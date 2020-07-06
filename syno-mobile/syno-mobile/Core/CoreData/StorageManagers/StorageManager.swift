import Foundation
import CoreData

/// Protocol for creating/getting info about `DbAppUser`
protocol IAppUserStorageManager {
    /// Gets active `DbAppUser`
    func getCurrentAppUser() -> DbAppUser?
    
    /// Gets active `DbAppUser` 's email
    func getCurrentUserEmail() -> String?
    
    /**
     Creates new `DbAppUser`
     - Parameter email: new user's email
     - Parameter password: new user's password
     - Parameter isCurrent: If this user is currently active
     */
    func createAppUser(email: String, password: String, isCurrent: Bool) -> DbAppUser?
    
    /// Marks given user as active and marks all other as non-active
    func markAppUserAsCurrent(user: DbAppUser)
}

/// Protocol for creating new `DbUserDictionary`
protocol IUserDictionaryStorageManager {
    /// Creates new `DbUserDictionary`
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?,language: String?, serverId: Int64?, cards: [DbUserCard]?, pin: String?, completion: ((DbUserDictionary?) -> Void)?)
}

/// Protocol for creating new `DbUserCard`
protocol IUserCardsStorageManager {
    /// Creates new `DbUserCard`
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?, pin: String?, completion: ((DbUserCard?) -> Void)?)
}

protocol ITranslationsStorageManager {
    /// Creates new `DbTranslation`
    func createTranslation(sourceCard: DbUserCard?, usageSample: String, translation: String, transcription: String, comment: String, serverId: Int64?, timeCreated: Date?, timeModified: Date?, pin: String?, completion: ((DbTranslation?) -> Void)?)
}

/// Protocol for service with all needed logic
protocol IStorageCoordinator: IAppUserStorageManager, IUserDictionaryStorageManager, IUserCardsStorageManager, ITranslationsStorageManager {
    /// Service responsible for storing `NSManagedObjectContext`, `NSManagedObjectModel` and `NSPersistentStoreCoordinator`
    var stack: ICoreDataStack { get }
    
    /// Performes save in given `NSManagedObjectContext`
    func performSave(in context: NSManagedObjectContext)
    
    /// Performes save in given `NSManagedObjectContext`
    func performSave(in context: NSManagedObjectContext, completion: (() -> Void)?)
}

class StorageManager: IStorageCoordinator {
    func getCurrentUserEmail() -> String? {
        return self.userManager.getCurrentUserEmail()
    }
    
    func getCurrentAppUser() -> DbAppUser? {
        return self.userManager.getCurrentAppUser()
    }
    
    func performSave(in context: NSManagedObjectContext) {
        DispatchQueue.global(qos: .background).async {
            self.stack.performSave(with: context, completion: nil)
        }
    }
    
    func performSave(in context: NSManagedObjectContext, completion: (() -> Void)?) {
        DispatchQueue.global(qos: .background).async {
            self.stack.performSave(with: context, completion: completion)
        }
    }
    
    func createAppUser(email: String, password: String, isCurrent: Bool) -> DbAppUser? {
        self.userManager.createAppUser(email: email, password: password, isCurrent: isCurrent)
    }
    
    func markAppUserAsCurrent(user: DbAppUser) {
        self.userManager.markAppUserAsCurrent(user: user)
    }
    
    func createUserDictionary(owner: DbAppUser, name: String, timeCreated: Date?, timeModified: Date?, language: String?, serverId: Int64?, cards: [DbUserCard]?, pin: String?, completion: ((DbUserDictionary?) -> Void)?) {
        self.dictManager.createUserDictionary(owner: owner, name: name, timeCreated: timeCreated, timeModified: timeModified, language: language, serverId: serverId, cards: cards, pin: pin, completion: completion)
    }
    
    func createUserCard(sourceDict: DbUserDictionary?, translatedWord: String, timeCreated: Date?, timeModified: Date?, serverId: Int64?, translation: [DbTranslation]?, pin: String?, completion: ((DbUserCard?) -> Void)?) {
        self.cardsManager.createUserCard(sourceDict: sourceDict, translatedWord: translatedWord, timeCreated: timeCreated, timeModified: timeModified, serverId: serverId, translation: translation, pin: pin, completion: completion)
    }
    
    func createTranslation(sourceCard: DbUserCard?, usageSample: String, translation: String, transcription: String, comment: String, serverId: Int64?, timeCreated: Date?, timeModified: Date?, pin: String?, completion: ((DbTranslation?) -> Void)?) {
        self.transManager.createTranslation(sourceCard: sourceCard, usageSample: usageSample, translation: translation, transcription: transcription, comment: comment, serverId: serverId, timeCreated: timeCreated, timeModified: timeModified, pin: pin, completion: completion)
    }
    
    /// Stores read-only `ICoreDataStack` instance
    private var privateStack: ICoreDataStack

    public var stack: ICoreDataStack {
        get {
            return privateStack
        }
    }

    /// Service for delegating `IAppUserStorageManager` functions
    private var userManager: IAppUserStorageManager
    
    /// Service for delegating `IUserDictionaryStorageManager` functions
    private var dictManager: IUserDictionaryStorageManager
    
    /// Service for delegating `IUserCardsStorageManager` functions
    private var cardsManager: IUserCardsStorageManager
    
    /// Service for delegating `ITranslationsStorageManager` functions
    private var transManager: ITranslationsStorageManager
    
    init() {
        self.privateStack = CoreDataStack()
        self.userManager = AppUserStorageManager(stack: self.privateStack)
        self.dictManager = UserDictionaryStorageManager(stack: self.privateStack)
        self.cardsManager = UserCardStorageManager(stack: self.privateStack)
        self.transManager = UserTranslationStorageManager(stack: self.privateStack)
    }
}
