import Foundation

/// Factory for creating `RequestConfig`
struct RequestFactory {
    /// Factory for creating `RequestConfig` for backend
    struct BackendRequests {
        /// Creates `RequestConfig` for login request with given dto
        static func login(loginDto: LoginDto) -> RequestConfig<DefaultParser<LoginResponseDto>> {
            return RequestConfig<DefaultParser<LoginResponseDto>>(request: LoginRequest(loginDto: loginDto), parser: DefaultParser())
        }
        /// Creates `RequestConfig` for register request with given dto
        static func register(registerDto: RegisterDto) -> RequestConfig<DefaultParser<MessageResponseDto>> {
            return RequestConfig<DefaultParser<MessageResponseDto>>(request: RegisterRequest(registerDto: registerDto), parser: DefaultParser())
        }
        /// Creates `RequestConfig` for fetching all dictionaries
        static func allDictsRequest(userDefaultsManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<[GetDictionaryResponseDto]>> {
            return RequestConfig<DefaultParser<[GetDictionaryResponseDto]>>(request: AllDictsRequest(manager: userDefaultsManager), parser: DefaultParser())
        }
        /// Creates `RequestConfig` for uploading dicts to server with given dto
        static func updateDictsRequest(updateDictsDto: UpdateRequestDto, userDefManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<MessageResponseDto>> {
            return RequestConfig<DefaultParser<MessageResponseDto>>(request: UpdateDictRequest(updateRequestDto: updateDictsDto, userDefaultManager: userDefManager), parser: DefaultParser())
        }
        /// Creates `RequestConfig` for creating share request with given dto
        static func createShare(dto: NewDictShare, userDefManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<MessageResponseDto>> {
            return RequestConfig<DefaultParser<MessageResponseDto>>(request: AddShareRequest(dto: dto, userDefManager: userDefManager), parser: DefaultParser())
        }
        
        /// Creates `RequestConfig` for getting share request with given dto
        static func getShare(dto: GetShareRequestConfig, userDefManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<GetDictionaryResponseDto>> {
            return RequestConfig<DefaultParser<GetDictionaryResponseDto>>(request: GetShareRequest(manager: userDefManager, getShareRequestConfig: dto), parser: DefaultParser())
        }
    }
}
