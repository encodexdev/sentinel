import Testing
import XCTest
@testable import Sentinel

/// Tests for the OpenAIService component
struct OpenAIServiceTests {
    
    // MARK: - Test Initialization
    
    @Test func testInitializationWithKey() async throws {
        // Arrange
        let validKey = "valid-api-key"
        
        // Act
        let service = try OpenAIService(apiKey: validKey)
        
        // Assert
        #expect(service.apiKey == validKey)
    }
    
    @Test func testInitializationWithoutKey() async throws {
        // Skip if no environment variable is set
        try XCTSkipIf(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] == nil, 
                     "Skipping test because OPENAI_API_KEY environment variable is not set")
        
        // Act
        let service = try OpenAIService()
        
        // Assert
        #expect(!service.apiKey.isEmpty)
    }
    
    @Test func testInitializationFailsWithEmptyKey() async throws {
        // Act & Assert
        #expect(throws: OpenAIServiceError.apiKeyMissing) {
            _ = try OpenAIService(apiKey: "")
        }
    }
    
    // MARK: - Test System Prompts
    
    @Test func testNormalSystemPrompt() async throws {
        // Arrange
        let service = try XCTSkipIf(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] == nil, 
                                  "Skipping test because OPENAI_API_KEY is not set")
            ? try OpenAIService(apiKey: "mock-key")
            : try OpenAIService()
        
        // Act
        let prompt = service.normalSystemPrompt
        
        // Assert
        #expect(!prompt.isEmpty)
        #expect(prompt.contains("incident reporting assistant"))
    }
    
    @Test func testEmergencySystemPrompt() async throws {
        // Arrange
        let service = try XCTSkipIf(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] == nil, 
                                  "Skipping test because OPENAI_API_KEY is not set")
            ? try OpenAIService(apiKey: "mock-key")
            : try OpenAIService()
        
        // Act
        let prompt = service.emergencySystemPrompt
        
        // Assert
        #expect(!prompt.isEmpty)
        #expect(prompt.contains("EMERGENCY"))
    }
    
    @Test func testCustomEmergencyPrompt() async throws {
        // Arrange
        let service = try XCTSkipIf(ProcessInfo.processInfo.environment["OPENAI_API_KEY"] == nil, 
                                  "Skipping test because OPENAI_API_KEY is not set")
            ? try OpenAIService(apiKey: "mock-key")
            : try OpenAIService()
        let level = "Medical"
        
        // Act
        let prompt = service.customEmergencyPrompt(level: level)
        
        // Assert
        #expect(!prompt.isEmpty)
        #expect(prompt.contains("MEDICAL"))
    }
    
    // MARK: - Mock API Tests
    
    @Test func testStreamingChatCompletion() async throws {
        // Arrange
        let mockService = try MockOpenAIService(apiKey: "mock-key")
        mockService.simulateNetworkDelay = false
        
        let messages = [
            ChatMessage(id: "1", role: .user, content: "Hello", timestamp: Date(), messageType: .chat)
        ]
        
        // Set expectations
        var tokenReceived = false
        var completionDone = false
        let expectation = XCTestExpectation(description: "Streaming completion")
        
        // Act
        mockService.sendStreamingChatCompletion(
            messages: messages,
            systemPrompt: "You are a test assistant",
            functions: nil
        ) { result in
            switch result {
            case .token:
                tokenReceived = true
            case .done:
                completionDone = true
                expectation.fulfill()
            default:
                break
            }
        }
        
        // Wait for completion
        await XCTWaiter().wait(for: [expectation], timeout: 1.0)
        
        // Assert
        #expect(mockService.streamingCompletionCalled)
        #expect(tokenReceived)
        #expect(completionDone)
    }
    
    @Test func testStreamingChatCompletionWithFunctionCalls() async throws {
        // Arrange
        let mockService = try MockOpenAIService(apiKey: "mock-key")
        mockService.simulateNetworkDelay = false
        
        let messages = [
            ChatMessage(id: "1", role: .user, content: "Generate a report", timestamp: Date(), messageType: .chat)
        ]
        
        let functionDefs: [[String: Any]] = [
            [
                "name": "generateReport",
                "description": "Generate an incident report",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "title": ["type": "string"],
                        "description": ["type": "string"]
                    ]
                ]
            ]
        ]
        
        // Set expectations
        var functionCallReceived = false
        var argsChunkReceived = false
        var completionDone = false
        let expectation = XCTestExpectation(description: "Function call completion")
        
        // Act
        mockService.sendStreamingChatCompletion(
            messages: messages,
            systemPrompt: "You are a test assistant",
            functions: functionDefs
        ) { result in
            switch result {
            case .functionCall(let name, let args):
                if name == "generateReport" {
                    functionCallReceived = true
                } else if name == "__args_chunk__" {
                    argsChunkReceived = true
                }
            case .done:
                completionDone = true
                expectation.fulfill()
            default:
                break
            }
        }
        
        // Wait for completion
        await XCTWaiter().wait(for: [expectation], timeout: 1.0)
        
        // Assert
        #expect(mockService.streamingCompletionCalled)
        #expect(functionCallReceived)
        #expect(argsChunkReceived)
        #expect(completionDone)
    }
    
    @Test func testNonStreamingChatCompletion() async throws {
        // Arrange
        let mockService = try MockOpenAIService(apiKey: "mock-key")
        mockService.simulateNetworkDelay = false
        mockService.mockResponseContent = "This is a test response"
        
        let messages = [
            ChatMessage(id: "1", role: .user, content: "Hello", timestamp: Date(), messageType: .chat)
        ]
        
        // Set expectations
        let expectation = XCTestExpectation(description: "Chat completion")
        var responseContent: String?
        
        // Act
        mockService.sendChatCompletion(
            messages: messages,
            systemPrompt: "You are a test assistant"
        ) { result in
            switch result {
            case .success(let response):
                responseContent = response.content
                expectation.fulfill()
            case .failure:
                XCTFail("Chat completion failed")
            }
        }
        
        // Wait for completion
        await XCTWaiter().wait(for: [expectation], timeout: 1.0)
        
        // Assert
        #expect(mockService.chatCompletionCalled)
        #expect(responseContent == "This is a test response")
    }
    
    @Test func testNonStreamingChatCompletionWithFunctionCall() async throws {
        // Arrange
        let mockService = try MockOpenAIService(apiKey: "mock-key")
        mockService.simulateNetworkDelay = false
        mockService.mockFunctionName = "testFunction"
        mockService.mockFunctionArgs = ["param1": "value1", "param2": "value2"]
        
        let messages = [
            ChatMessage(id: "1", role: .user, content: "Run function", timestamp: Date(), messageType: .chat)
        ]
        
        let functionDefs: [[String: Any]] = [
            [
                "name": "testFunction",
                "description": "A test function",
                "parameters": [
                    "type": "object",
                    "properties": [
                        "param1": ["type": "string"],
                        "param2": ["type": "string"]
                    ]
                ]
            ]
        ]
        
        // Set expectations
        let expectation = XCTestExpectation(description: "Function call completion")
        var functionName: String?
        var functionArgs: [String: Any]?
        
        // Act
        mockService.sendChatCompletion(
            messages: messages,
            systemPrompt: "You are a test assistant",
            functions: functionDefs
        ) { result in
            switch result {
            case .success(let response):
                functionName = response.functionCall?.name
                functionArgs = response.functionCall?.arguments
                expectation.fulfill()
            case .failure:
                XCTFail("Chat completion failed")
            }
        }
        
        // Wait for completion
        await XCTWaiter().wait(for: [expectation], timeout: 1.0)
        
        // Assert
        #expect(mockService.chatCompletionCalled)
        #expect(functionName == "testFunction")
        #expect(functionArgs?["param1"] as? String == "value1")
        #expect(functionArgs?["param2"] as? String == "value2")
    }
    
    @Test func testReportGeneration() async throws {
        // Arrange
        let mockService = try MockOpenAIService(apiKey: "mock-key")
        mockService.simulateNetworkDelay = false
        
        let messages = [
            ChatMessage(id: "1", role: .assistant, content: "What happened?", timestamp: Date(), messageType: .chat),
            ChatMessage(id: "2", role: .user, content: "I saw a suspicious person", timestamp: Date(), messageType: .chat)
        ]
        
        // Set expectations
        let expectation = XCTestExpectation(description: "Report generation")
        var reportData: ReportData?
        
        // Act
        mockService.generateReport(
            from: messages,
            incidentType: nil,
            isEmergency: false
        ) { result in
            switch result {
            case .success(let report):
                reportData = report
                expectation.fulfill()
            case .failure:
                XCTFail("Report generation failed")
            }
        }
        
        // Wait for completion
        await XCTWaiter().wait(for: [expectation], timeout: 1.0)
        
        // Assert
        #expect(mockService.reportGenerationCalled)
        #expect(reportData != nil)
        #expect(reportData?.title.contains("Suspicious"))
        #expect(reportData?.status == .open)
    }
    
    @Test func testEmergencyReportGeneration() async throws {
        // Arrange
        let mockService = try MockOpenAIService(apiKey: "mock-key")
        mockService.simulateNetworkDelay = false
        
        let messages = [
            ChatMessage(id: "1", role: .assistant, content: "What's your emergency?", timestamp: Date(), messageType: .emergency),
            ChatMessage(id: "2", role: .user, content: "There's a fire", timestamp: Date(), messageType: .emergency)
        ]
        
        // Set expectations
        let expectation = XCTestExpectation(description: "Emergency report generation")
        var reportData: ReportData?
        
        // Act
        mockService.generateReport(
            from: messages,
            incidentType: "Fire",
            isEmergency: true
        ) { result in
            switch result {
            case .success(let report):
                reportData = report
                expectation.fulfill()
            case .failure:
                XCTFail("Report generation failed")
            }
        }
        
        // Wait for completion
        await XCTWaiter().wait(for: [expectation], timeout: 1.0)
        
        // Assert
        #expect(mockService.reportGenerationCalled)
        #expect(reportData != nil)
        #expect(reportData?.title.contains("Fire"))
        #expect(reportData?.status == .inProgress)
    }
    
    @Test func testErrorHandling() async throws {
        // Arrange
        let mockService = try MockOpenAIService(apiKey: "mock-key")
        mockService.shouldSucceed = false
        mockService.simulateNetworkDelay = false
        
        let messages = [
            ChatMessage(id: "1", role: .user, content: "Hello", timestamp: Date(), messageType: .chat)
        ]
        
        // Set expectations
        let expectation = XCTestExpectation(description: "Error handling")
        var receivedError = false
        
        // Act
        mockService.generateReport(
            from: messages
        ) { result in
            switch result {
            case .success:
                XCTFail("Expected error but got success")
            case .failure:
                receivedError = true
                expectation.fulfill()
            }
        }
        
        // Wait for completion
        await XCTWaiter().wait(for: [expectation], timeout: 1.0)
        
        // Assert
        #expect(mockService.reportGenerationCalled)
        #expect(receivedError)
    }
}