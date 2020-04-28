import Foundation
import UIKit

/// Protocol defines data needed for `TestResultsTableViewCell`
protocol ITestResultsTableViewCellConfiguration {
    /// Current translation
    var translation: String? { get }
    /// Cells background color
    var backgroundColor: UIColor { get }
}

class TestResultsTableViewCellConfiguration: ITestResultsTableViewCellConfiguration {
    var translation: String?
    
    var backgroundColor: UIColor
    
    /**
     Creates new `TestResultsTableViewCellConfiguration`
     - Parameter translation: Current translation
     - Parameter backgroundColor:Cells background color
     */
    init(translation: String?, backgroundColor: UIColor) {
        self.translation = translation
        self.backgroundColor = backgroundColor
    }
}

/// Protocol for updating `TestResultsTableViewCell`
protocol IConfigurableTestResultsTableViewCell {
    /// Updates cell's state
    func configure(config: ITestResultsTableViewCellConfiguration)
}

/// TableView cell for displaying user's result on current translation
class TestResultsTableViewCell: UITableViewCell, IConfigurableTestResultsTableViewCell {
    static let cellId = "TestResultsTableViewCellId"

    override func prepareForReuse() {
        self.baseShadowView.shadowView.backgroundColor = .clear
    }
    
    func configure(config: ITestResultsTableViewCellConfiguration) {
        self.translationLabel.text = config.translation
        self.baseShadowView.shadowView.backgroundColor = config.backgroundColor
    }
    
    /// Label for displaying current translation
    lazy var translationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()
    
    /// Main view
    lazy var baseShadowView: BaseShadowView = {
        let view = BaseShadowView()
        view.cornerRadius = 20
        view.shadowView.shadowOffset = CGSize(width: 0, height: 4)
        view.bringSubviewToFront(view.shadowView)
        view.addSubview(self.translationLabel)
        self.translationLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 15, paddingRight: 15, width: 0, height: 0)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.contentView.addSubview(baseShadowView)
        baseShadowView.anchor(top: self.contentView.topAnchor, left: nil, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        self.baseShadowView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.93).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
