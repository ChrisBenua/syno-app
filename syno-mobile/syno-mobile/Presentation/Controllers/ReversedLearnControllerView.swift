import Foundation
import UIKit


class ReversedLearnCollectionViewController: UIViewController {
    /// Learn view for each card
  private var reversedLearnView: [ReversedLearnView]
  
  private var model: IReversedLearnControllerModel
  
  /// Gesture recognizer for right swiping
  private var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
  
  /// Gesture recognizer for left swiping
  private var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
  
  /// Current card number
  private var currCardNumber: Int = 0
      
  /// LearnView for `currCardNumber`
  var contentView: ReversedLearnView {
    get {
      return reversedLearnView[currCardNumber]
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
  
  /// SwipeGestureRecognizer handler
  @objc func handleSwipes(_ sender: UISwipeGestureRecognizer) {
    var nextView: ReversedLearnView?
    var success: Bool = false
    let contentView = self.contentView
    let currentCardNumber = self.currCardNumber
    let currContentView = contentView
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
      switch sender.direction {
      case .left:
        Logger.log("Left Swipe")
      if self.currCardNumber < self.model.getCardsCount() - 1 {
          success = true
          self.contentView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
          UIView.performWithoutAnimation {
            nextView = self.reversedLearnView[self.currCardNumber + 1]
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
            nextView = self.reversedLearnView[self.currCardNumber - 1]
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
    
    self.view.backgroundColor = .white
    
    self.view.addSubview(scrollView)
    scrollView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: UIScreen.main.bounds.width, height: 0)
    self.navigationItem.title = self.model.getDictionaryName()
    self.navigationItem.setHidesBackButton(true, animated:true)
  }
  
  /**
   Creates new `LearnCollectionViewController`
   - Parameter data: data for controller to check actions
   - Parameter learnViews: LearnView for each card in dictionary
   */
  init(model: IReversedLearnControllerModel, learnViews: [ReversedLearnView]) {
    self.model = model
    self.reversedLearnView = learnViews
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ReversedLearnCollectionViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.x = 0
  }
}


extension ReversedLearnCollectionViewController: UIGestureRecognizerDelegate {
func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
