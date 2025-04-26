import XCTest
@testable import Sentinel

final class ChatViewModelTests: XCTestCase {
    
    private var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ChatViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Verify the view model starts with one welcome message
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages[0].sender, .assistant)
        XCTAssertTrue(viewModel.messages[0].content.contains("What kind of incident"))
    }
    
    func testSendMessage() {
        // Given a message to send
        viewModel.inputText = "Testing message"
        
        // When sending the message
        viewModel.sendMessage()
        
        // Then the message should be added to the messages array
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages[1].sender, .user)
        XCTAssertEqual(viewModel.messages[1].content, "Testing message")
        
        // And the input text should be cleared
        XCTAssertEqual(viewModel.inputText, "")
        
        // Wait for the assistant response
        let expectation = XCTestExpectation(description: "Wait for assistant response")
        
        // Check after 1.5 seconds (giving time for the simulated assistant response)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Then there should be an assistant response
            XCTAssertEqual(self.viewModel.messages.count, 3)
            XCTAssertEqual(self.viewModel.messages[2].sender, .assistant)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSelectIncidentType() {
        // When selecting an incident type
        viewModel.selectIncidentType("Theft")
        
        // Then a user message should be added with that type
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages[1].sender, .user)
        XCTAssertEqual(viewModel.messages[1].content, "Theft")
        
        // Wait for the assistant response
        let expectation = XCTestExpectation(description: "Wait for assistant response")
        
        // Check after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Then there should be an assistant response acknowledging the type
            XCTAssertEqual(self.viewModel.messages.count, 3)
            XCTAssertEqual(self.viewModel.messages[2].sender, .assistant)
            XCTAssertTrue(self.viewModel.messages[2].content.contains("Theft"))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.5)
    }
    
    func testSendEmergencyMessage() {
        // When sending an emergency message
        viewModel.sendEmergencyMessage(level: "Police")
        
        // Then a user emergency message should be added
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages[1].sender, .user)
        XCTAssertEqual(viewModel.messages[1].messageType, .emergency)
        XCTAssertTrue(viewModel.messages[1].content.contains("Police"))
        
        // Wait for the assistant response (emergency responses are faster)
        let expectation = XCTestExpectation(description: "Wait for emergency response")
        
        // Check after 0.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Then there should be an emergency-typed assistant response
            XCTAssertEqual(self.viewModel.messages.count, 3)
            XCTAssertEqual(self.viewModel.messages[2].sender, .assistant)
            XCTAssertEqual(self.viewModel.messages[2].messageType, .emergency)
            XCTAssertTrue(self.viewModel.messages[2].content.contains("EMERGENCY"))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testShouldShowChips() {
        // Should show chips after the first assistant message only
        XCTAssertTrue(viewModel.shouldShowChips(after: viewModel.messages[0]))
        
        // Send a message to add more messages
        viewModel.inputText = "Test message"
        viewModel.sendMessage()
        
        // Wait for the assistant response
        let expectation = XCTestExpectation(description: "Wait for messages")
        
        // Check after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Should not show chips after subsequent messages
            XCTAssertFalse(self.viewModel.shouldShowChips(after: self.viewModel.messages[0]))
            XCTAssertFalse(self.viewModel.shouldShowChips(after: self.viewModel.messages[1]))
            XCTAssertFalse(self.viewModel.shouldShowChips(after: self.viewModel.messages[2]))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testEmptyMessageCannotBeSent() {
        // Given an empty message
        viewModel.inputText = "   "
        
        // When trying to send
        viewModel.sendMessage()
        
        // Then no message should be sent (still only initial message)
        XCTAssertEqual(viewModel.messages.count, 1)
    }
}