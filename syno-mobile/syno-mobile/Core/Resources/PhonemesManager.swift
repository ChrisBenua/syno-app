import Foundation

/// Service Protocol generating transcriptions
protocol IPhonemesManager {
    /// Asks for initialization
    func initialize()
    
    /// Gets transcription for given `word`
    func getPhoneme(for word: String) -> String?
}

class PhonemesManager: IPhonemesManager {
    /// Checks if `initialize` was called
    private var isInitialized: Bool {
        get {
            dict.count > 0
        }
    }
    /// Stores transcriptions
    private var dict: [String: String] = [:]
    /// Synchronization trick not to access not fully initialized dictionary
    private var dispatchGroup = DispatchGroup()
    
    func initialize() {
        if (!isInitialized) {
            self.dispatchGroup.enter()
            Logger.log("started initializing dict")
            DispatchQueue.global(qos: .userInitiated).async {
                let path = Bundle.main.path(forResource: "phonemes", ofType: "txt")!
                let str = try! String(contentsOfFile: path, encoding: .utf8)
                for line in str.split(separator: "\n") {
                    let arr = line.split(separator: " ").filter { (el) -> Bool in
                        el.count > 0
                    }
                    self.dict[String(arr[0])] = String(arr[1])
                }
                self.dispatchGroup.leave()
                Logger.log("ended initializing dict")
            }
        }
    
    }
    
    func getPhoneme(for word: String) -> String? {
        self.dispatchGroup.wait()
        var result: [String] = []
        for el in word.lowercased().trimmingCharacters(in: .whitespaces).components(separatedBy: CharacterSet.alphanumerics.inverted) {
            if let transcr = dict[el] {
                result.append(transcr)
            }
        }
        
        return result.joined(separator: "  ")
    }
}

