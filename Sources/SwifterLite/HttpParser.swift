//
//  HttpParser.swift
//  Swifter
// 
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//
//  SwifterLite
//  Copyright (c) 2022 Todd Bruss. All rights reserved.
//

import Foundation

enum HttpParserError: Error, Equatable {
    case invalidStatusLine(String)
    case negativeContentLength
}

public class HttpParser {
    public func readHttpRequest(_ socket: Socket) throws -> HttpRequest {
        let statusLine = try socket.readLine()
        let statusLineTokens = statusLine.components(separatedBy: " ")
        
        if statusLineTokens.count < 3 {
            throw HttpParserError.invalidStatusLine(statusLine)
        }
        
        let encodedPath = statusLineTokens[1].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? statusLineTokens[1]
        let urlComponents = URLComponents(string: encodedPath)
        
        let request = HttpRequest()
        request.method = statusLineTokens[0]
        request.path = urlComponents?.path ?? ""
        request.queryParams = urlComponents?.queryItems?.map { ($0.name, $0.value ?? "") } ?? []
        request.headers = try readHeaders(socket)
        
        if let contentLength = request.headers["content-length"],
           let contentLengthValue = Int(contentLength),
           contentLengthValue >= 0 {
           request.body = try readBody(socket, size: contentLengthValue)
        }
        
        return request
    }
    
    private func readBody(_ socket: Socket, size: Int) throws -> [UInt8] {
        try socket.read(length: size)
    }
    
    private func readHeaders(_ socket: Socket) throws -> [String: String] {
        var headers = [String: String]()
        
        while case let headerLine = try socket.readLine(), !headerLine.isEmpty {
            
            let headerTokens = headerLine.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true).map(String.init)

            if headerTokens.count == 2 {
                headers[headerTokens[0].lowercased()] = headerTokens[1].trimmingCharacters(in: .whitespaces)
            }
            
        }
        
        return headers
    }
    
    func supportsKeepAlive(_ headers: [String: String]) -> Bool {
        guard let value = headers["connection"] else { return false }
        return "keep-alive" == value.trimmingCharacters(in: .whitespaces)
    }
}
