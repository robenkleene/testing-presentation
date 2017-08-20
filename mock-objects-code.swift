import Foundation

class Tweet { }

class XCTestCase {
    func setUp() { }
}

class ResponseParser {
    func parseTweets(from json: String, completion: ([Tweet]) -> ()) {
        // ...
    }
}

class APICaller {
    func downloadTweets(at url: URL, completion: (String) -> ()) {
        // Download JSON from remote API
    }
}

class TweetGetter {
    let apiCaller: APICaller
    let responseParser: ResponseParser
    
    init(apiCaller: APICaller, responseParser: ResponseParser) {
        self.apiCaller = apiCaller
        self.responseParser = responseParser
    }

    func getTweets(at url: URL, completion: ([Tweet]) -> ()) {
        apiCaller.downloadTweets(at: url) { json in
            responseParser.parseTweets(from: json) { tweets in
                completion(tweets)
            }
        }
    }
}

// # Mock Objects

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
