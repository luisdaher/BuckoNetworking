# iOS Protocol-Oriented Networking in Swift

After developing a number of applications, we noticed that everyone's networking code was different. Every time maintenance developers had to take over a project, they had to "learn" the individual nuances of each network layer. This lead to a lot of wasted time. To solve this, our iOS Engineers decided to use the same networking setup. Thus we looked into Protocol-Oriented Networking.


### Dependencies
------

We ended up going with [Alamofire](https://github.com/Alamofire/Alamofire) instead of `URLSession` for a few reasons. Alamofire is asynchronous by nature, has session management, reduces boilerplate code, and is very easy to use.

[SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

### Installation
------

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate BuckoNetworking into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "teepsllc/BuckoNetworking"
```

1. Run `carthage update` to build the framework.
1. On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop `BuckoNetworking.framework` from the [Carthage/Build]() folder on disk. You will also need to drag `Alamofire.framework` and `SwiftyJSON.framework` into your project.
1. On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script in which you specify your shell (ex: `/bin/sh`), add the following contents to the script area below the shell:

  ```sh
  /usr/local/bin/carthage copy-frameworks
  ```

  and add the paths to the frameworks you want to use under “Input Files”, e.g.:

  ```
  $(SRCROOT)/Carthage/Build/iOS/BuckoNetworking.framework
  $(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
  $(SRCROOT)/Carthage/Build/iOS/SwiftyJSON.framework
  ```
  This script works around an [App Store submission bug](http://www.openradar.me/radar?id=6409498411401216) triggered by universal binaries and ensures that necessary bitcode-related files and dSYMs are copied when archiving.


To use BuckoNetworking, just import the module.

```swift
import BuckoNetworking
```

#### CocoaPods

Note: We don't use CocoaPods, so this may or may not work.

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate BuckoNetworking into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BuckoNetworking', :git => 'https://github.com/teepsllc/BuckoNetworking.git'
end
```

Then, run the following command:

```bash
$ pod install
```

### Usage
------
`BuckoNetworking` revolves around `Endpoint`s. There are a few ways you can use it. We use `services` to make all of our endpoints.

#### class/struct

```swift
import BuckoNetworking

// Create an endpoint
struct UserCreateService: Endpoint {
    var baseURL: String = "https://example.com/"
    var path: String = "users/"
    var method: HttpMethod = .post
    var body: Body {
        var body = Body()
        body["first_name"] = "Bucko"
        return body
    }
    var headers: HttpHeaders = ["Authorization" : "Bearer SOME_TOKEN"]
}

// Use your endpoint
Bucko.shared.request(UserCreateService()) { response in
  if response.result.isSuccess {
    // Response successful!
    let json = Json(response.result.value!)
  } else {
    // Failure
  }
}

```

#### enum

```swift
import BuckoNetworking

// Create an endpoint
enum UserService {
    case getUsers
    case getUser(id: String)
    case createUser(firstName: String, lastName: String)
}

extension UserService: Endpoint {
    // Set up the paths
    var path: String {
        switch self {
        case .getUsers: return "users/"
        case .getUser(let id): return "users/\(id)/"
        case .createUser: return "users/"
        }
    }

    // Set up the methods
    var method: HTTPMethod {
        switch self {
        case .getUsers: return .get
        case .getUser: return .get
        case .createUser: return .post
        }
    }

    // Set up any headers you may have. You can also create an extension on `Endpoint` to set these globally.
    var headers: HTTPHeaders {
        return ["Authorization" : "Bearer SOME_TOKEN"]
    }

    // Lastly, we set the body. Here, the only route that requires parameters is create.
    var body: Parameters {
        var body: Parameters = Parameters()

        switch self {
        case .createUser(let firstName, let lastName):
            body["first_name"] = firstName
            body["last_name"] = lastName
        default:
            break
        }

        return body
    }
}

// Use your endpoint
Bucko.shared.request(UserService.getUser(id: "1")) { response in
  if response.result.isSuccess {
    // Response successful!
    let json = Json(response.result.value!)
  } else {
    // Failure
  }
}

```

### Blog
------

You can go to our [Blog](https://teeps.org/blog/2017/02/27/26-protocol-oriented-networking-in-swift) to read more.
