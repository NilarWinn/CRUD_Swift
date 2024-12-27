//
//  Service.swift
//  Bulletin-Board-Swift
//
//  Created by NilarWin on 21/10/2022.
//

import Foundation
import Alamofire
import SwiftyJSON

class Service: NSObject {
    static let shared = Service()
    var data = Data()
    
    func getHeader(token: String) -> HTTPHeaders{
        let headers : HTTPHeaders = [
            "Authorization": "Bearer " + token
        ]
        return headers
    }
    
    func getPostList(token: String, startIndex: String,completion: @escaping (PostModel) -> ()) {
        AF.request("\(Network.HOSTAPI)post?page=\(startIndex)" , method : .get, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: PostModel.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func getSearchPostList(token: String, startIndex: String,searchData: String, completion: @escaping (PostModel) -> ()) {
        AF.request("\(Network.HOSTAPI)post/search?key=\(searchData)&page=\(startIndex)" , method : .get, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: PostModel.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func deletePost(token: String, parameter: Parameters, completion: @escaping (ResponseStatus) -> ()) {
        AF.request("\(Network.HOSTAPI)post/delete", method : .post, parameters: parameter as Parameters, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func createPost(token: String, parameter: Parameters, completion: @escaping (ResponseStatus) -> ()) {
        AF.request("\(Network.HOSTAPI)post/create", method : .post, parameters: parameter as Parameters, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func updatePost(token: String, parameter: Parameters, completion: @escaping (ResponseStatus) -> ()) {
        AF.request("\(Network.HOSTAPI)post/update", method : .put, parameters: parameter as Parameters, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func getUserList(token: String, startIndex: String,completion: @escaping (ResponseUserModel) -> ()) {
        AF.request("\(Network.HOSTAPI)user?page=" + String(startIndex), method : .get, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseUserModel.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func getSearchUserList(token: String, startIndex: String, searchData: String, completion: @escaping (ResponseUserModel) -> ()) {
        AF.request("\(Network.HOSTAPI)user/search?key=\(searchData)&page=\(startIndex)", method : .get, headers: getHeader(token: token)).responseDecodable(of: ResponseUserModel.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func deleteUser(token: String, parameter: Parameters, completion: @escaping (ResponseStatus) -> ()) {
        AF.request("\(Network.HOSTAPI)user/delete", method : .post, parameters: parameter as Parameters, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func createUser(url: String,token: String, parameter: Parameters, uploadFileURL : String, fileName: String, uploadFileMimeType: String, image: UIImage?, completion: @escaping (ProfileModel) -> ()) {
        AF.upload(multipartFormData:  { [self] multipartFormData in
            for (key, value) in parameter {
                if key == "profile" {
                    if uploadFileURL.count > 0 {
                        data = (image?.jpegData(compressionQuality: 0.2))! as Data
                    }
                    multipartFormData.append( data, withName: "profile", fileName: fileName, mimeType: uploadFileMimeType)
                }else{
                    multipartFormData.append((value as! NSString).data(using: String.Encoding.utf8.rawValue)!, withName: key )
                }
            }
        }, to: url ,method: .post,headers: getHeader(token: token))
        .responseDecodable(of: ProfileModel.self){ (response) in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func checkToken(token: String, completion: @escaping (ResponseStatus) -> ()) {
        AF.request("\(Network.HOSTAPI)checktoken", method : .get, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func logout(token: String, completion: @escaping (ResponseStatus) -> ()) {
        AF.request("\(Network.HOSTAPI)logout", method : .get, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func login(parameter: Parameters, completion: @escaping (LoginModel) -> ()) {
        AF.request("\(Network.HOSTAPI)login", method : .post, parameters: parameter as Parameters,encoding: JSONEncoding.default,headers: nil).responseDecodable(of: LoginModel.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func profile(token: String, completion: @escaping (ProfileModel) -> ()) {
        AF.request("\(Network.HOSTAPI)user/profile", method : .get, headers: getHeader(token: token)).responseDecodable(of: ProfileModel.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func uploadCSV(token: String,uploadFileName: String, uploadFileMimeType: String, data: Data, completion: @escaping (ResponseStatus) -> ()) {
        AF.upload(multipartFormData:  { multipartFormData in
            multipartFormData.append( data, withName: "data_file", fileName: uploadFileName, mimeType: uploadFileMimeType)
        }, to: "\(Network.HOSTAPI)post/upload" ,method: .post,headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func changePassword(token: String,parameter: Parameters, completion: @escaping (ResponseStatus) -> ()) {
        AF.request("\(Network.HOSTAPI)user/update/password", method : .post, parameters: parameter as Parameters, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: ResponseStatus.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func getMyPostList(token: String, startIndex: String,completion: @escaping (PostModel) -> ()) {
        AF.request("\(Network.HOSTAPI)user/profile/post?page=" + String(startIndex), method : .get, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: PostModel.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    func getSearchMyPostList(token: String, startIndex: String,searchData: String, completion: @escaping (PostModel) -> ()) {
        AF.request("\(Network.HOSTAPI)user/profile/post?key=\(searchData)&page=\(startIndex)", method : .get, encoding: JSONEncoding.default, headers: getHeader(token: token)).responseDecodable(of: PostModel.self) { response in
            guard let result = response.value else { return }
            completion(result)
        }
    }
}

