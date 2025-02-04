//
//  HttpRespBody.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//
//  SwifterLite
//  Copyright (c) 2022 Todd Bruss. All rights reserved.
//

import Foundation

public enum HttpResponseBody {
    
    case json(Any,     contentType: String? = "application/json")
    case ping(String,  contentType: String? = "text/plain")
    case data(Data,    contentType: String? = nil)
    case byts([UInt8], contentType: String? = nil)

    func content() -> httpWriter {
        do {
            switch self {
            case .data(let data, _):
                return (data.count, {
                    try $0.write(data: data)
                })
            case .byts(let bytes, _):
                return (bytes.count, {
                    try $0.write(byts: bytes)
                })
            case .json(let object, _):
                let data = try JSONSerialization.data(withJSONObject: object)
                return (data.count, {
                    try $0.write(data: data)
                })
            case .ping(let body, _):
                let data = [UInt8](body.utf8)
                return (data.count, {
                    try $0.write(byts: data)
                })
            }
        } catch {
            let data = [UInt8]("Http error: \(error)".utf8)
            return (data.count, {
                try $0.write(byts: data)
            })
        }
    }
}
