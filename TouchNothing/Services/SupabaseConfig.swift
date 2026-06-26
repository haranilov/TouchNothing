import Foundation

enum SupabaseConfigError: Error {
    case missingSecretsFile
    case invalidURL
    case missingAnonKey
}

enum SupabaseConfig {
    static func load() throws -> (url: URL, anonKey: String) {
        guard let secretsPath = Bundle.main.path(forResource: "SupabaseSecrets", ofType: "plist") else {
            throw SupabaseConfigError.missingSecretsFile
        }

        guard let secretsDictionary = NSDictionary(contentsOfFile: secretsPath) as? [String: Any] else {
            throw SupabaseConfigError.missingSecretsFile
        }

        guard let urlString = secretsDictionary["SUPABASE_URL"] as? String,
              let projectURL = URL(string: urlString),
              !urlString.contains("YOUR_PROJECT_REF") else {
            throw SupabaseConfigError.invalidURL
        }

        guard let anonKey = secretsDictionary["SUPABASE_ANON_KEY"] as? String,
              !anonKey.contains("YOUR_ANON_KEY") else {
            throw SupabaseConfigError.missingAnonKey
        }

        return (projectURL, anonKey)
    }
}
