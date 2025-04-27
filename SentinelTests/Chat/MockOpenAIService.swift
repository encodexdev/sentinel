import Foundation
import UIKit
@testable import Sentinel

/// Mock implementation of OpenAIService for testing
class MockOpenAIService: OpenAIService {
    
    // Tracks whether specific methods were called
    var streamingCompletionCalled = false
    var chatCompletionCalled = false
    var reportGenerationCalled = false
    
    // Control mock behavior
    var shouldSucceed = true
    var simulateNetworkDelay = true
    var delayInterval: TimeInterval = 0.1
    
    // Custom response content
    var mockResponseContent = "This is a mock response"
    var mockFunctionName = "generateReport"
    var mockFunctionArgs: [String: Any] = [
        "title": "Mock Report",
        "description": "This is a mock report description",
        "location": "Mock Location",
        "status": "open"
    ]
    
    // Override initializer to avoid API key requirements
    override init(apiKey: String? = nil) throws {
        try super.init(apiKey: apiKey ?? "mock-key")
    }
    
    // MARK: - Mock Streaming Methods
    
    /// Mocks the streaming chat completion
    override func sendStreamingChatCompletion(
        messages: [ChatMessage],
        systemPrompt: String,
        functions: [[String: Any]]? = nil,
        images: [UIImage] = [],
        model: String = "gpt-4o",
        temperature: Double = 0.7,
        onReceive: @escaping (OpenAIStreamResult) -> Void
    ) {
        streamingCompletionCalled = true
        
        if !shouldSucceed {
            onReceive(.error(OpenAIServiceError.requestFailed(NSError(domain: "MockError", code: -1))))
            return
        }
        
        // Create delay blocks for simulating real streaming
        let tokenDelays: [(TimeInterval, String)] = [
            (0.01, "Hello"),
            (0.02, ", I'm"),
            (0.03, " the"),
            (0.04, " mock"),
            (0.05, " AI"),
            (0.06, " assistant.")
        ]
        
        // Send tokens with delay
        for (index, (delay, token)) in tokenDelays.enumerated() {
            if simulateNetworkDelay {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    onReceive(.token(token))
                    
                    // If this is the last token, also handle function call if needed
                    if index == tokenDelays.count - 1 && functions != nil {
                        self.simulateFunctionCall(onReceive: onReceive)
                    }
                }
            } else {
                onReceive(.token(token))
            }
        }
        
        // If not simulating network delay and functions exist, simulate function call
        if !simulateNetworkDelay && functions != nil {
            simulateFunctionCall(onReceive: onReceive)
        }
        
        // Send done signal
        let finalDelay = simulateNetworkDelay ? 0.1 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + finalDelay) {
            onReceive(.done)
        }
    }
    
    /// Helper to simulate function calls
    private func simulateFunctionCall(onReceive: @escaping (OpenAIStreamResult) -> Void) {
        // Send function name
        onReceive(.functionCall(mockFunctionName, [:]))
        
        // Convert function args to JSON string
        if let argsData = try? JSONSerialization.data(withJSONObject: mockFunctionArgs),
           let argsString = String(data: argsData, encoding: .utf8) {
            
            // Simulate chunked arguments like the real API
            let halfPoint = argsString.index(argsString.startIndex, offsetBy: argsString.count / 2)
            let firstChunk = String(argsString[..<halfPoint])
            let secondChunk = String(argsString[halfPoint...])
            
            // Send chunks
            onReceive(.functionCall("__args_chunk__", ["chunk": firstChunk]))
            onReceive(.functionCall("__args_chunk__", ["chunk": secondChunk]))
        }
    }
    
    // MARK: - Mock Chat Completion
    
    /// Mocks the non-streaming chat completion
    override func sendChatCompletion(
        messages: [ChatMessage],
        systemPrompt: String,
        functions: [[String: Any]]? = nil,
        images: [UIImage] = [],
        model: String = "gpt-4o",
        temperature: Double = 0.7,
        completion: @escaping (Result<ChatCompletionResponse, Error>) -> Void
    ) {
        chatCompletionCalled = true
        
        let delay = simulateNetworkDelay ? delayInterval : 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if !self.shouldSucceed {
                completion(.failure(OpenAIServiceError.requestFailed(NSError(domain: "MockError", code: -1))))
                return
            }
            
            if functions != nil {
                // Return with function call
                let functionCall = FunctionCall(name: self.mockFunctionName, arguments: self.mockFunctionArgs)
                let response = ChatCompletionResponse(content: "", functionCall: functionCall)
                completion(.success(response))
            } else {
                // Return with content only
                let response = ChatCompletionResponse(content: self.mockResponseContent, functionCall: nil)
                completion(.success(response))
            }
        }
    }
    
    // MARK: - Mock Report Generation
    
    /// Mocks the report generation function
    override func generateReport(
        from messages: [ChatMessage],
        incidentType: String? = nil,
        isEmergency: Bool = false,
        images: [UIImage] = [],
        completion: @escaping (Result<ReportData, Error>) -> Void
    ) {
        reportGenerationCalled = true
        
        let delay = simulateNetworkDelay ? delayInterval : 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if !self.shouldSucceed {
                completion(.failure(OpenAIServiceError.requestFailed(NSError(domain: "MockError", code: -1))))
                return
            }
            
            // Extract content from messages to determine report type
            let messageContent = messages.map { $0.content }.joined(separator: " ")
            
            // Determine title based on content or incident type
            var title = "General Incident"
            if let type = incidentType, !type.isEmpty {
                title = "\(type) Incident"
            } else if messageContent.contains("suspicious") {
                title = "Suspicious Person"
            } else if messageContent.contains("theft") {
                title = "Theft Report"
            } else if messageContent.contains("damage") {
                title = "Property Damage"
            }
            
            // Determine status based on emergency flag
            let status: IncidentStatus = isEmergency ? .inProgress : .open
            
            // Create mock report
            let report = ReportData(
                title: title,
                description: "Description generated from user messages: \(messageContent.prefix(100))",
                location: "Location extracted from conversation",
                timestamp: Date(),
                status: status,
                userComments: messages.filter { $0.role == .user }.map { $0.content },
                images: images
            )
            
            completion(.success(report))
        }
    }
}