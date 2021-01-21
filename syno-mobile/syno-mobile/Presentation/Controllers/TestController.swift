import Foundation
import UIKit

/// Controller where user takes tests
class TestViewController: UIViewController, IScrollableToPoint {
    /// Last focused point to adjust view when keyboard is shown
    private var lastFocusedPoint: CGPoint?
    
    /// Assembly for creating view controllers
    private var presAssembly: IPresentationAssembly
    
    /// Shown card number
    private var currCardNumber: Int = 0
    
    func scrollToPoint(point: CGPoint, sender: UIView?) {
        lastFocusedPoint = sender?.convert(point, to: self.view)
    }
    
    func scrollToTop() {
        scrollToTop(self.scrollView, animated: true)
    }
    
    func scrollToTop(_ scrollView: UIScrollView, animated: Bool = true) {
        self.scrollView.contentInset.bottom = 0
        if #available(iOS 11.0, *) {
            let expandedBar = (navigationController?.navigationBar.frame.height ?? 64.0 > 44.0)
            let largeTitles = (navigationController?.navigationBar.prefersLargeTitles) ?? false
            let offset: CGFloat = (largeTitles && !expandedBar) ? 52: 0
            scrollView.setContentOffset(CGPoint(x: 0, y: -(scrollView.adjustedContentInset.top + offset)), animated: animated)
        } else {
            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: animated)
        }
    }
    /// `ITestView` for each card in dictionary
    private var testViews: [ITestView]
    
    /// Gets current `ITestView`
    var contentView: ITestView {
        get {
            testViews[currCardNumber].parentController = self
            return testViews[currCardNumber]
        }
    }
    
    /// Main scroll view with all views inside
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = true
        
        scrollView.addSubview(self.contentView)
        
        self.contentView.anchor(top: scrollView.contentLayoutGuide.topAnchor, left: nil, bottom: scrollView.contentLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30).isActive = true
        
        return scrollView
    }()
    
    /**
      Creates new `TestViewController`
     - Parameter testViews: `ITestView` for each card in dictionary
     - Parameter dictName: Dictionary name
     - Parameter presAssembly: assembly to create view controllers
     */
    init(testViews: [ITestView], dictName: String, presAssembly: IPresentationAssembly) {
        self.testViews = testViews
        self.presAssembly = presAssembly
        super.init(nibName: nil, bundle: nil)
        
        self.navigationItem.title = dictName
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закончить", style: .done, target: self, action: #selector(endTest))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancelTest))
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    /// Cancel button click listener
    @objc func cancelTest() {
        Logger.log("cancelled test")
        
        self.testViews[currCardNumber].model.cancelTest {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    /// End test button click listener
    @objc func endTest() {
        Logger.log("Test ended")
        self.testViews[currCardNumber].model.endTest { (test) in
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Успех", message: "Тест окончен!", preferredStyle: .alert)
                alertController.addAction(.okAction)
                self.present(alertController, animated: true, completion: {
                    Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false, block: { (tm) in
                        alertController.dismiss(animated: true, completion: {
                            self.navigationController?.pushViewController(self.presAssembly
                            .testResultsController(sourceTest: test), animated: true)
                        })
                    })
                })
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// `UISwipeGestureRecognizer` handlers
    @objc
    func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        var success = false
        let pt = sender.location(in: self.contentView.tableView)
        
        if self.contentView.tableView.bounds.contains(pt) {
            return
        }
        
        var nextView: ITestView?
        let currentCardNumber = self.currCardNumber
        let currContentView = contentView
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            switch sender.direction {
            case .left:
                if (self.currCardNumber < self.testViews.count - 1) {
                    success = true
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.testViews[self.currCardNumber + 1]
                        self.scrollView.addSubview(nextView!)
                        nextView!.parentController = self
                        nextView!.translatesAutoresizingMaskIntoConstraints = false
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
                        
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.currCardNumber += 1
                }
                break
            case .right:
                Logger.log("Right Swipe")
                if self.currCardNumber > 0 {
                    success = true
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.testViews[self.currCardNumber - 1]
                        nextView!.translatesAutoresizingMaskIntoConstraints = false
                        nextView!.parentController = self
                        self.scrollView.addSubview(nextView!)
                        
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.currCardNumber -= 1
                }
                break
            default:
                break
            }
        }) { (_) in
           if (success) {
                Logger.log("\(self.currCardNumber) \(currentCardNumber)")
                if (currentCardNumber != self.currCardNumber) {
                currContentView.removeFromSuperview()
                    if let nextView = nextView, self.scrollView.subviews.contains(nextView) {
                        nextView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
                        nextView.makeFirstTextFieldResponder()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .yellow
        self.view.addSubview(scrollView)
        
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer.direction = .left
        recognizer.delegate = self

        let recognizer1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer1.direction = .right
        recognizer1.delegate = self
        
        self.scrollView.addGestureRecognizer(recognizer)
        self.scrollView.addGestureRecognizer(recognizer1)
        
        let allViewTapGestureReco = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(allViewTapGestureReco)
        allViewTapGestureReco.cancelsTouchesInView = false
        
        self.addKeyboardObservers(showSelector: #selector(showKeyboard(notification:)), hideSelector: #selector(hideKeyboard(notification:)))
        
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        contentView.makeFirstTextFieldResponder()
    }
}

extension TestViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TestViewController {
    /**
    Keyboard showing listener
    - Parameter notification: contains inner data about notification
    */
    @objc func showKeyboard(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            Logger.log("lastPoint: \(lastFocusedPoint?.y)")
            Logger.log("keyboard height:\(keyboardHeight)")
            
            if let lastFocusedPoint = lastFocusedPoint {
                let neededShift = UIScreen.main.bounds.height - lastFocusedPoint.y - keyboardHeight
                Logger.log("neededShift: \(neededShift)")
                Logger.log("currOffset: \(scrollView.contentOffset.y)")
                if (neededShift < 0) {
                    self.scrollView.contentInset.bottom += -neededShift
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - neededShift), animated: true)
                }
            }
        }
    }
    
    /**
    Keyboard hiding listener
    - Parameter notification: contains inner data about notification
    */
    @objc func hideKeyboard(notification: NSNotification) {
        Logger.log("Hide")
    }
    
    /// Tap gesture recignizer handler: ends editing in whole view
    @objc func clearKeyboard() {
        view.endEditing(true)
    }
}
