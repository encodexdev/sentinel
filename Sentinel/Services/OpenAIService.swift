import Foundation
import UIKit
import Security

/// Results from a streaming OpenAI request
enum OpenAIStreamResult {
  case token(String)
  case functionCall(String, [String: Any])
  case error(Error)
  case done
}

/// Possible errors from OpenAI service
enum OpenAIServiceError: Error {
  case invalidURL
  case requestFailed(Error)
  case invalidResponse
  case apiKeyMissing
  case jsonParsingError
  case functionCallParsingError
  case missingRequiredFields
}

/// Function call from OpenAI
struct FunctionCall {
  let name: String
  let arguments: [String: Any]
}

/// Response from OpenAI chat completion
struct ChatCompletionResponse {
  let content: String
  let functionCall: FunctionCall?
}

/// Service for interacting with OpenAI API
class OpenAIService {
  // MARK: - Properties
  
  /// API key for authentication
  private(set) var apiKey: String
  
  /// Base URL for OpenAI API
  private let baseURL = "https://api.openai.com/v1/chat/completions"
  
  // MARK: - Initializer
  
  init(apiKey: String? = nil) throws {
    // Use directly provided API key if available
    if let key = apiKey, !key.isEmpty {
      self.apiKey = key
      return
    }
    
    // Get API key from secure storage
    if let secureKey = KeychainManager.retrieve(key: AppConfig.Keys.openAIApiKey.rawValue) {
      self.apiKey = secureKey
      return
    }
    
    // Fall back to Info.plist
    if let bundleKey = AppConfig.value(for: .openAIApiKey) {
      self.apiKey = bundleKey
      return
    }
    
    // Check environment variables (useful for CI/CD)
    if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
       !envKey.isEmpty {
      self.apiKey = envKey
      
      // Store in keychain for future use
      _ = KeychainManager.store(value: envKey, key: AppConfig.Keys.openAIApiKey.rawValue)
      return
    }
    
    // No valid API key found through any method
    throw OpenAIServiceError.apiKeyMissing
  }
  
  // MARK: - System Prompts
  
  /// Normal system prompt for standard conversations
  var normalSystemPrompt: String {
    return ChatPrompts.standard
  }
  
  /// Emergency system prompt for emergency situations
  var emergencySystemPrompt: String {
    return ChatPrompts.emergency(level: "Security")
  }
  
  /// Create a custom emergency prompt with the specified level
  func customEmergencyPrompt(level: String) -> String {
    return ChatPrompts.emergency(level: level)
  }

  // MARK: - Basic Streaming API
  
  /// Legacy streaming completion method
  func sendStreamingCompletion(
    messages: [ChatMessage],
    isEmergency: Bool = false,
    model: String = "gpt-4o",
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
    let systemPrompt = isEmergency ? self.emergencySystemPrompt : self.normalSystemPrompt

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
      "stream": true,
    ]
    
    // Serialize request body
    guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
      onReceive(.error(OpenAIServiceError.jsonParsingError))
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

  private func processStreamingResponse(
    data: Data, onReceive: @escaping (OpenAIStreamResult) -> Void
  ) {
    // Split the response by lines
    let responseString = String(decoding: data, as: UTF8.self)
    let lines = responseString.components(separatedBy: "\n\n")

    for line in lines {
      if line.hasPrefix("data: ") {
        let jsonString = line.dropFirst(6)  // Remove "data: " prefix

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
          let content = delta["content"] as? String
        {
          // Send token to handler
          onReceive(.token(content))
        }
      }
    }
  }
  
  // MARK: - Enhanced API Methods
  
  /// Send a non-streaming chat completion request with optional function calling
  /// - Parameters:
  ///   - messages: Array of chat messages for conversation history
  ///   - systemPrompt: Custom system prompt to use
  ///   - functions: Optional function definitions for OpenAI function calling
  ///   - images: Optional array of images to include with the request
  ///   - model: OpenAI model to use
  ///   - temperature: Randomness parameter (0-1)
  ///   - completion: Callback with result
  func sendChatCompletion(
    messages: [ChatMessage],
    systemPrompt: String,
    functions: [[String: Any]]? = nil,
    images: [UIImage] = [],
    model: String = "gpt-4o",
    temperature: Double = 0.7,
    completion: @escaping (Result<ChatCompletionResponse, Error>) -> Void
  ) {
    // Validate API key
    guard !apiKey.isEmpty else {
      completion(.failure(OpenAIServiceError.apiKeyMissing))
      return
    }
    
    // Prepare URL
    guard let url = URL(string: baseURL) else {
      completion(.failure(OpenAIServiceError.invalidURL))
      return
    }
    
    // Create API messages
    var apiMessages: [[String: Any]] = [
      ["role": "system", "content": systemPrompt]
    ]
    
    // Convert our app's messages to OpenAI format
    for message in messages {
      let role = message.role == .user ? "user" : "assistant"
      
      // Prepare content - if we have images and this is a user message, we'll use a different format
      if !images.isEmpty && role == "user" && message.id == messages.last?.id {
        // For the latest user message if images are present, use content list format
        var contentList: [[String: Any]] = []
        
        // Add text content
        if !message.content.isEmpty {
          contentList.append(["type": "text", "text": message.content])
        }
        
        // Add images as base64
        for image in images {
          if let base64String = image.pngData()?.base64EncodedString() {
            contentList.append([
              "type": "image_url",
              "image_url": [
                "url": "data:image/png;base64,\(base64String)"
              ]
            ])
          }
        }
        
        apiMessages.append(["role": role, "content": contentList])
      } else {
        // Standard text message
        apiMessages.append(["role": role, "content": message.content])
      }
    }
    
    // Create request body
    var requestBody: [String: Any] = [
      "model": model,
      "messages": apiMessages,
      "temperature": temperature
    ]
    
    // Add function calling if provided
    if let functions = functions, !functions.isEmpty {
      requestBody["functions"] = functions
      requestBody["function_call"] = "auto"
    }
    
    // Serialize request body
    guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
      completion(.failure(OpenAIServiceError.jsonParsingError))
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
        completion(.failure(OpenAIServiceError.requestFailed(error)))
        return
      }
      
      // Handle empty response
      guard let data = data else {
        completion(.failure(OpenAIServiceError.invalidResponse))
        return
      }
      
      // Parse JSON response
      do {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        guard let json = json,
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first
        else {
          completion(.failure(OpenAIServiceError.invalidResponse))
          return
        }
        
        // Extract message content
        guard let message = firstChoice["message"] as? [String: Any] else {
          completion(.failure(OpenAIServiceError.missingRequiredFields))
          return
        }
        
        // Check for function call
        var functionCall: FunctionCall? = nil
        if let funcCall = message["function_call"] as? [String: Any],
           let name = funcCall["name"] as? String,
           let argumentsJson = funcCall["arguments"] as? String {
          
          // Parse function arguments
          if let argData = argumentsJson.data(using: .utf8),
             let args = try? JSONSerialization.jsonObject(with: argData, options: []) as? [String: Any] {
            functionCall = FunctionCall(name: name, arguments: args)
          } else {
            completion(.failure(OpenAIServiceError.functionCallParsingError))
            return
          }
        }
        
        // Get content (may be null if function_call is present)
        let content = message["content"] as? String ?? ""
        
        // Create response
        let chatResponse = ChatCompletionResponse(
          content: content,
          functionCall: functionCall
        )
        
        completion(.success(chatResponse))
        
      } catch {
        completion(.failure(OpenAIServiceError.jsonParsingError))
      }
    }
    
    task.resume()
  }
  
  /// Send streaming chat completion with function calling support
  /// - Parameters:
  ///   - messages: Array of chat messages for conversation history
  ///   - systemPrompt: Custom system prompt to use
  ///   - functions: Optional function definitions for OpenAI function calling
  ///   - images: Optional array of images to include with the request
  ///   - model: OpenAI model to use
  ///   - temperature: Randomness parameter (0-1)
  ///   - onReceive: Stream handler for tokens and function calls
  func sendStreamingChatCompletion(
    messages: [ChatMessage],
    systemPrompt: String,
    functions: [[String: Any]]? = nil,
    images: [UIImage] = [],
    model: String = "gpt-4o",
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
    
    // Create API messages
    var apiMessages: [[String: Any]] = [
      ["role": "system", "content": systemPrompt]
    ]
    
    // Convert our app's messages to OpenAI format
    for message in messages {
      let role = message.role == .user ? "user" : "assistant"
      
      // Prepare content - if we have images and this is a user message, we'll use a different format
      if !images.isEmpty && role == "user" && message.id == messages.last?.id {
        // For the latest user message if images are present, use content list format
        var contentList: [[String: Any]] = []
        
        // Add text content
        if !message.content.isEmpty {
          contentList.append(["type": "text", "text": message.content])
        }
        
        // Add images as base64
        for image in images {
          if let base64String = image.pngData()?.base64EncodedString() {
            contentList.append([
              "type": "image_url",
              "image_url": [
                "url": "data:image/png;base64,\(base64String)"
              ]
            ])
          }
        }
        
        apiMessages.append(["role": role, "content": contentList])
      } else {
        // Standard text message
        apiMessages.append(["role": role, "content": message.content])
      }
    }
    
    // Create request body
    var requestBody: [String: Any] = [
      "model": model,
      "messages": apiMessages,
      "temperature": temperature,
      "stream": true
    ]
    
    // Add function calling if provided
    if let functions = functions, !functions.isEmpty {
      requestBody["functions"] = functions
      requestBody["function_call"] = "auto"
    }
    
    // Serialize request body
    guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
      onReceive(.error(OpenAIServiceError.jsonParsingError))
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
      
      // Process streaming response with enhanced function call support
      self.processEnhancedStreamingResponse(data: data, onReceive: onReceive)
    }
    
    task.resume()
  }
  
  /// Process streaming response with support for function calls
  private func processEnhancedStreamingResponse(
    data: Data, onReceive: @escaping (OpenAIStreamResult) -> Void
  ) {
    // Split the response by lines
    let responseString = String(decoding: data, as: UTF8.self)
    let lines = responseString.components(separatedBy: "\n\n")
    
    for line in lines {
      if line.hasPrefix("data: ") {
        let jsonString = line.dropFirst(6)  // Remove "data: " prefix
        
        // Handle [DONE] marker
        if jsonString.contains("[DONE]") {
          onReceive(.done)
          return
        }
        
        // Parse JSON response
        if let data = jsonString.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let choice = choices.first {
          
          // Check for content delta
          if let delta = choice["delta"] as? [String: Any] {
            if let content = delta["content"] as? String {
              // Send token to handler
              onReceive(.token(content))
            }
            
            // Check for function call delta
            if let functionCall = delta["function_call"] as? [String: Any] {
              // For function name
              if let name = functionCall["name"] as? String {
                // Initial function call with name
                onReceive(.functionCall(name, [:]))
              }
              
              // For function arguments (may come in chunks)
              if let argsChunk = functionCall["arguments"] as? String {
                // We're only sending argument chunks here
                // The actual JSON parsing happens later when all chunks are collected
                onReceive(.functionCall("__args_chunk__", ["chunk": argsChunk]))
              }
            }
          }
        }
      }
    }
  }
  
  // MARK: - Report Generation
  
  /// Generate a complete report from conversation history
  func generateReport(
    from messages: [ChatMessage],
    incidentType: String? = nil,
    isEmergency: Bool = false,
    images: [UIImage] = [],
    completion: @escaping (Result<ReportData, Error>) -> Void
  ) {
    // Select appropriate system prompt
    let systemPrompt = isEmergency ? 
      ChatPrompts.emergencyReportGeneration :
      ChatPrompts.reportGeneration
      
    // Use function definitions for report generation
    let functionDefs: [[String: Any]] = [
      [
        "name": "createIncidentReport",
        "description": "Create a detailed incident report from conversation",
        "parameters": [
          "type": "object",
          "properties": [
            "title": [
              "type": "string",
              "description": "Clear, descriptive title for the incident"
            ],
            "description": [
              "type": "string",
              "description": "Comprehensive description of the incident"
            ],
            "location": [
              "type": "string",
              "description": "Where the incident occurred"
            ],
            "status": [
              "type": "string",
              "enum": ["open", "inProgress", "resolved"],
              "description": "Current status of the incident"
            ],
            "userComments": [
              "type": "array",
              "items": [
                "type": "string"
              ],
              "description": "Key statements from the user about the incident"
            ]
          ],
          "required": ["title", "description", "status"]
        ]
      ]
    ]
    
    // If incident type is provided, append it to the first message
    var contextMessages = messages
    if let type = incidentType, !type.isEmpty {
      // Add incident type context to the prompt
      let contextMessage = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content: "This is a \(type) incident report.",
        timestamp: Date(),
        messageType: .chat
      )
      contextMessages.insert(contextMessage, at: 0)
    }
    
    // Send completion request
    sendChatCompletion(
      messages: contextMessages,
      systemPrompt: systemPrompt,
      functions: functionDefs,
      images: images
    ) { result in
      switch result {
      case .success(let response):
        // Check for function call
        if let functionCall = response.functionCall,
           functionCall.name == "createIncidentReport" {
          
          // Extract required fields
          guard let title = functionCall.arguments["title"] as? String,
                let description = functionCall.arguments["description"] as? String
          else {
            completion(.failure(OpenAIServiceError.missingRequiredFields))
            return
          }
          
          // Extract optional fields with defaults
          let location = functionCall.arguments["location"] as? String ?? "Unknown Location"
          let statusStr = functionCall.arguments["status"] as? String ?? (isEmergency ? "inProgress" : "open")
          let userComments = functionCall.arguments["userComments"] as? [String] ?? []
          
          // Map status string to enum
          let status: IncidentStatus
          switch statusStr.lowercased() {
          case "open": status = .open
          case "inprogress", "in_progress", "in progress": status = .inProgress
          case "resolved": status = .resolved
          default: status = isEmergency ? .inProgress : .open
          }
          
          // Create report data
          let report = ReportData(
            title: title,
            description: description,
            location: location,
            timestamp: Date(),
            status: status,
            userComments: userComments,
            images: images
          )
          
          completion(.success(report))
          
        } else {
          // If no function call, try to parse from content (less reliable)
          completion(.failure(OpenAIServiceError.functionCallParsingError))
        }
        
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
