import Foundation

struct RequestFactory {
    struct BackendRequests {
        static func login(loginDto: LoginDto) -> RequestConfig<DefaultParser<LoginResponseDto>> {
            return RequestConfig<DefaultParser<LoginResponseDto>>(request: LoginRequest(loginDto: loginDto), parser: DefaultParser())
        }
        
        static func register(registerDto: RegisterDto) -> RequestConfig<DefaultParser<MessageResponseDto>> {
            return RequestConfig<DefaultParser<MessageResponseDto>>(request: RegisterRequest(registerDto: registerDto), parser: DefaultParser())
        }
        
        static func allDictsRequest(userDefaultsManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<[GetDictionaryResponseDto]>> {
            return RequestConfig<DefaultParser<[GetDictionaryResponseDto]>>(request: AllDictsRequest(manager: userDefaultsManager), parser: DefaultParser())
        }
        
        static func updateDictsRequest(updateDictsDto: UpdateRequestDto, userDefManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<MessageResponseDto>> {
            return RequestConfig<DefaultParser<MessageResponseDto>>(request: UpdateDictRequest(updateRequestDto: updateDictsDto, userDefaultManager: userDefManager), parser: DefaultParser())
        }
        
        static func createShare(dto: NewDictShare, userDefManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<MessageResponseDto>> {
            return RequestConfig<DefaultParser<MessageResponseDto>>(request: AddShareRequest(dto: dto, userDefManager: userDefManager), parser: DefaultParser())
        }
        
        static func getShare(dto: GetShareRequestConfig, userDefManager: IUserDefaultsManager) -> RequestConfig<DefaultParser<GetDictionaryResponseDto>> {
            return RequestConfig<DefaultParser<GetDictionaryResponseDto>>(request: GetShareRequest(manager: userDefManager, getShareRequestConfig: dto), parser: DefaultParser())
        }
    }
}
