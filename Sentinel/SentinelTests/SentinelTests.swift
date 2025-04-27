//
//  SentinelTests.swift
//  SentinelTests
//
//  Created by Cameron  Faith on 2025-04-21.
//

import Testing
import XCTest
@testable import Sentinel

struct SentinelTests {
    
    @Test func testReportDataInitialization() async throws {
        // Arrange
        let title = "Test Incident"
        let description = "This is a test incident"
        let location = "Test Location"
        let status = IncidentStatus.open
        
        // Act
        let report = ReportData(
            title: title,
            description: description,
            location: location,
            status: status
        )
        
        // Assert
        #expect(report.title == title)
        #expect(report.description == description)
        #expect(report.location == location)
        #expect(report.status == status)
        #expect(report.userComments.isEmpty)
        #expect(report.images.isEmpty)
    }
    
    @Test func testReportToIncidentConversion() async throws {
        // Arrange
        let id = "test-id"
        let title = "Test Incident"
        let description = "This is a test incident"
        let location = "Test Location"
        let timestamp = Date()
        let status = IncidentStatus.open
        
        let report = ReportData(
            id: id,
            title: title,
            description: description,
            location: location,
            timestamp: timestamp,
            status: status
        )
        
        // Act
        let incident = report.toIncident()
        
        // Assert
        #expect(incident.id == id)
        #expect(incident.title == title)
        #expect(incident.description == description)
        #expect(incident.location == location)
        #expect(incident.time == timestamp)
        #expect(incident.status == status)
    }
    
    @Test func testChatMessageCreation() async throws {
        // Arrange & Act
        let message = ChatMessage(
            id: "test-id",
            role: .user,
            content: "Test message",
            timestamp: Date(),
            messageType: .chat
        )
        
        // Assert
        #expect(message.id == "test-id")
        #expect(message.role == .user)
        #expect(message.content == "Test message")
        #expect(message.messageType == .chat)
    }
    
    @Test func testEmergencyMessageCreation() async throws {
        // Arrange & Act
        let level = "Security"
        let message = ChatMessage(emergencyLevel: level)
        
        // Assert
        #expect(message.role == .user)
        #expect(message.content == "EMERGENCY: Security assistance requested")
        #expect(message.messageType == .emergency)
    }
    
    @Test func testImageMessageCreation() async throws {
        // Arrange & Act
        let count = 3
        let message = ChatMessage(imageUploadCount: count)
        
        // Assert
        #expect(message.role == .user)
        #expect(message.content == "Uploaded 3 image(s)")
        #expect(message.messageType == .image)
    }
}
