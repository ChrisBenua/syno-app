import Foundation

/// Class for storing Request URLs
class RequestSettings {
    /// Server's host
    public static let URLPrefix = "http://localhost:8080"
    /// Server's login end point
    public static let LoginEndPoint = URLPrefix + "/api/auth/signin"
    /// Server's registration end point
    public static let RegisterEndPoint = URLPrefix + "/api/auth/signup"
    /// Server's fetching all dictionaries end point
    public static let AllDicts = URLPrefix + "/api/dicts/my_all"
    /// Server's uploading dicitonaries end point
    public static let UploadDicts = URLPrefix + "/api/dicts/update"
    /// Server's end point for creating share
    public static let AddShare = URLPrefix + "/api/dict_share/add_share"
    
    public static let confirmAccount = URLPrefix + "/api/auth/verify"
    /// Server's end point for getting share
    public static func getShare(shareUUID: String) -> String {
        return URLPrefix + "/api/dict_share/get_share/\(shareUUID)"
    }
    
    public static func resendConfirmationEmail(email: String) -> String {
        return URLPrefix + "/api/auth/resend_conf_email/\(email)"
    }
}
