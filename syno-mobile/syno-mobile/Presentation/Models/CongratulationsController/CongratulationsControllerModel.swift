import Foundation

struct CongratulationsControllerData {
    let messages: [SmallMessages]
    
    struct SmallMessages {
        var message: String
        var fontSize: Float
        var additionalDelayAfterAnimation: Float = 0.8
    }
}

protocol ICongratulationsControllerModel {
    func getCongratulations() -> CongratulationsControllerData
}

class CongratulationsControllerModelImpl: ICongratulationsControllerModel {
    func getCongratulations() -> CongratulationsControllerData {
        return CongratulationsControllerData(
            messages: [
                CongratulationsControllerData.SmallMessages(message: "С Новым Годом!!!🎉🎉🎉", fontSize: 28),
                CongratulationsControllerData.SmallMessages(message: "А это поздравление", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Для лучшей девочки на свете!", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Ты самая родная,", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Самая-самая нежная,", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Самая милая,", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Самая-самая понимающая,", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Самая чувственная,", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Самая интересная,", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Самая-самая любимая!", fontSize: 24),
                CongratulationsControllerData.SmallMessages(message: "Люблю тебя сильно-сильно!", fontSize: 24, additionalDelayAfterAnimation: 2)
            ])
    }
    
    
}

