//
//  Network.swift
//  MVC-Swift
//
//  Created by NilarWin on 22/08/2022.
//

import Foundation
import Alamofire

struct Network {
    static let HOSTAPI = "http://172.20.80.62:3000/api/"
    static let IMGAPI = "http://172.20.80.62:3000"
}

class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
