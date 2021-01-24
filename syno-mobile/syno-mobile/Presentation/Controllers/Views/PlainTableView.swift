import Foundation
import UIKit

class UITableViewReloadCompletion: UITableView {
    var reloadDataCompletionBlock: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()

        self.reloadDataCompletionBlock?()
        self.reloadDataCompletionBlock = nil
    }
    
    func reloadDataWithCompletion(completion: @escaping () -> Void) {
        reloadDataCompletionBlock = completion
        self.reloadData()
    }
}

/// TableView without scrolling
class PlainTableView: UITableView {
    var reloadDataCompletionBlock: (() -> Void)?

    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        } set (newValue) {
            super.contentOffset = CGPoint(x: 0, y: 0)
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height + contentInset.top + contentInset.bottom)
    }
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        super.deleteRows(at: indexPaths, with: animation)
        self.invalidateIntrinsicContentSize()
    }
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        super.insertRows(at: indexPaths, with: animation)
        self.invalidateIntrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.reloadDataCompletionBlock?()
        self.reloadDataCompletionBlock = nil
    }
    
    func reloadDataWithCompletion(completion: @escaping () -> Void) {
        reloadDataCompletionBlock = completion
        self.reloadData()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.isScrollEnabled = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
