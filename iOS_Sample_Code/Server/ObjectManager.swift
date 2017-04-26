//
//  ObjectManager.swift
//  Project
//
//  Created by Alex Kovalov on 2/8/17.
//  Copyright © 2017 Requestum. All rights reserved.
//

import Foundation

import Alamofire
import AlamofireNetworkActivityIndicator
import ObjectMapper

public class ObjectManager: NSObject {
    
    
    // MARK: Properties
    
    let kHTTPHeaderAuthorization = "Authorization"
    
    var sessionManager: SessionManager!
    
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        sessionManager = SessionManager(configuration: configuration)
    }
    
    
    // MARK: Actions
    
    func authHeaders() -> HTTPHeaders {
        
        var headers = HTTPHeaders()
        
        if UserManager.shared.userSessionActive {
            if let token = UserManager.shared.token {
                headers[kHTTPHeaderAuthorization] = "Bearer" + " " + token
            }
        }
        
        return headers
    }
    
    func urlString(forServerAPI serverAPI: ServerAPI, urlParameters: [String: String]? = nil) -> String {
        
        var URLString = serverAPIURL + serverAPI.rawValue
        if urlParameters != nil {
            URLString = URLString.replacingURLParameters(urlParameters: urlParameters!)
        }
        
        if URLString.contains("?") {
            URLString = URLString.replacingOccurrences(of: "?", with: ("." + ServerAPIPathExtension + "?"))
        }
        else {
            URLString +=  "." + ServerAPIPathExtension
        }
        
        return URLString
    }
    
    public func request(
        method: HTTPMethod,
        serverAPI: ServerAPI,
        parameters: Parameters? = nil,
        urlParameters: [String: String]? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
        )
        -> DataRequest {
            
            let URLString = urlString(forServerAPI: serverAPI, urlParameters: urlParameters)
            
            return sessionManager.request(URLString, method: method, parameters: parameters, encoding: encoding, headers: authHeaders())
                .validate({ (urlRequest, httpUrlResponce, data) -> Request.ValidationResult in
                    
                    return self.validate(urlRequest: urlRequest, httpUrlResponce: httpUrlResponce, data: data)
                })
    }
    
    public func upload(
        serverAPI: ServerAPI,
        urlParameters: [String: String]? = nil,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        completion: @escaping (_ upload: UploadRequest?, _ error: NSError?) -> Void
        ) {
        
        let URLString = urlString(forServerAPI: serverAPI, urlParameters: urlParameters)
        
        sessionManager.upload(multipartFormData: multipartFormData, to: URLString, headers: authHeaders(), encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                let validatedUpload = upload.validate()
                completion(validatedUpload, nil)
                
            case .failure(let encodingError):
                completion(nil, encodingError as NSError?)
            }
        }
        )
    }
}


// MARK: Validation

extension ObjectManager {
    
    func validate(urlRequest: URLRequest?, httpUrlResponce: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
        
        let httpCodeRepresantation = ResponseCodeError(code: httpUrlResponce.statusCode)
        
        switch httpCodeRepresantation.code() {
            
        case ResponseCodeError.ResponseCode.forbidden.rawValue:
            
            DispatchQueue.main.async {
                UserManager.shared.logout()
            }
            
        case ResponseCodeError.ResponseCode.unauthorized.rawValue:
            
            DispatchQueue.main.async {
                UserManager.shared.logout()
            }
            
        case ResponseCodeError.ResponseCode.ok.rawValue:
            
            return .success
            
        case ResponseCodeError.ResponseCode.created.rawValue:
            
            return .success
            
        case ResponseCodeError.ResponseCode.noContent.rawValue:
            
            return .success
            
        default: break
        }
        
        var error: NSError?
        if data != nil {
            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                error = NSError.error(from: json as AnyObject)
            }
        }
        if error == nil {
            error = NSError.appError(withDescription: "Unknown server error".localized)
        }
        
        return .failure(error!)
    }
}
