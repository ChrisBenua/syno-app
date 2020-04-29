import Foundation
import UIKit

/// Controller for adding shared dictionary
class AddShareViewController: UIViewController, IAddShareModelDelegate, IGetDictShareDelegate {
    func didSubmitText(text: String) {
        self.shareModel.addShare(text: text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    /// Process view for indicating sharing process
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Sharing...")
        
        return view
    }()
    
    func showProcessView() {
        processingSaveView.showSavingProcessView(sourceView: self)
    }
    
    func showCompletionView(title: String, text: String) {
        processingSaveView.dismissSavingProcessView()
        
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            alertController.dismiss(animated: true, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Service responsible for inner logic in `AddShareViewController`
    private var shareModel: IAddShareModel
    
    /// Main view for sharing
    lazy var shareView: GetDictShareView = {
        let shareView = GetDictShareView()
        shareView.delegate = self
        
        return shareView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.shareView)
        
        self.navigationItem.title = "Новый словарь"
        
        self.view.backgroundColor = .white
        self.shareView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
    }
    
    /**
     Creates new `AddShareViewController`
     - Parameter shareModel: service responsible for inner logic `AddShareViewController`
     */
    init(shareModel: IAddShareModel) {
        self.shareModel = shareModel
        super.init(nibName: nil, bundle: nil)
        self.shareModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
