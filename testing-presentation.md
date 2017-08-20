# Practical Testing for an Imperative World

* Unit testing
* Functional Programming
* Dependency Injection
* Composition
* Mock Objects

---

# Why using unit testing?

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

* Calling a function with the same inputs always generates the same result.
* This means *no state*.
* Unlike Object-Orientated Programming, where methods can access objects state (e.g., through properties).

---

Simple Introducer

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

Less Simple Introducer

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

Interfaces

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

## Testing State

Testing updates means testing state, so:

1. Your surface area for bugs is enormous.
2. Your tests will be complicated.

---

## Our Testing Techniques

How we test updates in the Wall Street Journal for iOS.

---

## The Basic Building Block

* Copy test data into the test bundle as a build phase.
* Create a simple helper function to access the test data.

``` swift
extension XCTestCase {
    public func fileURLForTestData(withPathComponent pathComponent: String) -> URL {
        let bundleURL = Bundle(for: self).bundleURL
        let fileURL = bundleURL.appendingPathComponent("TestData").appendingPathComponent(pathComponent)
        return fileURL
    }
}

class ManifestTests: XCTestCase {
	let testDataManifestNoEntryPathComponent = "manifestNoEntry.json"
	fileURLForTestData(withFilename: testDataManifestNoEntryPathComponent)
}
```

---

## More Sophisticated Test Cases

Build up to more sophisticated test cases by subclassing:

``` swift
class MockFilesContainerTestCase: XCTestCase { }
class MockCatalogUpdaterTestCase: FilesContainerTestCase { }
class MockBarflyTestCase: MockCatalogUpdaterTestCase { }
```

Note these are postfixed with `TestCase` not `Tests`. Tests use:

``` swift
class CatalogUpdaterTests: MockCatalogUpdaterTestCase { }
```

---

## High-Level Test Cases

``` swift
class BarflyCatalogUpdateTestCase: TestDataFilesContainerTestCase {
	var barfly: MockBarfly!
	func setUp() {
		// Setup `MockBarfly` dependencies
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

## An Example Tests

1. Use the before and after catalogs.
2. Test that callbacks fire.

``` swift
class ContainerResultsControllerTests: BarflyCatalogUpdateTestCase {
	let firstCatalog = loadCatalog()
	let updatedCatalog = updateCatalog()
	XCTAssertTrue(containerResultsControllerDelegate.delegateWasInformed)
	XCTAssertTrue(type(of: self).doContainers(containerResultsController.availableContainers(), 
								 matchContainers: firstCatalog.containers)))

	_ = containerResultsController.applyUpdate()
	XCTAssertTrue(type(of: self).doContainers(containerResultsController.availableContainers(), 
	                             matchContainers: updatedCatalog.containers)))
}
```

---

## Testing Across Apps & Frameworks

Create "Testers" to share the same testing infrastructure across apps and frameworks.

```
Barfly Targets                           WSJ Targets

* Barfly                                 * WSJ
* BarflyTester								* Imports Barfly
	* Imports XCTest					 * WSJ Tests
* BarflyTests								* Imports XCTest (implicately)
	* Imports Barfly and BarflyTester		 * Imports Barfly and BarflyTester
```

This way `WSJ Tests` can subclass `BarflyCatalogUpdateTestCase` and call `updateCatalog()`.

---

## Tricks & Gotchas

* Mocked all network IO, using `HTTPStubs`.
* Also mocked all disk IO (disk IO is slow, especially with a large number of content files). 
	* Mocked our lowest-level file system classes to wrap the `TestData` directories in the test bundle.

If we did it again, I'd use that same technique for network IO instead of `HTTPStubs` because it was more reliable (no swizzling).

---

## That's All

*Thanks for listening!*

Roben Kleene
