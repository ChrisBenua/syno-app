import UIKit
import AVFoundation

/// Protocol for `LoginModel` event handling
protocol ILoginReactor {
    /// Notify view that we send lign request
    func onStartedProcessingLogin()

    /// Notify view on successfull login
    func onSuccessfulLogin(email: String)

    /// Notify view on failure login attempt
    func onFailedLogin()
}

/// Controller for performing Login
class LoginViewController: UIViewController, ILoginReactor {
    /// instance with inner logic connected with `LoginViewController`
    private var loginModel: ILoginModel
    
    /// Layouts elements on view
    private var layouter: ILoginLayouter = LoginRegistrationLayouter()
    
    /// Instance for creating other Controllers
    private var presAssembly: IPresentationAssembly
    
    /**
     Create new `LoginViewController` with
     - Parameter presAssembly: `IPresentationAssembly` for creating other Controllers
     - Parameter loginModel: `ILoginModel` for handling inner logic
     - Parameter registrationViewController: `UIViewController` to present on button click
     */
    init(presAssembly: IPresentationAssembly, loginModel: ILoginModel) {
        self.presAssembly = presAssembly
        self.loginModel = loginModel
        super.init(nibName: nil, bundle: nil)
        self.loginModel.controller = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Processing view to show while performing login
    lazy var processingSaveView: SavingProcessView = {
        let view = SavingProcessView()
        view.setText(text: "Вход..")
        
        return view
    }()

    /// `registrationLabel` click listener
    @objc func registrationLabelClicked() {
        (self.layouter.alternateAuthButton() as? UILabel)?.flash(duration: 0.3)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.35) {
            self.present(self.presAssembly.registerViewController(), animated: true, completion: nil)
        }
    }
    
    ///  `submitButton` click listener
    @objc func submitLoginCredentials() {
        self.layouter.submitButton().flash(toValue: 0.4, duration: 0.25)
        self.loginModel.login(loginState: LoginState(email: layouter.emailTextField().text ?? "", password: layouter.passwordTextField().text ?? ""))
    }
    
    /// Called when model started processing login request, presents `processingSaveView`
    func onStartedProcessingLogin() {
        Logger.log(#function)
        self.layouter.submitButton().isEnabled = false
        
        self.processingSaveView.showSavingProcessView(sourceView: self)
    }

    /// Called when model performed login request successfully, dismisses `processingSaveView`
    func onSuccessfulLogin(email: String) {
        Logger.log(#function)
        self.layouter.submitButton().isEnabled = true
        
        self.processingSaveView.dismissSavingProcessView()

        let alert = UIAlertController.okAlertController(title: "Добро пожаловать, \(email)!")
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 1.2

        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            alert.dismiss(animated: true, completion: {
                self.afterSuccessfullLogin()
            })
        })
    }
    
    /// Dismisses current controller and replaces main window controller with `mainTabBarController`
    func afterSuccessfullLogin() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window!.rootViewController = presAssembly.mainTabBarController()
    }

    /// Called when model failed to login user, dismisses `processingSaveView` and present `alertController` with error
    func onFailedLogin() {
        Logger.log(#function)
        
        self.processingSaveView.dismissSavingProcessView()
        
        self.present(UIAlertController.okAlertController(title: "Ошибка", message: "Вход не удался"), animated: true, completion: nil)

        self.layouter.submitButton().isEnabled = true
        self.layouter.passwordTextField().text = ""
    }

    /// Skip Registration button onclick listener
    @objc func skipRegistration() {
        (self.layouter.skipRegistrationButton() as? UILabel)?.flash(duration: 0.3)
        self.loginModel.skippedRegistration()
    }
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        
        layouter.submitButton().addTarget(self, action: #selector(submitLoginCredentials), for: .touchUpInside)
        layouter.alternateAuthButton().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registrationLabelClicked)))
        layouter.skipRegistrationButton().addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skipRegistration)))
        
        let resendGR = UITapGestureRecognizer(target: self, action: #selector(handleResendEmail))
        self.layouter.resendConfirmationView().isUserInteractionEnabled = true
        self.layouter.resendConfirmationView().addGestureRecognizer(resendGR)
    
        self.view.backgroundColor = .white;
        
        let allScreenStackView = self.layouter.allStackView()
        self.view.addSubview(allScreenStackView)

        allScreenStackView.anchor(top: self.view.topAnchor, left: nil, bottom: self.view.bottomAnchor, right: nil,
                paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)

        allScreenStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        allScreenStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true

        super.viewDidLoad()
    }
    
    @objc func handleResendEmail() {
        self.present(presAssembly.emailForConfirmationController(), animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Logger.log("Bounds: \(self.layouter.emailTextField().bounds)")
        Logger.log("\(self.view.bounds)")
    }
}


extension LoginViewController {

    /// Shifts view up when keyboard is shown
    @objc func showKeyboard(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {

            let loginButton = self.layouter.submitButton()
            
            let focusedViewOrigin = loginButton.superview!.convert(loginButton.frame.origin, to: self.view)
            
            if keyboardHeight > self.view.frame.height - focusedViewOrigin.y {
                self.view.frame.origin.y = -(keyboardHeight - (self.view.frame.height - focusedViewOrigin.y - loginButton.frame.height))
            }
        }
    }
    
    /// Shifts view back when keyboard is hidden
    @objc func hideKeyboard(notification: NSNotification) {
        Logger.log("Hide")
        self.view.frame.origin.y = 0
    }
    
    /// Ends editing all view inside root view
    @objc func clearKeyboard() {
        view.endEditing(true)
    }
}
