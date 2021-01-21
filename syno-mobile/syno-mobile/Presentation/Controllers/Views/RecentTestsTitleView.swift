import Foundation
import UIKit

/// Protocol for `RecentTestsTitleView` event handling
protocol IRecentTestsTitleViewDelegate: class {
    func didChangeState(isExpanded: Bool)
}

/// View for displaying interacting with list of recent tests
class RecentTestsTitleView: UIView {
    /// is table view with list of recent tests expanded
    var isExpanded: Bool = false
    
    /// event handler
    weak var delegate: IRecentTestsTitleViewDelegate?
    
    /// main view
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(self.label)
        view.addSubview(self.expandButton)
        
        self.expandButton.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        self.expandButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: self.expandButton.leftAnchor, paddingTop: 7, paddingLeft: 15, paddingBottom: 7, paddingRight: 0, width: 0, height: 0)
        
        return view
    }()
    
    /// Title label
    lazy var label: UILabel = {
        let l = UILabel()
        l.text = "Недавние тесты"
        l.font = .systemFont(ofSize: 19)
        l.textAlignment = .center
        
        return l
    }()
    
    /// Button for expanding and collapsing tableView with recent tests
    lazy var expandButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let image = #imageLiteral(resourceName: "Vector 30")
        button.isUserInteractionEnabled = false
        
        button.setImage(image, for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        //button.addTarget(self, action: #selector(expandButtonClicked), for: .touchUpInside)
        if !self.isExpanded {
            button.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 1e-7).scaledBy(x: 0.8, y: 0.8)
        } else {
            button.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        }
        
        return button
    }()
    
    /**
     Creates new `RecentTestsTitleView`:
     - Parameter isExpanded: is tableView with recent tests expanded
     */
    init(isExpanded: Bool) {
        super.init(frame: .zero)
        self.isExpanded = isExpanded
        Logger.log("New title View")
        
        self.addSubview(baseShadowView)
        baseShadowView.anchor(top: self.topAnchor, left: nil, bottom: self.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        baseShadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        baseShadowView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7).isActive = true
        
        self.baseShadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didExpandOrCollapse)))
    }

    /// `expandButton` click listener
    @objc func didExpandOrCollapse() {
        self.isExpanded.toggle()
        
        UIView.animate(withDuration: 0.5) {
            if self.isExpanded {
                self.expandButton.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
            } else {
                self.expandButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 1e-7).scaledBy(x: 0.8, y: 0.8)
            }
        }
        Logger.log("isExpanded: \(self.isExpanded)")
        delegate?.didChangeState(isExpanded: self.isExpanded)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

