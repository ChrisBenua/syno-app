import Foundation
import UIKit

/// Protocol for defining data for `TestResultsTableViewHeaderView`
protocol ITestResultsHeaderConfiguration {
    /// Card's translated word
    var translatedWord: String? { get }
    /// number of right answered in this card
    var rightAnswered: Int { get }
    /// number of translations in this card
    var allTranslations: Int { get }
    /// index of section in table view
    var section: Int { get }
    /// is current section expanded
    var isExpanded: Bool { get }
    /// should animate indicator rotation
    var shouldAnimate: Bool { get }
}

class TestResultsHeaderConfiguration: ITestResultsHeaderConfiguration {
    var translatedWord: String?
    
    var rightAnswered: Int
    
    var allTranslations: Int
    
    var section: Int
    
    var isExpanded: Bool
    
    var shouldAnimate: Bool
    
    /**
     Creates new `TestResultsHeaderConfiguration`
     - Parameter translatedWord: Card's translated word
     - Parameter rightAnswered: number of right answered in this card
     - Parameter allTranslations:number of translations in this card
     - Parameter section:index of section in table view
     - Parameter isExpanded:is current section expanded
     - Parameter shouldAnimate:should animate indicator rotation
     */
    init(translatedWord: String?, rightAnswered: Int, allTranslations: Int, section: Int, isExpanded: Bool, shouldAnimate: Bool) {
        self.translatedWord = translatedWord
        self.rightAnswered = rightAnswered
        self.allTranslations = allTranslations
        self.section = section
        self.isExpanded = isExpanded
        self.shouldAnimate = shouldAnimate
    }
}

/// Protocol for updating `TestResultsTableViewHeaderView`
protocol IConfigurableTestResultsHeader {
    func configure(config: ITestResultsHeaderConfiguration)
}

/// Protocol for handling `TestResultsTableViewHeaderView` events
protocol ITestResultsHeaderViewDelegate: class {
    /// Notifies when user collapses or expands section
    func didChangeExpandStateAt(section: Int)
}

/// Class for displaying section header in TestResultsController
class TestResultsTableViewHeaderView: UIView, IConfigurableTestResultsHeader {
            
    var config: ITestResultsHeaderConfiguration!
    
    weak var delegate: ITestResultsHeaderViewDelegate?
    
    func configure(config: ITestResultsHeaderConfiguration) {
        self.config = config
        
        updateUI()
    }
    
    /// Updates `translatedWordLabel`, `cardResultLabel`
    func updateUI() {
        self.translatedWordLabel.text = config.translatedWord
        self.cardResultLabel.text = "\(config.rightAnswered)/\(config.allTranslations)"
        self.cardResultLabel.textColor = GradeToStringAndColor.gradeToColor(gradePercentage: Double(config.rightAnswered) / Double(config.allTranslations) * 100)
    }
    
    /// Main container view
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        

        view.addSubview(self.translatedWordLabel)
        view.addSubview(self.cardResultLabel)
        view.addSubview(self.expandButton)
        
        self.translatedWordLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 20, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
        self.cardResultLabel.anchor(top: nil, left: self.translatedWordLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.expandButton.anchor(top: nil, left: self.cardResultLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        self.cardResultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.expandButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        return view
    }()
    
    /// Label for displaying current translated word
    lazy var translatedWordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    /// Label for displaying test results in current card
    lazy var cardResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    /// Button for expanding and collapsing current section
    lazy var expandButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        let image = #imageLiteral(resourceName: "Vector 30")
        
        button.setImage(image, for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 1e-7)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.baseShadowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandButtonClicked)))
        self.addSubview(self.baseShadowView)
        self.baseShadowView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UIView.animate(withDuration: 0.001, animations: {
            if Int(self.config.isExpanded ? 1 : 0) ^ Int(self.config.shouldAnimate ? 1 : 0) == 1 {
                self.expandButton.transform = .identity
            } else {
                self.expandButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 1e-7)
            }
        }) { (_) in
            if self.config.shouldAnimate {
                if !self.config.isExpanded {
                    UIView.animate(withDuration: 0.5) {
                        self.expandButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi - 1e-7)
                    }
                } else {
                    UIView.animate(withDuration: 0.5) {
                        self.expandButton.transform = .identity
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// `expandButton` click listener
    @objc func expandButtonClicked() {
        self.delegate?.didChangeExpandStateAt(section: self.config.section)
    }
}
