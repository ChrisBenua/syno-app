import Foundation
import UIKit

/// Protocol defines data
protocol IRecentTestTableViewCellConfiguration {
    /// Dictionary name
    var dictName: String? { get }
    /// Dictionary last test grade
    var grade: String? { get }
}

class RecentTestTableViewCellConfiguration: IRecentTestTableViewCellConfiguration {
    var dictName: String?
    
    var grade: String?
    
    /**
     Creates new `RecentTestTableViewCellConfiguration`
     - Parameter dictName: Dictionary name
     - Parameter grade: Dictionary last test grade
     */
    init(dictName: String?, grade: String?) {
        self.dictName = dictName
        self.grade = grade
    }
}

/// Protocol for updating `RecentTestTableViewCell`
protocol IConfigurableRecentTestTableViewCell {
    /// updates `RecentTestTableViewCell` with data from config
    func configure(config: IRecentTestTableViewCellConfiguration)
}

/// TableView cell for displaying recent test
class RecentTestTableViewCell: UITableViewCell, IConfigurableRecentTestTableViewCell {
    /// Cell's reuse identifier
    public static let cellId = "RecentTestTableViewCellId"
    
    private var config: IRecentTestTableViewCellConfiguration!
    
    func configure(config: IRecentTestTableViewCellConfiguration) {
        self.config = config
        self.updateUI()
    }
    
    /// updates `dictNameLabel` and `gradeLabel`
    func updateUI() {
        self.dictNameLabel.attributedText = NSAttributedString(string: self.config.dictName ?? "", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.underlineColor: self.dictNameLabel.textColor!])
        self.gradeLabel.text = "Результат: " + (self.config.grade ?? "N/A")
    }
    
    /// Label for displaying dictionary name
    lazy var dictNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.3176470588, green: 0.431372549, blue: 0.5450980392, alpha: 1)
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        
        return label
    }()
    
    /// Label for displaying dictionary last test grade
    lazy var gradeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    /// Main view
    lazy var baseShadowView: BaseShadowView = {
        let view = BaseShadowView()
        view.cornerRadius = 10
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.containerViewBackgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        
        view.addSubview(gradeLabel)
        view.addSubview(dictNameLabel)
        
        self.gradeLabel.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 0, height: 0)
        self.gradeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.dictNameLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: self.gradeLabel.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 10, width: 0, height: 0)
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.contentView.addSubview(self.baseShadowView)
        self.baseShadowView.anchor(top: self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

