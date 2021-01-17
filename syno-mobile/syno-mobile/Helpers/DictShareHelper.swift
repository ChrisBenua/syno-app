//
//  DictShareHelper.swift
//  syno-mobile
//
//  Created by Christian Benua on 17.01.2021.
//  Copyright © 2021 Christian Benua. All rights reserved.
//

import Foundation
import UIKit

class DictShareHelper {
    static func showSharingResultView(controller: UIViewController, result: ShowSharingResultViewConfiguration) {
        switch result {
        case .success(let code, let dictName):
            let url = URL(string: "https://chrisbenua.site/share/\(code)")
            let activityController = UIActivityViewController(activityItems: ["Dictionary \"\(dictName)\"\n\n", url], applicationActivities: nil)
            activityController.completionWithItemsHandler = {
                (activityType: UIActivity.ActivityType?, success: Bool, params: [Any]?, erorr: Error?) in
                if activityType == UIActivity.ActivityType.copyToPasteboard && success {
                    let alertController = UIAlertController(title: nil, message: "Скопировано успешно!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                        alertController.dismiss(animated: true, completion: nil)
                    }))
                    controller.present(alertController, animated: true, completion: nil)
                }
            }
            controller.present(activityController, animated: true)
        case .failure(let alertTitle, let alertText):
            let alertController = UIAlertController(title: alertTitle, message: alertText, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}
