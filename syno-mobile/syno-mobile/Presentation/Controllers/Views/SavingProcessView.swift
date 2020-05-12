import Foundation
import UIKit

/// Wrapper-view for process indicating
class SavingProcessView: UIView {
    /// removes view
    func dismissSavingProcessView() {
        self.activityIndicator.stopAnimating()
        self.removeFromSuperview()
    }
    
    /**
     Shows this view in the center of `sourceView`
     - Parameter sourceView: In which controller view should be shown
     */
    func showSavingProcessView(sourceView: UIViewController) {
        sourceView.view.addSubview(self)
        self.activityIndicator.startAnimating()
        self.centerYAnchor.constraint(equalTo: sourceView.view.centerYAnchor).isActive = true
        self.centerXAnchor.constraint(equalTo: sourceView.view.centerXAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
    }
    
    /// Label with text above activity indicator
    let savingLabel: UILabel = {
        let label = UILabel()
        label.text = "Saving..."
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /**
     Sets test of `savingLabel`
     - Parameter text: text to be placed in `savingLabel`
     */
    func setText(text: String) {
        savingLabel.text = text
    }
    
    /// Animated activity indicator
    lazy var activityIndicator = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray
        self.alpha = 0.7
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.addSubview(activityIndicator)
        self.addSubview(savingLabel)
        
        savingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        savingLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
                
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
