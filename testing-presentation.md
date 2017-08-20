# Practical Testing for an Imperative World

* Functional Programming
* Dependency Injection
* Composition

---

## Functional Style

* First class functions
* Higher-order functions
* Declarative (vs. Imperative)

## Functional Programming

* Calling a function with the same inputs always generates the same result.
* This means *no state*.
* Unlike Object-Orientated Programming, where methods can access objects state (e.g., through properties).

## Simple Introducer

``` swift
// Object

class SimpleIntroducer {
    func whoIsIt(_ name: String) -> String {
        return "It's \(name)"
    }
}
assert("It's Poppy" == SimpleIntroducer().whoIsIt("Poppy"))

// Function

// Don't acually do this!
func whoIsIt(_ name: String) -> String {
    return "It's \(name)"
}
assert("It's Poppy" == whoIsIt("Poppy"))
```

---

## Less Simple Introducer

``` swift
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
lessSimpleIntroducer.announcer = "Kanye West"
assert("Kanye West says \"It's Poppy\"" == lessSimpleIntroducer.whoIsIt("Poppy"))
```

---

## Interfaces

``` swift
class LessSimpleIntroducer {
    var announcer: String
    func whoIsIt(_ name: String) -> String 
}

func whoIsIt(announcer: String, 
             name: String) -> String
```

## More Complex Interfaces

``` swift
class MoreComplexIntroducer {
    var announcer: String
    var objectIdentifier: ObjectIdentifier
    var objectExplainer: ObjectExplainer
    func whoIsIt(_ name: String) -> String
    func whatIsIt(_ object: Any) -> String
    func whatDoesItDo(_ object: Any) -> String
}

func whoIsIt(announcer: String, 
             name: String) -> String
func whatIsIt(objectIdentifier: ObjectIdentifier, 
              object: Any) -> String
func whatDoesItDo(objectExplainer: ObjectExplainer, 
                  object: Any) -> String
```

## Dangerous Introducer

``` swift
class ICanHazDangerousProperty {
    var announcer = "Taylor Swift"
    func announce() {
        DispatchQueue.global().async {
            print("\(self.announcer) says \"Your ten year old memes are lame.\"")
            semaphore.signal()
        }
    }
}
let dangerous = ICanHazDangerousProperty()

// This call is straight-forward
dangerous.announcer = "Beyonce"
dangerous.announce()
semaphore.wait()
// Beyonce says "Your ten year old memes are lame."

// But this one is unexpected!
dangerous.announcer = "Taylor Swift"
dangerous.announce()
dangerous.announcer = "Kanye West"
semaphore.wait()
// Kanye West says "Your ten year old memes are lame."
```

# Safe Introducer

``` Swift
class SafeAsyncIntroducer {
    var announcer = "Taylor Swift"
    func announce() {
        DispatchQueue.global().async {
            print("\(self.announcer) says \"Your ten year old memes are lame.\"")
            semaphore.signal()
        }
    }
}
let safe = SafeAsyncIntroducer()
safe.announce(announcer: "Taylor Swift")


---

## Why does functional programming help us write tests?

> **"Imperative shell, functional core"**
-- *Gary Bernhardt, Boundaries, 2012*

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
user@example.com
