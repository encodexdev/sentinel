import Foundation

/// The type of message being sent or received
enum MessageType: String, Codable {
    /// Standard text message
    case chat
    
    /// Emergency assistance message
    case emergency
    
    /// Message containing image(s)
    case image
    
    /// Report message containing incident details
    case report
    
    /// Loading indicator while AI is typing
    case loading
}
