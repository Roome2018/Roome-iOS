
import Foundation
import Alamofire

class MyApi: NSObject {
    
    static var api = MyApi()
    
    //MARK: Requests Functions
    func sendRequestPost(urlString:String , param:[String:Any], auth:[String:String]? = nil , completion:((NSDictionary?,String,Bool)->Void)!)
    {
        
        Alamofire.request(urlString, method: .post, parameters: param,
                          encoding: JSONEncoding.default, headers: auth)
            .validate(statusCode: 200..<300)
            .responseJSON { response  in
                
                if(response.result.isSuccess)
                {
                    if   let resp = response.result.value as? NSDictionary {
                        completion(resp,"",true)
                    }else {
                        completion(nil,"something wrong",false)
                    }
                }
                else
                {
                    completion(nil,response.result.error.debugDescription,false)
                }
        }
    }
    
    func sendRequestGet(urlString:String , completion:((NSDictionary?,String,Bool)->Void)!)
    {
        let auth = ["Accept":"application/json",
                    "Authorization":"\(Auth_User.TokenType) \(Auth_User.AccessToken)"]
        Alamofire.request(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: auth)
            .validate(statusCode: 200..<300)
            .responseJSON
            { response in
            
            if(response.result.isSuccess)
            {
                if  let resp = response.result.value as? NSDictionary {
                    completion(resp,"",true)
                }else {
                    completion(nil,"something wrong",false)
                }
            }
            else
            {
                completion(nil,response.result.error.debugDescription,false)
            }
        }
    }
    
    //MARK: Login
    func func_login(_ email:String,_ password:String, completion:((String,Bool)->Void)!)
        {
        
            let param  = ["grant_type":"password","client_id":"2",
                          "client_secret":"wqUMJXS8uSMjE72TWgMsqYauaMicpXB7qK3ZAZI9",
                          "username":email,
                          "password":password,
                          "scope":"*"]
            let loginUrl = TAConstant.LoginUrl
            sendRequestPost(urlString: loginUrl, param: param) { (response, messageRes, success) in
                if success {
                    let status = response!.value(forKey: "status") as? Bool ?? false
                    let message = response!.value(forKey: "message") as? String ?? ""
                    
                    if status {
                        let access_token = response!.value(forKey: "access_token") as? String ?? ""
                        let token_type = response!.value(forKey: "token_type") as? String ?? ""
                        Auth_User.AccessToken = access_token
                        Auth_User.TokenType = token_type
                        completion(message,true)
                        
                    }else {
                        completion(message,false)
                    }
                }else {
                    completion(messageRes,false)
                }
            }
    }
    
    //MARK: Signup
    func func_signup(_ name:String,_ email:String,_ password:String,_ mobile:String, completion:((String,Bool)->Void)!)
    {
        
        let param  = ["grant_type":"password","client_id":"2",
                      "client_secret":"wqUMJXS8uSMjE72TWgMsqYauaMicpXB7qK3ZAZI9",
                      "email":email,
                      "password":password,
                      "mobile": mobile,
                      "name":name,
                      "scope":"*"]
        
        let signupUrl = TAConstant.SignupUrl
        sendRequestPost(urlString: signupUrl, param: param) { (response, messageRes, success) in
            if success {
                let status = response!.value(forKey: "status") as? Bool ?? false
                let message = response!.value(forKey: "message") as? String ?? ""
                
                if status {
                    let access_token = response!.value(forKey: "access_token") as? String ?? ""
                    let token_type = response!.value(forKey: "token_type") as? String ?? ""
                    Auth_User.AccessToken = access_token
                    Auth_User.TokenType = token_type
                    completion(message,true)
                    
                }else {
                    let errors = response!.value(forKey: "errors") as? [[String:Any]] ?? []
                    var msg = ""
                    for item in errors {
                        let msg_error = item["message"] as? String ?? ""
                        msg += "-" + msg_error + "\n"
                    }
                    completion(msg,false)
                }
            }else {
                completion(messageRes,false)
            }
        }
    }
    
    
    //MARK: Rooms
    func func_rooms( completion:(([[String:Any]],Bool)->Void)!)
    {
        
        let roomUrl = TAConstant.RoomsUrl
        sendRequestGet(urlString: roomUrl) { (response, message, success) in
            if success {
                let items = response!.value(forKey: "items") as? [[String:Any]] ?? []
                completion(items, true)
            }else {
                completion([], false)
            }
        }
    }
    
    //MARK: Single Room
    func func_getSingleRoom(_ room_id:Int, completion:(([String:Any],Bool)->Void)!)
    {
        let roomUrl = TAConstant.RoomsUrl + "/\(room_id)"
        sendRequestGet(urlString: roomUrl) { (response, message, successResp) in
            if successResp {
                let status = response!.value(forKey: "status") as? Bool ?? false
                if status {
                    let item = response!.value(forKey: "items") as? [String:Any] ?? [:]
                    completion(item, true)
                }else {
                    completion([:], false)
                }
                
            }else {
                completion([:], false)
            }
        }
    }
    
    //MARK: Book
    func func_Book(_ room_id:Int,_ book_date:String , completion:((String,Bool)->Void)!)
    {
        
        let param  = ["room_id": room_id,
                      "date":book_date] as [String : Any]
        
        let auth = ["Accept":"application/json",
                    "Authorization":"\(Auth_User.TokenType) \(Auth_User.AccessToken)"]

        let bookingsUrl = TAConstant.BookingsUrl
        sendRequestPost(urlString: bookingsUrl, param: param , auth :auth) { (response, messageRes, success) in
            if success {
                let status = response!.value(forKey: "status") as? Bool ?? false
                let message = response!.value(forKey: "message") as? String ?? ""
                completion(message,status)
            }else {
                completion(messageRes,false)
            }
        }
    }
    
    
    //MARK: upload images
    func func_uploadImages(_ images:[UIImage] , completion:(([Int],Bool)->Void)!)
    {
        
        let auth = ["Accept":"application/json",
                    "Authorization":"\(Auth_User.TokenType) \(Auth_User.AccessToken)"]
        
        let url = TAConstant.UploadImagesUrl
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in

            for image in images {
                let data = UIImageJPEGRepresentation(image, 0.4)
                if let imageData = data{
                    multipartFormData.append(imageData, withName: "photos[]", fileName: "\(Date().millisecondsSince1970).jpg", mimeType: "image/jpeg")
                }
            }
            
            multipartFormData.append("Room".data(using: .utf8)!, withName: "model_name")
            multipartFormData.append("photos".data(using: .utf8)!, withName: "file_key")
            multipartFormData.append("photos".data(using: .utf8)!, withName: "bucket")

        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: auth) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let result = response.result.value as? NSDictionary {
                        let status = result.value(forKey: "status") as? Bool ?? false
                        if status {
                            let items = result.value(forKey: "items") as? [Int] ?? []
                            completion(items,true)
                        }else {
                            completion([],false)
                        }
                    }else {
                        completion([],false)
                    }
                }
            case .failure(_):
                completion([],false)
            }
        }

    }
    
    //MARK: ADD ROOM
    func func_addRoom(_ title:String,_ info:String , _ price:String, _ ownerName:String,
        _ team_count:String,_ address:String,_ lattitude: Double, _ logitude:Double,_ images:[Int], completion:((String,Bool)->Void)!)
    {
        
        let param  = ["title": title,
                      "owner":ownerName,
                      "info":info,
                      "price":price,
                      "max_tenants":team_count,
                      "location_address":address,
                      "location_latitude":lattitude ,
                      "location_longitude":logitude,
                      "photos_id":images] as [String : Any]
        
        let auth = ["Accept":"application/json",
                    "Authorization":"\(Auth_User.TokenType) \(Auth_User.AccessToken)"]
        
        let bookingsUrl = TAConstant.RoomsUrl
        sendRequestPost(urlString: bookingsUrl, param: param , auth :auth) { (response, messageRes, success) in
            if success {
                let status = response!.value(forKey: "status") as? Bool ?? false
                let message = response!.value(forKey: "message") as? String ?? ""
                completion(message,status)
            }else {
                completion(messageRes,false)
            }
        }
    }
    
}


