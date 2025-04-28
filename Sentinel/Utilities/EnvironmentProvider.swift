import Foundation
import Security

/// Provider that makes AppConfig and KeychainManager accessible
class ConfigProvider {
    static let shared = ConfigProvider()
    
    /// Get a value from the app configuration
    func getValue(for key: AppConfig.Keys) -> String? {
        return AppConfig.value(for: key)
    }
    
    /// Get a secure value from keychain or app configuration
    func getSecureValue(for key: AppConfig.Keys) -> String? {
        return AppConfig.secureValue(for: key)
    }
    
    /// Store a value in the keychain
    func storeInKeychain(value: String, key: String) -> Bool {
        return KeychainManager.store(value: value, key: key)
    }
    
    /// Get a value from the keychain
    func getFromKeychain(key: String) -> String? {
        return KeychainManager.retrieve(key: key)
    }
}