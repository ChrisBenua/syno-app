import Foundation
import UIKit

/// Protocol for data passed to `LearnCollectionViewController` table view
protocol ILearnViewControllerData {
    /// Number of cards in dictionary
    var cardsAmount: Int { get }
    /// Name of dictionary
    var dictName: String? { get }
}

class LearnViewControllerData: ILearnViewControllerData {
    var cardsAmount: Int
    
    var dictName: String?
    
    /**
     Creates new `LearnViewControllerData`
     - Parameter cardsAmount: Number of cards in dictionary
     - Parameter dictName: Name of dictionary
     */
    init(cardsAmount: Int, dictName: String?) {
        self.cardsAmount = cardsAmount
        self.dictName = dictName
    }
}

class LearnCollectionViewController: UIViewController {
    /// Data for learn view controller header
    private var data: ILearnViewControllerData
    
    /// Learn view for each card
    private var learnViews: [ILearnView]
    
    /// Gesture recognizer for right swiping
    private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    /// Gesture recognizer for left swiping
    private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
    
    /// Current card number
    private var currCardNumber: Int = 0
        
    /// LearnView for `currCardNumber`
    var contentView: ILearnView {
        get {
            return learnViews[currCardNumber]
        }
    }
    
    /// Main scroll view with all view inside
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(self.contentView)
        
        self.contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        self.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -30).isActive = true
        
        return scrollView
    }()
    
    /// End button click listener
    @objc func endLearn() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func editCard() {
        learnViews[currCardNumber].editAssociatedCard()
    }
    
    /// SwipeGestureRecognizer handler
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
        var nextView: ILearnView?
        var success: Bool = false
        let contentView = self.contentView
        let currentCardNumber = self.currCardNumber
        let currContentView = contentView
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            switch sender.direction {
            case .left:
                Logger.log("Left Swipe")
                if self.currCardNumber < self.data.cardsAmount - 1 {
                    success = true
                    self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.learnViews[self.currCardNumber + 1]
                        self.scrollView.addSubview(nextView!)
                        nextView!.translatesAutoresizingMaskIntoConstraints = false
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
                        
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.currCardNumber += 1
                }
            case .right:
                Logger.log("Right Swipe")
                if self.currCardNumber > 0 {
                    success = true
                    self.contentView.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                    UIView.performWithoutAnimation {
                        nextView = self.learnViews[self.currCardNumber - 1]
                        nextView!.translatesAutoresizingMaskIntoConstraints = false

                        self.scrollView.addSubview(nextView!)
                        
                        nextView!.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
                        nextView!.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor).isActive = true
                        nextView!.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, constant: -30).isActive = true
                        
                        nextView?.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
                    }
                    nextView?.transform = CGAffineTransform(translationX: 0, y: 0)
                    self.currCardNumber -= 1
                }
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
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer.direction = .left
        recognizer.delegate = self

        let recognizer1 = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        recognizer1.direction = .right
        recognizer1.delegate = self
        
        self.scrollView.addGestureRecognizer(recognizer)
        self.scrollView.addGestureRecognizer(recognizer1)

        
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Закончить", style: .done, target: self, action: #selector(endLearn))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Редактировать", style: .done, target: self, action: #selector(editCard))
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(scrollView)
        scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
        self.navigationItem.title = self.data.dictName
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.contentView.refreshData()
    }
    
    /**
     Creates new `LearnCollectionViewController`
     - Parameter data: data for controller to check actions
     - Parameter learnViews: LearnView for each card in dictionary
     */
    init(data: ILearnViewControllerData, learnViews: [ILearnView]) {
        self.data = data
        self.learnViews = learnViews
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LearnCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}


extension LearnCollectionViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let view = otherGestureRecognizer.view as? UIScrollView {
            if let superView = view.superview as? UIScrollableTextField {
                return false
            }
        }
        return true
    }
}
