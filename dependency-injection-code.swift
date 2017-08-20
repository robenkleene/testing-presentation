import Foundation

class APICaller { }

class ResponseParser { }

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
