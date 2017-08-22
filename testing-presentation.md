# Practical Testing for an Imperative World

---

# Topics

* Unit Testing
* Functional Programming
* Composition
* Dependency Injection
* Mock Objects
* Case Study: WSJ's Barfly

---

# Why write unit tests?

* No more "moving the food around on your plate"
* Reduce feedback loops
* Facilitate refactoring
* Manual testing is boring

---

# Functional Style

* First class functions
* Higher-order functions
* Declarative (vs. Imperative)

---

# Functional Programming

* Calling a function with the same inputs always produces the same result.
* This means *no state*.
* Unlike Object-Orientated Programming, where methods can access objects state (e.g., through properties).

---

Class vs. Function: Simple Introducer

``` swift
// Class
class SimpleIntroducer {
    func whoIsIt(_ name: String) -> String {
        return "It's \(name)"
    }
}
assert("It's Poppy" == SimpleIntroducer().whoIsIt("Poppy"))

// Function (Don't actually do this!)
func whoIsIt(_ name: String) -> String {
    return "It's \(name)"
}
assert("It's Poppy" == whoIsIt("Poppy"))
```

---

Class vs. Function: Less Simple Introducer

``` swift
// Class
class LessSimpleIntroducer {
    var announcer = "Taylor Swift"
    func whoIsIt(_ name: String) -> String {
        return "\(announcer) says \"It's \(name)\""
    }
}
let lessSimpleIntroducer = LessSimpleIntroducer()
lessSimpleIntroducer.announcer = "Beyonce"
assert("Beyonce says \"It's Poppy\"" == lessSimpleIntroducer.whoIsIt("Poppy"))

// Function (Don't actually do this!)
func whoIsIt(announcer: String, name: String) -> String {
    return "\(announcer) says \"It's \(name)\""
}
assert("Kanye West says \"It's Poppy\"" == whoIsIt(announcer: "Kanye West", 
                                                   name: "Poppy"))

```

---

Class vs. Function: Interfaces

``` swift
// Class
class LessSimpleIntroducer {
    var announcer: String
    func whoIsIt(_ name: String) -> String 
}

// Function
func whoIsIt(announcer: String, 
             name: String) -> String
```

---

More Complex Interfaces

``` swift

// Class
class MoreComplexIntroducer {
    var announcer: String
    var objectIdentifier: ObjectIdentifier
    var objectExplainer: ObjectExplainer
    func whoIsIt(_ name: String) -> String
    func whatIsIt(_ object: Any) -> String
    func whatDoesItDo(_ object: Any) -> String
}

// Function
func whoIsIt(announcer: String, 
             name: String) -> String
func whatIsIt(objectIdentifier: ObjectIdentifier, 
              object: Any) -> String
func whatDoesItDo(objectExplainer: ObjectExplainer, 
                  object: Any) -> String
```

---

> Reason #1 that functional programming facilitates testing is by clarifying your API

---

Confusing Async Introducer

``` swift
let semaphore = DispatchSemaphore(value: 0)
class ConfusingAsyncIntroducer {
    var announcer = "Taylor Swift"
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
```
---

Clear Async Introducer

``` swift
class ClearAsyncIntroducer {
    class func whoIsIt(announcer: String, name: String) {
        DispatchQueue.global().async {
            print("\(announcer) says \"It's \(name)\"")
            semaphore.signal()
        }
    }
}
ClearAsyncIntroducer.whoIsIt(announcer: "Taylor Swift", name: "Poppy")
```
---

> Reason #2 that functional programming facilitates testing by reducing the testing surface area

---

To facilitate testing, write as much of your program as possible in a functional style.

> **"Imperative shell, functional core"**
-- *Gary Bernhardt, Boundaries, 2012*

---

# Composition

* "Composition over inheritance"
* [Object composition - Wikipedia](https://en.wikipedia.org/wiki/Object_composition): "Combine simple objects or data types into more complex ones"
* For example, instead of a `UIViewController` downloading and parsing an API call itself, it might have a `TweetGetter` that performs that work. The `TweetGetter` might itself have an `APICaller` and a `ResponseParser`.

---

Without composition

``` swift
class AllInOneTweetListViewController: UIViewController {
    let url = URL(string: "https://api.twitter.com/1.1/search/tweets.json")!

    override func viewDidLoad() {
        getTweets(at: url) { tweets in
            // Display the tweets
        }
    }
    
    func getTweets(at url: URL, completion: ([Tweet]) -> ()) {
        downloadTweets(at: url) { json in
            parseTweets(from: json) { tweets in
                completion(tweets)
            }
        }
    }
    
    func downloadTweets(at url: URL, completion: (String) -> ()) {
        // ...
    }

    func parseTweets(from json: String, completion: ([Tweet]) -> ()) {
        // ...
    }
}
```

---

With composition

``` swift
class ComposedTweetListViewController: UIViewController {
    let url = URL(string: "https://api.twitter.com/1.1/search/tweets.json")!
    let tweetGetter = TweetGetter()

    override func viewDidLoad() {
        tweetGetter.getTweets(at: url) { tweets in
            // Display the tweets
        }
    }
}

class TweetGetter {
    let apiCaller = APICaller()
    let responseParser = ResponseParser()

    func getTweets(at url: URL, completion: ([Tweet]) -> ()) {
        apiCaller.downloadTweets(at: url) { json in
            responseParser.parseTweets(from: json) { tweets in
                completion(tweets)
            }
        }
    }
}

class APICaller {
    func downloadTweets(at url: URL, completion: (String) -> ()) {
        // ...
    }
}

class ResponseParser {
    func parseTweets(from json: String, completion: ([Tweet]) -> ()) {
        // ...
    }
}
```

---

Composition allows individual classes responsible for subsets of code to be instantiated separately

``` swift
let apiCaller = APICaller()
let responseParser = ResponseParser()
let tweetGetter = TweetGetter()
```

---

> Reason #1 that composition facilitates testing is by making it possible to test subsets of code individually

---

# Dependency Injection

[Dependency injection - Wikipedia](https://en.wikipedia.org/wiki/Dependency_injection): "Dependency injection is a technique whereby one object supplies the dependencies of another object"
* [James Shore](http://www.jamesshore.com/Blog/Dependency-Injection-Demystified.html): "'Dependency Injection' is a 25-dollar term for a 5-cent concept"
* Instead of the `TweetGetter` initializing the `APICaller` and `ResponseParser` itself, it takes those dependencies as initialization parameters.

---

``` swift
// Without Dependency Injection

class StiffTweetGetter {
    let apiCaller = APICaller()
    let responseParser = ResponseParser()
}

// With Dependency Injection

class FlexibleTweetGetter {
    let apiCaller: APICaller
    let responseParser: ResponseParser
    init(apiCaller: APICaller, responseParser: ResponseParser) {
        self.apiCaller = apiCaller
        self.responseParser = responseParser
    }
}
```

---

# Mock Objects

* [Mock object - Wikipedia](https://en.wikipedia.org/wiki/Mock_object): "Mock objects are simulated objects that mimic the behavior of real objects in controlled ways."
* The `FlexibleTweetGetter` could be initialized with an `APICaller`, that instead of making a network call, it returns a constant `string` for the API response.

---

Mock Objects Example

``` swift
class MockAPICaller: APICaller {
    override func downloadTweets(at url: URL, completion: (String) -> ()) {
        // Use a built-in constant JSON response
    }
}

class TweetGetterTests: XCTestCase {
    var tweetGetter: TweetGetter!

    override func setUp() {
        super.setUp()
        tweetGetter = TweetGetter(apiCaller: MockAPICaller(), 
                                  responseParser: ResponseParser())
    }
}
```

---

> Reason #1 that dependency injection facilitates testing is because it allows dependencies to be mocked

---

> Reason #2 that composition facilitates testing is because it enables dependency injection

---

## Case Study: WSJ's Barfly

* Barfly, because our backend system is called Pubcrawl (it crawls publications)
* Barfly is responsible for downloading all the content in the WSJ app

---

## How to Structure Tests

* Everything is functional that can be functional
* Composed all of the things
* Anything can be dependency injected into anything
* How do I write my tests now?

---

## Basic Building Block

* Copy test data into the test bundle as a build phase
* Create a simple helper function to access the test data

---

## Basic Building Block Example

``` swift
extension XCTestCase {
    public func fileURLForTestData(withPathComponent pathComponent: String) -> URL {
        let bundleURL = Bundle(for: type(of: self)).bundleURL
        let fileURL = bundleURL.appendingPathComponent("TestData").appendingPathComponent(pathComponent)
        return fileURL
    }
}

class ManifestTests: XCTestCase {
    func testManifest() {
        let testDataManifestNoEntryPathComponent = "manifestNoEntry.json"
        let fileURL = fileURLForTestData(withPathComponent: testDataManifestNoEntryPathComponent)
        print("fileURL = \(fileURL)")
    }
}
```

---

## Weird Trick #1: `XCTestCase` Subclasses

These are postfixed with `TestCase` not `Tests`.

``` swift
class MockFilesContainerTestCase: XCTestCase {
    var mockFilesContainer: FilesContainer!
    override func setUp() {
        super.setUp()
        mockFilesContainer = MockFilesContainer()
    }
}

class MockCatalogUpdaterTestCase: MockFilesContainerTestCase {
    var mockCatalogUpdater: CatalogUpdater!
    override func setUp() {
        super.setUp()
        mockCatalogUpdater = MockCatalogUpdater(filesContainer: mockFilesContainer)
    }
}

class CatalogUpdaterTests: MockCatalogUpdaterTestCase { }
```

---

## At the Top

``` swift
class BarflyCatalogUpdateTestCase: TestDataFilesContainerTestCase {
    var barfly: MockBarfly!
    func setUp() {
        barfly = MockBarfly(...)
    }

    func updateCatalog() -> Catalog {
        var updatedCatalog: Catalog!
        let updateCatalogExpectation = expectation(description: "Update catalog")
        updateCatalogWithCompletion { (error, catalog) -> Void in
            updatedCatalog = catalog
            updateCatalogExpectation.fulfill()
        }
        waitForExpectations(timeout: testTimeout, handler: nil)
        return updatedCatalog
    }
}
```

---

## It Scales!

This techniques scales up naturally to complex classes with many dependencies.

``` swift
class Barfly {
   public init(catalogContainerLoader: CatalogContainerLoader,
               catalogController: CatalogController,
               containerLoader: ContainerLoader,
               trashDirectoryURL: URL,
               jobCoordinator: JobCoordinator,
               containerManifestLoader: ContainerManifestLoader,
               foregroundContainersUpdater: ForegroundContainersUpdater,
               backgroundContainersUpdater: BackgroundContainersUpdater,
               janitor: Janitor,
               maxConcurrentBackgroundDownloads: Int)
   {
       // ...
   }
}
```

---

## Weird Trick #2: `Tester` Frameworks

Create "Testers" to share the same testing infrastructure across apps and frameworks.

```
Barfly Targets							WSJ Targets

* Barfly								* WSJ
* BarflyTester								* Imports Barfly
* BarflyTests							* WSJ Tests
	* Imports Barfly						* Imports Barfly
	* Imports BarflyTester					* Imports BarflyTester
```

This way `WSJ Tests` can subclass `BarflyCatalogUpdateTestCase` and call `updateCatalog()`.

---

## That's All

*Thanks for listening!*

Roben Kleene
