import Foundation

protocol IAddShareModel {
    func addShare(text: String)
    
    var delegate: IAddShareModelDelegate? { get set }
}

protocol IAddShareModelDelegate: class {
    func showProcessView()
    
    func showCompletionView(title: String, text: String)
}

class AddShareModel: IAddShareModel {
    
    private let shareService: IDictShareService
    
    weak var delegate: IAddShareModelDelegate?
    
    func addShare(text: String) {
        self.delegate?.showProcessView()
        self.shareService.getShare(shareUUID: text) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let str):
                    self.delegate?.showCompletionView(title: "Успех!", text: str)
                case .error(let err):
                    self.delegate?.showCompletionView(title: "Ошибка!", text: err)
                }
            }
        }
    }
    
    init(shareService: IDictShareService) {
        self.shareService = shareService
    }
}

