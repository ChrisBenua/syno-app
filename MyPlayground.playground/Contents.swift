import Foundation

let url = URL(string: "https://www.stackoverflow.com")!
var semaphore = DispatchSemaphore(value: 1)

let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
    guard let data = data else { return }
    print(response.hashValue)
    let url2 = URL(string: "https://www.stackoverflow.com")!

    var innerTask = URLSession.shared.dataTask(with: url2) {(data2, response2, error2) in
        guard let data2 = data2 else { print("shit"); return }
        print(response2.hashValue)
        semaphore.signal()
    }
    innerTask.resume()
    semaphore.wait()
}

task.resume()
