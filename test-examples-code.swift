import Foundation

class XCTestCase { 
    func setUp() {
    }
}

class FilesContainer { }
class MockFilesContainer: FilesContainer { }
class CatalogUpdater { 
    init(filesContainer: FilesContainer) {
    }
}
class MockCatalogUpdater: CatalogUpdater { }

// # Basic Building Block

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

// #  Trick #1: `XCTestCase` Subclasses

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
