import Foundation

// # Simple Introducer

// Object

class SimpleIntroducer {
    func whoIsIt(_ name: String) -> String {
        return "It's \(name)"
    }
}
assert("It's Poppy" == SimpleIntroducer().whoIsIt("Poppy"))

// Function

func whoIsIt(_ name: String) -> String {
    return "It's \(name)"
}
assert("It's Poppy" == whoIsIt("Poppy"))

// # Less Simple Introducer

// Function

// Don't acually do this!
func whoIsIt(announcer: String, name: String) -> String {
    return "\(announcer) says \"It's \(name)\""
}
assert("Kanye West says \"It's Poppy\"" == whoIsIt(announcer: "Kanye West", 
                                                   name: "Poppy"))
// Object

class LessSimpleIntroducer {
    var announcer = "Taylor Swift"
    func whoIsIt(_ name: String) -> String {
        return "\(announcer) says \"It's \(name)\""
    }
}
let lessSimpleIntroducer = LessSimpleIntroducer()
lessSimpleIntroducer.announcer = "Beyonce"
assert("Beyonce says \"It's Poppy\"" == lessSimpleIntroducer.whoIsIt("Poppy"))

// # Confusing Async Introducer

let semaphore = DispatchSemaphore(value: 0)

class ConfusingAsyncIntroducer {
    var announcer = "Taylor Swift"
    var objectIdentifier: Any?
    var objectExplainer: Any?
    func whoIsIt(_ name: String) {
        DispatchQueue.global().async {
            print("\(self.announcer) says \"It's \(name)\"")
            semaphore.signal()
        }
    }
}

let confusing = ConfusingAsyncIntroducer()

// This call is straight-forward
confusing.announcer = "Beyonce"
confusing.whoIsIt("Poppy")
semaphore.wait()
// Beyonce says "It's Poppy"

// But this one is unexpected!
confusing.announcer = "Taylor Swift"
confusing.whoIsIt("Poppy")
confusing.announcer = "Kanye West"
semaphore.wait()
// Kanye West says "It's Poppy"

// # Clear Async Introducer

class ClearAsyncIntroducer {
    var objectIdentifier: Any?
    var objectExplainer: Any?
    class func whoIsIt(announcer: String, name: String) {
        DispatchQueue.global().async {
            print("\(announcer) says \"It's \(name)\"")
            semaphore.signal()
        }
    }
}
ClearAsyncIntroducer.whoIsIt(announcer: "Taylor Swift", name: "Poppy")
