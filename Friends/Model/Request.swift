//
//  Request.swift
//  Friends
//
//  Created by SANGMIN YEOM on 2021/12/27.
//

import UIKit

let placeHolderImage: UIImage? = UIImage(named: "placeholder")

struct Response: Codable {
    let friends: [Person]
    
    enum CodingKeys: String, CodingKey {
        case friends = "results"
    }
}

struct Request {
    private static let friendsURL: URL = URL(string: "https://randomuser.me/api/1.1/?inc=name,nat,cell,picture&format=json&results=50&noinfo")!
    
    private static let imageDispatchQueue: DispatchQueue = DispatchQueue(label: "image")
    
    private static var cachedImage: [URL:UIImage] = [:]
}

extension Request {
    static func friends(_ completion: @escaping (_ friends: [Person]?)-> Void) {
        let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let dataTask: URLSessionDataTask = session.dataTask(with: friendsURL) { (data:Data?, response:URLResponse?, error:Error?) in
            
            defer {
                DispatchQueue.main.async {
                    //UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
            guard let data = data else {
                print("전달받은 데이터 없음")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let decodeResponse:Response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.async {
                    completion(decodeResponse.friends)
                }
            } catch {
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
}

extension Request {
    static func image(_ url:URL, completion: @escaping (_ image:UIImage?)->Void) {
        if let cachedImage: UIImage = self.cachedImage[url] {
            DispatchQueue.main.async {
                completion(cachedImage)
                return
            }
        }
        
       // UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        imageDispatchQueue.async {
            defer {
                DispatchQueue.main.async {
                    //UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
            guard let data: Data = try? Data(contentsOf: url) else {
                print("데이터- 이미지 변환 실패")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let image:UIImage? = UIImage(data: data)
            cachedImage[url] = image
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
