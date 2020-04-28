import Foundation
import UIKit

/// Protocol for defining `TestAndLearnControllerHeader` event handler
protocol ITestAndLearnHeaderDelegate: class {
    /// mode changed: from 'test' to 'learn' or vice versa
    func onSegmentChanged()
}

/// View for displaying mode of TestAndLearnController and recent user's tests
class TestAndLearnControllerHeader: UICollectionViewCell {
    static let headerId = "TestAndLearnControllerHeaderId"
    
    weak var delegate: ITestAndLearnHeaderDelegate?
    
    private let selectedSegmentTintColor = UIColor.init(red: 73.0/255, green: 116.0/255, blue: 171.0/255, alpha: 0.65)
    
    /// Segment control for selecting mode: 'learn' or 'test'
    lazy var segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Обучение", "Тест"])
                
        control.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .normal)
        control.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)], for: .selected)
        
        control.tintColor = UIColor.init(red: 239.0/255, green: 239.0/255, blue: 239.0/255, alpha: 1)
        if #available(iOS 13.0, *) {
            control.selectedSegmentTintColor = selectedSegmentTintColor
        } else {
            // Fallback on earlier versions
            control.updateColors(selectedColor: selectedSegmentTintColor)
        }
        control.addTarget(self, action: #selector(onSegmentChanged), for: .valueChanged)
        
        return control
    }()
    
    /// TableView for displaying user's recent tests
    lazy var tableView: UITableView = {
        let tableView = PlainTableView()
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        
        tableView.register(RecentTestTableViewCell.self, forCellReuseIdentifier: RecentTestTableViewCell.cellId)
        
        return tableView
    }()
    
    /// Segment control change listener: notifies `delegate`
    @objc func onSegmentChanged() {
        if #available(iOS 13.0, *) {
        } else {
            segmentControl.updateColors(selectedColor: selectedSegmentTintColor)
        }
        self.delegate?.onSegmentChanged()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = UIView()
        view.addSubview(segmentControl)
        let widthMult: CGFloat = 0.7
        self.segmentControl.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        self.contentView.addSubview(view)
        self.contentView.addSubview(self.tableView)
        view.anchor(top: self.contentView.topAnchor, left: nil, bottom: self.tableView.topAnchor, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 0)
        view.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: widthMult).isActive = true
        view.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        
        tableView.anchor(top: nil, left: self.contentView.leftAnchor, bottom: self.contentView.bottomAnchor, right: self.contentView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
