import Foundation

// Functional

let expectedIntroduction = "It's Poppy"

func whoIsIt(_ name: String) -> String {
    return "It's \(name)"
}

_ = whoIsIt("Poppy")

assert(expectedIntroduction == whoIsIt("Poppy"))

class SimpleIntroducer {
    func whoIsIt(_ name: String) -> String {
        return "It's \(name)"
    }
}

// Interface
//class SimpleIntroducer {
//    func whoIsIt(_ name: String) -> String
//}

_ = SimpleIntroducer().whoIsIt("Poppy")
//assert(expectedIntroduction == whoIsIt("Poppy"))

class LessSimpleIntroducer {
    var announcer = "Taylor Swift"
    func whoIsIt(_ name: String) -> String {
        return "It's \(name)"
    }
}

// Interface
//class LessSimpleIntroducer {
//    var announcer: String
//    func whoIsIt(_ name: String) -> String
//}

class SafeIntroducer {
    var announcer = "Taylor Swift"
    class func whoIsIt(_ name: String) -> String {
        return "It's \(name)"
    }
}

// Interface
//class LessSimpleIntroducer {
//    var announcer: String
//    class func whoIsIt(_ name: String) -> String
//}

_ = SafeIntroducer.whoIsIt("Poppy")

let semaphore = DispatchSemaphore(value: 0)

class ICanHazDangerousProperty {
    var announcer = "Taylor Swift"
    func announce() {
        DispatchQueue.global().async {
            print("\(self.announcer) says \"Your ten year old memes are lame.\"")
            semaphore.signal()
        }
    }
}

// Interface
//class ICanHazDangerousProperty {
//    var accouncer: String
//    func announce()
//}

let dangerous = ICanHazDangerousProperty()
dangerous.announcer = "Beyonce"
dangerous.announce()
semaphore.wait()
dangerous.announcer = "Taylor Swift"
dangerous.announce()
dangerous.announcer = "Kanye West"
semaphore.wait()
