import Foundation

/// Provider that makes Environment and KeychainManager accessible
class EnvironmentProvider {
    static let shared = EnvironmentProvider()
    
    /// Get a value from the environment
    func getValue(for key: Environment.Keys) -> String? {
        return Environment.value(for: key)
    }
    
    /// Get a secure value from keychain or environment
    func getSecureValue(for key: Environment.Keys) -> String? {
        return Environment.secureValue(for: key)
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