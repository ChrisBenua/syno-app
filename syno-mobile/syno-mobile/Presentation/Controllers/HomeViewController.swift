import Foundation
import UIKit

class HomeViewController: UIViewController, IHomeControllerDataProviderDelegate, IHomeControllerUserHeaderDelegate {
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
    
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Logging in..")
        
        return view
    }()
    
    private var dataProvider: IHomeControllerMenuDataProvider
    
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
    
    @objc func onCreateCopyLabelClick() {
        self.dataProvider.onUploadDataToServer()
    }
    
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
    
    @objc func onDownloadCopyLabelClick() {
        self.dataProvider.onDownloadDataFromServer()
    }
    
    lazy var actionsView: UIView = {
       let view = BaseShadowView()
        
        view.cornerRadius = 12
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        let sv = UIStackView(arrangedSubviews: [self.createCopyLabel, self.downloadCopyLabel])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 13
        
        view.addSubview(sv)
        
        sv.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 13, paddingBottom: 16, paddingRight: 13, width: 0, height: 0)
        
        return view
    }()
    
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

