//
//  Request.swift
//  test-reader
//
//  Created by kyo ago on 2018/10/02.
//  Copyright © 2018 kyo ago. All rights reserved.
//

import Foundation

class Request {
    let session: URLSession = URLSession.shared
    func get(url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}
