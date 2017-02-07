//
//  Bucko.swift
//  Networking
//
//  Created by Chayel Heinsen on 2/6/17.
//  Copyright © 2017 Teeps. All rights reserved.
//

import Foundation
import Alamofire

protocol BuckoErrorHandler {
    func buckoRequest(request: URLRequest, error: Error)
}

typealias ResponseClosure = ((DataResponse<Any>) -> Void)

struct Bucko {
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
    var manager: SessionManager = SessionManager()
    static let shared = Bucko()
    var delegate: BuckoErrorHandler?
    
    /**
     Make API requests
     
     Example:
     
     ```
     let request = Bucko.shared.request(.getUser(id: "1")) { response in
        if let response.result.isSuccess {
            let json = JSON(response.result.value!)
        } else {
            // Handle error
        }
     ```
     
      - parameter endpoint:   The endpoint to use.
      - parameter completion: The closure that will return the response from the server.
      - returns: The request that was made.
     */
    func request(endpoint: Endpoint, completion: @escaping ResponseClosure) -> Request {
        let request = manager.request(
            endpoint.fullURL,
            method: endpoint.method,
            parameters: endpoint.body,
            encoding: endpoint.encoding,
            headers: endpoint.headers
        ).responseJSON { response in
            
            if response.result.isSuccess {
                debugPrint(response.result.description)
            } else {
                debugPrint(response.result.error ?? "Error")
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