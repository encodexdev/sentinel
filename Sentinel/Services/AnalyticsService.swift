import Foundation

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {
        // Private initializer for singleton
    }
    
    /// Track analytics events
    /// - Parameters:
    ///   - event: Name of the event
    ///   - parameters: Optional event parameters
    func track(_ event: String, parameters: [String: Any]? = nil) {
        #if DEBUG
        // Log to console in debug mode
        if let parameters = parameters {
            print("📊 ANALYTICS EVENT: \(event) - \(parameters)")
        } else {
            print("📊 ANALYTICS EVENT: \(event)")
        }
        #else
        // In production, we would connect to a real analytics service like Firebase Analytics
        #endif
    }
    
    // Predefined events for consistent tracking
    struct Events {
        static let messageSent = "message_sent"
        static let emergencyRequested = "emergency_requested"
        static let imageUploaded = "image_uploaded"
        static let reportSubmitted = "report_submitted"
        static let incidentAccepted = "incident_accepted"
        static let chatOpened = "chat_opened"
        static let assistantResponded = "assistant_responded"
    }
}
