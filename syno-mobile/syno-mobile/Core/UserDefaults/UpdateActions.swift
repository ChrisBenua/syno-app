import Foundation

protocol IUpdateAction {
    var key: String { get }
    
    func isValid() -> Bool
    
    func execute()
}

protocol IUpdateActionsExecutor {
    func register(action: IUpdateAction)
    func performActions()
}

class UpdateActionsExecutor: IUpdateActionsExecutor {
    var actions: [IUpdateAction] = []
    private let prefix = "UpdateActionsExecutor"
    
    func register(action: IUpdateAction) {
        actions.append(action)
    }
    
    func performActions() {
        for action in actions {
            if action.isValid() && !UserDefaults.standard.bool(forKey: prefix + action.key) {
                UserDefaults.standard.setValue(true, forKey: prefix + action.key)
                action.execute()
            }
        }
    }
}
