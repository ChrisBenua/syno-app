import Foundation

class RequestSettings {
    public static let URLPrefix = "http://localhost:8080"

    public static let LoginEndPoint = URLPrefix + "/api/auth/signin"
    
    public static let RegisterEndPoint = URLPrefix + "/api/auth/signup"
    
    public static let AllDicts = URLPrefix + "/api/dicts/my_all"
    
    public static let UploadDicts = URLPrefix + "/api/dicts/update"
    
    public static let AddShare = URLPrefix + "/api/dict_share/add_share"
    
    public static func getShare(shareUUID: String) -> String {
        return URLPrefix + "/api/dict_share/get_share/\(shareUUID)"
    }
}
