//
//  Bucko.swift
//  Networking
//
//  Created by Chayel Heinsen on 2/6/17.
//  Copyright © 2017 Teeps. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public protocol BuckoErrorHandler: class {
  func buckoRequest(request: URLRequest, error: Error)
}

public typealias BuckoResponseClosure = ((DataResponse<Any>) -> Void)
@available(*, deprecated, message: "Use HTTPMethod instead")
public typealias HttpMethod = HTTPMethod
@available(*, deprecated, message: "Use HTTPHeaders instead")
public typealias HttpHeaders = HTTPHeaders
@available(*, deprecated, message: "Use ParameterEncoding instead")
public typealias Encoding = ParameterEncoding
@available(*, deprecated, message: "Use URLEncoding instead")
public typealias UrlEncoding = URLEncoding
@available(*, deprecated, message: "Use JSONEncoding instead")
public typealias JsonEncoding = JSONEncoding
@available(*, deprecated, message: "Use Parameters instead")
public typealias Body = Parameters
@available(*, deprecated, message: "Use JSON instead")
public typealias Json = JSON

public struct Bucko {
  /**
   Can be overriden to configure the session manager.
   e.g - Creating server trust policies
   ```
   let manager: SessionManager = {
     // Create the server trust policies
     let serverTrustPolicies: [String: ServerTrustPolicy] = [
     "0.0.0.0": .disableEvaluation // Use your server obviously. Can be a url as well, example.com
     ]

     // Create custom manager
     let configuration = URLSessionConfiguration.default
     configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
     let manager = SessionManager(
      configuration: URLSessionConfiguration.default,
      serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
     )
     return manager
   }()

   Bucko.shared.manager = manager

   ```
   */
  public var manager: SessionManager = SessionManager()
  public static var shared = Bucko()
  public weak var delegate: BuckoErrorHandler?

  public init() {
  }

  /**
   Make API requests. Use this to handle responses with your own response closure. The example
   uses responseData to handle the response. If you are expecting JSON, you should
   use `Bucko.shared.request(endpoint:,completion:)` instead.

   Example:

   ```
   let request = Bucko.shared.request(.getUser(id: "1"))
   request.responseData { response in

   if response.result.isSuccess {
    debugPrint(response.result.description)
    } else {
    debugPrint(response.result.error ?? "Error")
    }
   }
   ```

   - parameter endpoint:   The endpoint to use.
   - returns: The request that was made.
   */
  public func request(endpoint: Endpoint) -> DataRequest {
    let request = manager.request(
      endpoint.fullURL,
      method: endpoint.method,
      parameters: endpoint.body,
      encoding: endpoint.encoding,
      headers: endpoint.headers
    )

    print(request.description)
    return request
  }

  /**
   Make API requests with JSON response.

   Example:

   ```
   let request = Bucko.shared.request(.getUser(id: "1")) { response in

   if let response.result.isSuccess {
    let json = JSON(response.result.value!)
   } else {
    let error = JSON(data: response.data)
   }
   ```

   - parameter endpoint:   The endpoint to use.
   - parameter completion: The closure that will return the response from the server.
   - returns: The request that was made.
   */
  @discardableResult
  public func request(endpoint: Endpoint, completion: @escaping BuckoResponseClosure) -> DataRequest {
    let request = self.request(endpoint: endpoint).validate().responseJSON { response in

        if response.result.isSuccess {
          debugPrint(response.result.description)
        } else {
          debugPrint(response.result.error ?? "Error")
          debugPrint(response.serverError ?? "Error")
          // Can globably handle errors here if you want
          if let urlRequest = response.request, let error = response.result.error {
            self.delegate?.buckoRequest(request: urlRequest, error: error)
          }
        }

        completion(response)
    }

    print(request.description)
    return request
  }
}

extension DataResponse {
  public var serverError: JSON? {
    guard let data = self.data else { return nil }
    return JSON(data: data)
  }
}
