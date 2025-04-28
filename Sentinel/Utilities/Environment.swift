import Foundation
import Security

/// Configuration helper to access app variables securely
struct AppConfig {
    
    /// App configuration variables from Info.plist
    enum Keys: String {
        case openAIApiKey = "OPENAI_API_KEY"
    }
    
    /// Retrieve a configuration value from Info.plist
    /// - Parameter key: The configuration key to retrieve
    /// - Returns: The value for the specified key, or nil if not found
    static func value(for key: Keys) -> String? {
        guard let value = Bundle.main.infoDictionary?[key.rawValue] as? String,
              !value.isEmpty,
              !value.contains("$(") // Check it's not an unexpanded variable
        else {
            return nil
        }
        
        return value
    }
    
    /// Retrieve a key securely, first checking the keychain, then Info.plist
    /// - Parameter key: The key to retrieve
    /// - Returns: The secure value, or nil if not found
    static func secureValue(for key: Keys) -> String? {
        // First try the keychain (for runtime storage)
        if let keychainValue = KeychainManager.retrieve(key: key.rawValue) {
            return keychainValue
        }
        
        // Then fall back to Info.plist (for build-time injection)
        return value(for: key)
    }
}

/// Simple Keychain wrapper for secure storage
class KeychainManager {
    
    /// Store a value in the keychain
    /// - Parameters:
    ///   - value: The value to store
    ///   - key: The key to store it under
    /// - Returns: True if successful, false otherwise
    @discardableResult
    static func store(value: String, key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing key before saving
        SecItemDelete(query as CFDictionary)
        
        // Save the key
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve a value from the keychain
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored value, or nil if not found
    static func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let retrievedData = dataTypeRef as? Data,
              let result = String(data: retrievedData, encoding: .utf8)
        else {
            return nil
        }
        
        return result
    }
    
    /// Delete a value from the keychain
    /// - Parameter key: The key to delete
    /// - Returns: True if successful, false otherwise
    @discardableResult
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}