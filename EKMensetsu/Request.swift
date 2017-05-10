//
//  Request.swift
//  EKMensetsu
//
//  Created by 成沢淳史 on 2017/04/28.
//  Copyright © 2017 naru. All rights reserved.
//

import Foundation


class Request {
    private var url : URL!
    var request : URLRequest!
    var return_data : NSString?
    
    
    init(url : URL) {
        self.url = url
        self.request = URLRequest.init(url: url)
    }
    
    func get() {
        request.httpMethod = "GET"
    }
    
    func get(_ params : Dictionary<String, String>) {
        request.httpMethod = "GET"
        url_with_params(params)
        print(self.url)
        
    }
    
    func post(_ files : Dictionary<String, Data>) {
        request.httpMethod = "POST"
        let boundary  = randomStringWithLength(29)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = dataWithDictionary(files as NSDictionary, boundary: boundary as String)
        request.httpBody = data
        
    }   
    
    func post(_ params : Dictionary<String, String>, files : Dictionary<String, Data>) {
        request.httpMethod = "POST"
        url_with_params(params)
        request.httpMethod = "POST"
        let boundary  = randomStringWithLength(29)
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = dataWithDictionary(files as NSDictionary, boundary: boundary as String)
        request.httpBody = data
    }
    
    private func url_with_params(_ params: Dictionary<String, String>) {
        var base = self.url.absoluteString
        base = base + "?"
        var i = 0
        for (key, val) in params {
            i = i + 1
            base = "\(base)\(key)=\(val)"
            if (i == params.count) {
                break
            } else {
                base = base + "&"
            }
        }
        self.url = URL(string: base)!
        self.request = URLRequest.init(url: self.url)
    }
    
    
    
    //Dictionary から http の body を生成します
    private func dataWithDictionary(_ files : NSDictionary?, boundary: String?) -> Data? {
        let data = NSMutableData()
        var i = 0
        data.append(str2data("--\(boundary!)\n"))
        for (key, val) in files! {
            i = i+1
            data.append( str2data("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)\"\n\n") )
            data.append(val as! Data)
            data.append(str2data("\n"))
            if files!.count != i {
                data.append(str2data("--\(boundary!)\n"))
            } else {
                data.append(str2data("--\(boundary!)"))
                break
            }
        }
        data.append(str2data("--\n"))
        return data as Data
    }
    
    // String -> NSData
    private func str2data(_ str : String) -> Data {
        return str.data(using: .utf8)!
    }
    
    // ランダムな文字列を獲得します
    private func randomStringWithLength (_ len : Int) -> NSString {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for _ in 0 ..< len
        {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    
    
}

