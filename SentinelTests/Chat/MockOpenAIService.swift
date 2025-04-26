import Foundation
@testable import Sentinel

// A test mock of the OpenAI service to verify integration
class MockOpenAIService {
    // Track calls to the service
    var completionCalls: [(messages: [ChatMessage], isEmergency: Bool)] = []
    
    // Configurable responses
    var responseDelay: TimeInterval = 0.2
    var responseTokens: [String] = ["This", " is", " a", " test", " response", "."]
    
    // Flag to simulate errors
    var shouldFail: Bool = false
    var simulatedError: Error?
    
    func sendStreamingCompletion(
        messages: [ChatMessage],
        isEmergency: Bool = false,
        model: String = "gpt-3.5-turbo",
        temperature: Double = 0.7,
        onReceive: @escaping (OpenAIStreamResult) -> Void
    ) {
        // Record this call
        completionCalls.append((messages: messages, isEmergency: isEmergency))
        
        // If configured to fail, return error
        if shouldFail {
            DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
                onReceive(.error(self.simulatedError ?? OpenAIServiceError.invalidResponse))
            }
            return
        }
        
        // Stream tokens with slight delays
        let tokensPerStep = 1
        var index = 0
        
        func sendNextTokens() {
            guard index < responseTokens.count else {
                onReceive(.done)
                return
            }
            
            let end = min(index + tokensPerStep, responseTokens.count)
            let tokenBatch = responseTokens[index..<end]
            
            for token in tokenBatch {
                onReceive(.token(token))
            }
            
            index = end
            
            if index < responseTokens.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    sendNextTokens()
                }
            } else {
                onReceive(.done)
            }
        }
        
        // Start sending after initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + responseDelay) {
            sendNextTokens()
        }
    }
}