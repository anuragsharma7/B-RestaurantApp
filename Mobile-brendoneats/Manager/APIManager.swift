//
//  APIManager.swift
//  Mobile-brendoneats
//
//  Created by Brendon L on 12/11/21.
//

import Foundation
import Alamofire
import SwiftyJSON

enum NetworkError: Error {
    case invalidUrl
    case noData
    case decodingError
}

class APIManager {
    
    static let shared = APIManager()
    
    let baseURL =  "https://brandon-appdjango.herokuapp.com/"//"https://aqueous-peak-57786.herokuapp.com/"
    var accessToken = "Token \(appSession.token ?? "")"
    var expired = Date()
    
    // Request Server function
    func requestServer(_ method: Alamofire.HTTPMethod,_ path: String,_ params: [String: Any]?,_ encoding: ParameterEncoding,_ completionHandler: @escaping (JSON?) -> Void) {
        let url = baseURL + path
        
        let headers: HTTPHeaders = [
            "Authorization": self.accessToken,
        ]
        
        AF.request(url, method: method, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    completionHandler(jsonData)
                    break
                
                case .failure(let error):
                    print(error.errorDescription!)
                    completionHandler(nil)
                    break
                }
            }
    }
    
    // Sign Up
    func signUp(username: String, password: String, email: String, completionHandler: @escaping(Result<[String: Any], AFError>) -> Void) {
        let path = "auth/users/"
        let params: [String: String] = [
            "username": username,
            "password": password,
            "email": email
        ]
        
        AF.request(baseURL + path, method: .post, parameters: params, encoder: JSONParameterEncoder.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let data = JSON(value).dictionaryObject
                    if data == nil {
                        completionHandler(.failure(NSError(domain: "", code: 0) as! AFError))
                    } else {
                        completionHandler(.success(data!))
                    }
                    break
                case .failure(let error):
                    completionHandler(.failure(error))
                    break
                }
            }
    }
    
    // Log in
    func logIn(username: String, password: String, completionHandler: @escaping(Result<[String: Any], AFError>) -> Void) {
        let path = "auth/token/login/"
        let params: [String: String] = [
            "username": username,
            "password": password
        ]
        
        AF.request(baseURL + path, method: .post, parameters: params, encoder: JSONParameterEncoder.default)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let data = JSON(value).dictionaryObject
                    if data == nil {
                        completionHandler(.failure(NSError(domain: "", code: 0) as! AFError))
                    } else {
                        completionHandler(.success(data!))
                    }
                    break
                case .failure(let error):
                    completionHandler(.failure(error))
                    break
                }
            }
    }
    
    // API to fetch all restaurants
    func getRestaurants(completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/restaurants/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    // API to fetch all restaurants
    func getMeals(restaurantId: Int, completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/meals/\(restaurantId)"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
    
    // API to get driver's location
    func getDriverLocation(completionHandler: @escaping (JSON?) -> Void) {
        let path = "api/customer/driver/location/"
        requestServer(.get, path, nil, JSONEncoding.default, completionHandler)
    }
        
    //API to create Payment
    func createPaymentIntent(completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/payment_intent/"
        let params: [String: String] = [
            "total": Cart.currentCart.getTotalValue().description,
            //xxx
        ]
        let headers: HTTPHeaders = [
            "Authorization": self.accessToken,
        ]

        AF.request(baseURL + path, method: .post, parameters: params, encoder: JSONParameterEncoder.default, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    completionHandler(jsonData)
                    break
                
                case .failure(let error):
                    print(error.errorDescription!)
                    completionHandler(nil)
                    break
                }
            }
    }
    
    //API to create an order
    func createOrder(completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/order/add/"
        let items = Cart.currentCart.items
        
        let jsonArray = items.map { item in
            return [
                "meal_id": item.meal.id,
                "quantity": item.qty
            ]
        }
        
        if JSONSerialization.isValidJSONObject(jsonArray) {
            do {
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                let dataString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                
                let params: [String: String] = [
                    "restaurant_id": Cart.currentCart.restaurant!.id!.description,
                    "order_details": dataString.description,
                    "address": Cart.currentCart.address!
                ]
                
                let headers: HTTPHeaders = [
                    "Authorization": self.accessToken,
                ]
                
                AF.request(baseURL + path, method: .post, parameters: params, encoder: JSONParameterEncoder.default, headers: headers)
                    .responseJSON { response in
                        
                        switch response.result {
                        case .success(let value):
                            let jsonData = JSON(value)
                            completionHandler(jsonData)
                            break
                        
                        case .failure(let error):
                            print(error.errorDescription!)
                            completionHandler(nil)
                            break
                        }
                    }
                
            } catch {
                print("JSON serialization failed: \(error)")
            }
        }
    }
    
    //API to to get the latest order (Customer)
    func getLatestOrder(completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/order/latest/"
        let headers: HTTPHeaders = [
            "Authorization": self.accessToken,
        ]
 
        AF.request(baseURL + path, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    completionHandler(jsonData)
                    break
                
                case .failure(let error):
                    print(error.errorDescription!)
                    completionHandler(nil)
                    break
                }
            }
    }
    
    //API to to get the latest order's status (Customer)
    func getLatestOrderStatus(completionHandler: @escaping(JSON?) -> Void) {
        let path = "api/customer/order/latest_status/"
        let headers: HTTPHeaders = [
            "Authorization": self.accessToken,
        ]
        
        AF.request(baseURL + path, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let jsonData = JSON(value)
                    completionHandler(jsonData)
                    break
                
                case .failure(let error):
                    print(error.errorDescription!)
                    completionHandler(nil)
                    break
                }
            }
    }
    
    func getCustomerProfile(completion: @escaping (_ response: CustomerResponse?)->Void) {
            guard let url = URL(string: "https://brandon-appdjango.herokuapp.com/api/customer/profile/") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                
                let json = JSONDecoder()
                let res = try! json.decode(CustomerResponse.self, from: data)
                
               /* guard let results = try! JSONDecoder().decode(Customer.self, from: data) else {
                    print("Decoding Error")
                    return
                }
                print("\(results)")
                */
                completion(res)
            }.resume()
        
            
        }
    
    func updateCustomerProfile(avatar: String,
                               phone: String,
                               address: String,
                               completion: @escaping (_ status: String)->Void ) {
           
        let parameters = "avatar=\(avatar)&phone=\(phone)&address=\(address)"

        let postData =  parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://brandon-appdjango.herokuapp.com/api/customer/profile/update/")!,timeoutInterval: Double.infinity)
        request.addValue(self.accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
         
            guard let data = data else {
                print(String(describing: error))
                return
          }
            do
            {
                print(String(data: data, encoding: .utf8)!)
                let json = try JSON(data: data)
                let status = json["status"].stringValue
                completion(status)
                print("Success")
                
            } catch _ as NSError
            {
                print("fail")
            }
                
            
        }
        
        task.resume()
        
    }
  }


