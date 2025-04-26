import Foundation
import DotEnv

enum OpenAIStreamResult {
    case token(String)
    case error(Error)
    case done
}

enum OpenAIServiceError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case apiKeyMissing
}

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    // System prompts for different flows
    static let normalSystemPrompt = """
    You are a security-assistant AI helping security personnel document incidents. 
    Be concise, professional, and focused on gathering relevant information.
    Ask clarifying questions to better understand the incident details.
    """
    
    static let emergencySystemPrompt = """
    You are handling an urgent security alert. Be brief, direct, and focused.
    Help the security personnel gather critical information for emergency response.
    Use short sentences and prioritize safety instructions.
    """
    
    init(apiKey: String? = nil) throws {
        // Load environment variables from .env
        do {
            // Could load this in an environment loader if there were other api services
            _ = try DotEnv.load(path: ".env")
        } catch {
            // Could not load .env
            throw OpenAIServiceError.apiKeyMissing
        }
        // Resolve API key: provided, or from environment
        if let key = apiKey, !key.isEmpty {
            self.apiKey = key
        } else if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            self.apiKey = envKey
        } else {
            throw OpenAIServiceError.apiKeyMissing
        }
    }
    
    func sendStreamingCompletion(
        messages: [ChatMessage],
        isEmergency: Bool = false,
        model: String = "gpt-3.5-turbo",
        temperature: Double = 0.7,
        onReceive: @escaping (OpenAIStreamResult) -> Void
    ) {
        // Validate API key
        guard !apiKey.isEmpty else {
            onReceive(.error(OpenAIServiceError.apiKeyMissing))
            return
        }
        
        // Prepare URL
        guard let url = URL(string: baseURL) else {
            onReceive(.error(OpenAIServiceError.invalidURL))
            return
        }
        
        // Determine system prompt based on flow
        let systemPrompt = isEmergency ? Self.emergencySystemPrompt : Self.normalSystemPrompt
        
        // Create API messages
        var apiMessages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Convert our app's messages to OpenAI format
        for message in messages {
            let role = message.role == .user ? "user" : "assistant"
            apiMessages.append(["role": role, "content": message.content])
        }
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": model,
            "messages": apiMessages,
            "temperature": temperature,
            "stream": true
        ]
        
        // Serialize request body
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            onReceive(.error(OpenAIServiceError.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle request errors
            if let error = error {
                onReceive(.error(OpenAIServiceError.requestFailed(error)))
                return
            }
            
            // Handle empty response
            guard let data = data else {
                onReceive(.error(OpenAIServiceError.invalidResponse))
                return
            }
            
            // Process streaming response
            self.processStreamingResponse(data: data, onReceive: onReceive)
        }
        
        task.resume()
    }
    
    private func processStreamingResponse(data: Data, onReceive: @escaping (OpenAIStreamResult) -> Void) {
        // Split the response by lines
        let responseString = String(decoding: data, as: UTF8.self)
        let lines = responseString.components(separatedBy: "\n\n")
        
        for line in lines {
            if line.hasPrefix("data: ") {
                let jsonString = line.dropFirst(6) // Remove "data: " prefix
                
                // Handle [DONE] marker
                if jsonString.contains("[DONE]") {
                    onReceive(.done)
                    return
                }
                
                // Parse JSON response
                if let data = jsonString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let choice = choices.first,
                   let delta = choice["delta"] as? [String: Any],
                   let content = delta["content"] as? String {
                    
                    // Send token to handler
                    onReceive(.token(content))
                }
            }
        }
    }
}
