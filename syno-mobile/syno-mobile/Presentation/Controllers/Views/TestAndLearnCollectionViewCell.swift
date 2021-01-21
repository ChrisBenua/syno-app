import Foundation
import UIKit

/// Protocol for defining data for `TestAndLearnCollectionViewCell`
protocol ITestAndLearnCellConfiguration {
    /// Name of dictionary
    var dictionaryName: String? { get }
    /// Dictionary's language
    var language: String? { get }
    /// Dictionary's last passed test grade
    var gradePercentage: Double { get }
}

class TestAndLearnCellConfiguration: ITestAndLearnCellConfiguration {
    var dictionaryName: String?
    
    var language: String?
    
    var gradePercentage: Double
    
    /**
     Creates new `TestAndLearnCellConfiguration`
     - Parameter dictionaryName: Name of dictionary
     - Parameter language: Dictionary's language
     - Parameter gradePercentage: Dictionary's last passed test grade
     */
    init(dictionaryName: String?, language: String?, gradePercentage: Double) {
        self.dictionaryName = dictionaryName
        self.language = language
        self.gradePercentage = gradePercentage
    }
}

/// Protocol for setting up data in `TestAndLearnCollectionViewCell`
protocol IConfigurableTestAndLearnCell {
    /// Setups cell data with `config`
    func setup(config: ITestAndLearnCellConfiguration)
}

class TestAndLearnCollectionViewCell: UICollectionViewCell, IConfigurableTestAndLearnCell {
    /// Cell's reuseIdentifier
    static let cellId = "TestAndLearnCollectionViewCellId"
    
    /// Last cell's configuration
    var config: ITestAndLearnCellConfiguration?
    
    private var gradeLabelConstrains: AnchoredConstraints = AnchoredConstraints()
    
    /// Wrapper view for `gradeLabel` and `languageLabel`
    lazy var gradeAndLanguageView: UIView = {
        let view = UIView()
        view.addSubview(self.gradeLabel)
        view.addSubview(self.languageLabel)
        
        self.gradeLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: -15, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        gradeLabelConstrains.vertical = self.gradeLabel.centerYAnchor.constraint(equalTo: languageLabel.centerYAnchor)
        gradeLabelConstrains.vertical?.isActive = true
        //self.gradeLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        self.languageLabel.anchor(top: view.topAnchor, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        return view
    }()
    
    /// Label for dictionary's last passed test grade
    let gradeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        
        return label
    }()
    
    /// Label for dictionary name
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .headerMainColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    /// Label for dictionary language
    let languageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .right
        
        return label
    }()
    
    /// Stack-view with all elements inside
    lazy var stackView: UIStackView = {
        let sepView = UIView();sepView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let stackView = UIStackView(arrangedSubviews: [self.nameLabel, sepView, self.gradeAndLanguageView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 5
                
        return stackView
    }()
    
    /// Main view
    lazy var baseShadowView: UIView = {
        let view = BaseShadowView()
        view.cornerRadius = 10
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.containerView.addSubview(self.stackView)
        self.stackView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 9, paddingLeft: 12, paddingBottom: 14, paddingRight: 12, width: 0, height: 0)
        
        return view
    }()
    
    /// Updates `gradeLabel`, `nameLabel` and `languageLabel`
    func updateUI() {
        self.gradeLabel.text = GradeToStringAndColor.gradeToStringAndColor(gradePercentage: self.config!.gradePercentage).0
        if self.config != nil {
            let result = GradeToStringAndColor.gradeToStringAndColor(gradePercentage: self.config!.gradePercentage)
            self.gradeLabel.textColor = result.1
            if !result.2 {
                self.configureConstraintsForEmptyResult()
            } else {
                self.configureConstraintsForSomeResult()
            }
        }
        self.nameLabel.text = self.config?.dictionaryName
        self.languageLabel.text = self.config?.language
    }
    
    func setup(config: ITestAndLearnCellConfiguration) {
        self.config = config
        updateUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(baseShadowView)
        self.configureInitialsConstraints()

        baseShadowView.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    private func configureConstraintsForEmptyResult() {
        self.gradeLabel.font = .systemFont(ofSize: 11, weight: .light)
        self.gradeLabel.textColor = .lightGray
        
        self.gradeLabelConstrains.trailing?.isActive = false
        self.gradeLabelConstrains.trailing? = self.gradeLabel.rightAnchor.constraint(equalTo: self.languageLabel.leftAnchor, constant: 4.5 * 2)
        self.gradeLabelConstrains.trailing?.isActive = true
        self.gradeLabelConstrains.vertical?.constant = 0.5
        self.layoutIfNeeded()
    }
    
    private func configureConstraintsForSomeResult() {
        self.gradeLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        self.gradeLabelConstrains.trailing?.isActive = false
        self.gradeLabelConstrains.trailing = self.gradeLabel.rightAnchor.constraint(equalTo: self.gradeAndLanguageView.rightAnchor, constant: 15)
        self.gradeLabelConstrains.trailing?.isActive = true
        self.gradeLabelConstrains.vertical?.constant = 0
        self.layoutIfNeeded()
    }
    
    private func configureInitialsConstraints() {
        self.gradeLabel.leftAnchor.constraint(equalTo: self.gradeAndLanguageView.leftAnchor, constant: -15).isActive = true
        self.gradeLabelConstrains.trailing = gradeLabel.rightAnchor.constraint(equalTo: self.gradeAndLanguageView.rightAnchor, constant: 15)
        self.gradeLabelConstrains.trailing?.isActive = true
    }
    
    /// Forbidden to init from storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
