import Foundation

// # Simple Introducer

// Function

func whoIsIt(_ name: String) -> String {
    return "It's \(name)"
}
assert("It's Poppy" == whoIsIt("Poppy"))

// Object

class SimpleIntroducer {
    func whoIsIt(_ name: String) -> String {
        return "It's \(name)"
    }
}
assert("It's Poppy" == SimpleIntroducer().whoIsIt("Poppy"))

// # Less Simple Introducer

class LessSimpleIntroducer {
    var announcer = "Taylor Swift"
    func whoIsIt(_ name: String) -> String {
        return "\(announcer) says \"It's \(name)\""
    }
}
assert("Taylor Swift says \"It's Poppy\"" == LessSimpleIntroducer().whoIsIt("Poppy"))

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
