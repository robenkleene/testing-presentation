import Foundation

// # Composition

// ## Without Composition

class Tweet { }
class UIViewController {
    func viewDidLoad() {
    }
}

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

// ## With Composition

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
