//
//  FacebookManager.swift
//  LetSwift
//
//  Created by Marcin Chojnacki on 20.04.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import FBSDKLoginKit

enum FacebookLoginStatus {
    case success(LoginManagerLoginResult)
    case error(Error?)
    case cancelled
}

enum FacebookEventAttendance: String {
    case unknown
    case attending
    case declined
    case maybe
}

private enum FacebookPermissions {
    static let rsvpEvent = "rsvp_event"
}

private enum FacebookError: Int {
    case missingPermissions = 200
    case missingExtendedPermissions = 299 // HACK: Undocumented status code
    
    static func from(error: Error?) -> FacebookError? {
        guard let errorCode = (error as NSError?)?.userInfo[GraphRequestErrorGraphErrorCodeKey] as? Int else { return nil }

        return FacebookError(rawValue: errorCode)
    }
}

final class FacebookManager {
    
    static let shared = FacebookManager()
    private let loginManager = LoginManager()
    
    private let readPermissions = [String]()
    private let publishPermissions = [FacebookPermissions.rsvpEvent]
    
    let facebookLoginObservable = Observable<Void>()
    let facebookLogoutObservable = Observable<Void>()
    
    private init() {
        GraphRequestConnection.defaultConnectionTimeout = NetworkProvider.timeout
    }
    
    var isLoggedIn: Bool {
        return AccessToken.current != nil
    }
    
    func logIn(from viewController: UIViewController?, callback: ((FacebookLoginStatus) -> Void)?) {
        let handler = { [weak self] (result: LoginManagerLoginResult?, error: Error?) in
            if let error = error {
                callback?(.error(error))
            } else if let result = result {
                if result.isCancelled {
                    callback?(.cancelled)
                } else {
                    self?.facebookLoginObservable.next()
                    callback?(.success(result))
                }
            } else {
                callback?(.error(nil))
            }
        }
        
        if readPermissions.isEmpty || isLoggedIn {
            loginManager.logIn(permissions: publishPermissions,
                               from: viewController,
                               handler: handler)
        } else {
            loginManager.logIn(permissions: readPermissions,
                               from: viewController,
                               handler: handler)
        }
    }
    
    func logOut() {
        loginManager.logOut()
        
        facebookLogoutObservable.next()
    }
    
    private func askForMissingPermissions(error: FacebookError?, callback: @escaping (Bool) -> Void) {
        guard let error = error, [FacebookError.missingPermissions, FacebookError.missingExtendedPermissions].contains(error) else {
            callback(false)
            return
        }
        
        self.logIn(from: nil) { status in
            if case .success(_) = status {
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    private func sendGraphRequest(_ request: GraphRequest, callback: @escaping (Any?) -> Void) {
        request.start { [weak self] (_, result: Any?, error: Error?) in
            self?.askForMissingPermissions(error: FacebookError.from(error: error)) { recovered in
                guard recovered else {
                    callback(result)
                    return
                }
                
                request.start(completionHandler: { (_, result, _) in
                    callback(result)
                })
            }
        }
    }
    
    func changeEvent(attendanceTo attendance: FacebookEventAttendance, forId id: String, callback: ((Bool) -> Void)?) {
        // HACK: Undocumented API call
        let request = GraphRequest(graphPath: "\(id)/\(attendance)", parameters: [:], httpMethod: .post)
        
        sendGraphRequest(request) { result in
            guard let resultDict = (result as? [String: Any]) else {
                callback?(false)
                return
            }
            
            let success = resultDict["success"] as? Bool
            callback?(success == true)
        }
    }
    
    private func attendanceRequest(forEventId id: String) -> GraphRequest? {
        guard isLoggedIn else { return nil }

        let parameters: [String: Any] = [
            "user": AccessToken.current?.userID as Any,
            "fields": "rsvp_status"
        ]
        
        return GraphRequest(graphPath: "\(id)/\(FacebookEventAttendance.attending)", parameters: parameters, httpMethod: .get)
    }
    
    func isUserAttending(toEventId id: String, callback: @escaping (FacebookEventAttendance) -> Void) {
        guard let request = attendanceRequest(forEventId: id) else {
            callback(.unknown)
            return
        }
        
        sendGraphRequest(request) { result in
            guard let resultDict = (result as? [String: Any]), let data = resultDict["data"], let dataArray = (data as? [Any]) else {
                callback(.unknown)
                return
            }
            
            callback(dataArray.isEmpty ? .declined : .attending)
        }
    }
}
