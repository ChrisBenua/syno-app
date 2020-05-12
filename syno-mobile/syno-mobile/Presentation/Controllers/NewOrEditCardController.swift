import Foundation
import UIKit

/// Controller for creating new card
class NewOrEditCardController: TranslationsCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(cancelButtonClicked))
    }
    
    /// Cancel button click listener
    @objc func cancelButtonClicked() {
        self.dataSource.deleteTempCard {
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
