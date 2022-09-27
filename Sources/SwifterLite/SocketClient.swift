//
//  SocketClient.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//
//  SwifterLite
//  Copyright (c) 2022 Todd Bruss. All rights reserved.
//

import Foundation

extension Socket {
    public func acceptClientSocket() throws -> Socket {
        try autoreleasepool {
            var addr = sockaddr()
            var len: socklen_t = 0
            let clientSocket = accept(self.socketFileDescriptor, &addr, &len)
            
            if clientSocket != -1 {
                Socket.setNoSigPipe(clientSocket)
                return Socket(socketFileDescriptor: clientSocket)
            } else {
                throw SocketError.acceptFailed(ErrNumString.description())
            }
        }
    }
}
