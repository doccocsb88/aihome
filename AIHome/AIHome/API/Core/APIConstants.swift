import Foundation

public enum APIConstants {
    /// The API key provided by the user for HomeDesignsAI
    public static let homeDesignsAPIKey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJuYW1lIjoiVGhlIEFuaCBUcmFuIiwiZW1haWwiOiJhbmh0dEBiaWxsaW9ueC5jbyJ9.rRdbeAWEbuAP-ULCcC3AJ1CbAapcxJaCXw-rMNfetJc"
    public static let homeDesignsBaseURL = URL(string: "https://homedesigns.ai/api/v2")!
    public static let homeAIBackendBaseURL = URL(string: "https://aiart.billionx.co")!

    public enum HomeAIBackend {
        public static let authorizationHeaderName = "Api-Key"
        public static let devAPIKey = "mhj9xxGV.Thk4JCaeUriamUBn2iDSq184sCJrEIYM"
        public static let apiKeyEnvironmentKey = "HOME_AI_BACKEND_API_KEY"
        public static let apiKeyInfoPlistKey = "HOME_AI_BACKEND_API_KEY"
        public static let apiKeyUserDefaultsKey = "HOME_AI_BACKEND_API_KEY"
    }
}
