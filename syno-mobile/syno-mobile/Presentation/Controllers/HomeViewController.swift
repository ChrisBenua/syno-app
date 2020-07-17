import Foundation
import UIKit

/// Controller for main actions: create copy on server, download copy from server, login as different user
class HomeViewController: UIViewController, IHomeControllerDataProviderDelegate, IHomeControllerUserHeaderDelegate {
    func onSuccessGuestCopy() {
        let alert = UIAlertController.okAlertController(title: "Успех!")
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1.2

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true, completion: {
            })
        })
    }
    
    func onFailedGuestCopy() {
        let alert = UIAlertController.okAlertController(title: "Ошибка")
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1.2

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true, completion: {
            })
        })
    }
    
    func showController(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func onShowLogin() {
        self.dataProvider.onSignInAction()
    }
    
    func showProcessView(text: String) {
        processingSaveView.setText(text: text)
        processingSaveView.showSavingProcessView(sourceView: self)
    }
    
    func dismissProcessView() {
        processingSaveView.dismissSavingProcessView()
    }
    
    /// Process view for downloading or uploading dictionaries to server
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Загрузка..")
        
        return view
    }()
    
    /// Service responsible for inner logic of `HomeViewController`
    private var dataProvider: IHomeControllerMenuDataProvider
    
    /// View with login form info
    lazy var loginView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 10
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        let v = HomeControllerUserHeader(email: self.dataProvider.userEmail())
        v.delegate = self
        view.addSubview(v)
        v.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 0)
        
        return view
    }()
    
    /// Label for creating copy on server
    lazy var createCopyLabel: UILabel = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7))
        label.isUserInteractionEnabled = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.text = "Создать резервную копию"
        label.backgroundColor = .white
        
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCreateCopyLabelClick)))
        
        return label
    }()
    
    lazy var copyFromGuestLabel: UILabel = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7))
        label.isUserInteractionEnabled = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.text = "Копировать словари анонимного пользователя"
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .white
        
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCopyFromGuestLabelClick)))
        
        return label
    }()
    
    @objc func onCopyFromGuestLabelClick() {
        self.dataProvider.copyGuestDicts()
    }
    
    /// `createCopyLabel` click listener
    @objc func onCreateCopyLabelClick() {
        self.dataProvider.onUploadDataToServer()
    }
    
    /// Label for downloading copy from server
    lazy var downloadCopyLabel: UILabel = {
        let label = UILabelWithInsets(padding: UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7))
        label.isUserInteractionEnabled = true
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.text = "Загрузить резервную копию"
        label.backgroundColor = .white
        
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDownloadCopyLabelClick)))

        
        return label
    }()
    
    /// `downloadCopyLabel` click listener
    @objc func onDownloadCopyLabelClick() {
        self.dataProvider.onDownloadDataFromServer()
    }
    
    /// Wrapper-view with `createCopyLabel` and `downloadCopyLabel`
    lazy var actionsView: UIView = {
       let view = BaseShadowView()
        
        view.cornerRadius = 12
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        var views = [self.createCopyLabel, self.downloadCopyLabel]
        if (!self.dataProvider.isGuest()) {
            views.append(self.copyFromGuestLabel)
        }
        let sv = UIStackView(arrangedSubviews: views)
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 13
        
        view.addSubview(sv)
        
        sv.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 13, paddingBottom: 16, paddingRight: 13, width: 0, height: 0)
        
        return view
    }()
    
    /// Main view
    lazy var mainContainerView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1)
        
        view.addSubview(self.loginView)
        view.addSubview(self.actionsView)
        
        self.loginView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 13, paddingLeft: 13, paddingBottom: 0, paddingRight: 13, width: 0, height: 0)
        self.actionsView.anchor(top: self.loginView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 35, paddingLeft: 13, paddingBottom: 13, paddingRight: 13, width: 0, height: 0)
        
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        
        scrollView.addSubview(self.mainContainerView)
        
        self.mainContainerView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.mainContainerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.mainContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20).isActive = true
        
        return scrollView
    }()
    
    /**
     Creates new `HomeViewController`
     - Parameter dataProvider: service responsiblee for inner logic in `HomeViewController`
     */
    init(dataProvider: IHomeControllerMenuDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
        
        self.dataProvider.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9488552213, green: 0.9487094283, blue: 0.9693081975, alpha: 1)
        self.view.addSubview(scrollView)
        self.navigationItem.title = "Управление"
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

