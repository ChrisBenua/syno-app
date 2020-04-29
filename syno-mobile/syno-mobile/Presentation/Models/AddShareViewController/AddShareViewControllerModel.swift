import Foundation

/// Service protocol for getting share
protocol IAddShareModel {
    /**
     Gets share with given id
     - Parameter text: share id
     */
    func addShare(text: String)
    
    /// Delegate for event handling
    var delegate: IAddShareModelDelegate? { get set }
}

/// Protocol for `IAddShareModel` event handling
protocol IAddShareModelDelegate: class {
    /// Notifies when model started processing request
    func showProcessView()
    
    /// Notifies when model ended processing request
    func showCompletionView(title: String, text: String)
}

/// Service responsible for adding shares logic
class AddShareModel: IAddShareModel {
    /// Service for fetching shares
    private let shareService: IDictShareService
    
    /// event handler
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
    
    /**
     Creates new `AddShareModel`
     - Parameter shareService: service responsible for getting and creating shares
     */
    init(shareService: IDictShareService) {
        self.shareService = shareService
    }
}

