//
//  SocketTcp.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//
//  SwifterLite
//  Copyright (c) 2022 Todd Bruss. All rights reserved.
//

import Foundation

extension Socket {
    
    /// - Parameters:
    ///   - listenAddress: String representation of the address the socket should accept
    ///       connections from. It should be in IPv4 format if forceIPv4 == true,
    ///       otherwise - in IPv6.
    public class func tcpSocketForListen(_ port: in_port_t,_ maxPendingConnection: Int32 = SOMAXCONN) throws -> Socket {
        
        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        
        if socketFileDescriptor == -1 {
            throw SocketError.socketCreationFailed(ErrNumString.description())
        }
        
        var value: Int32 = 1
        if setsockopt(socketFileDescriptor, SOL_SOCKET, SO_REUSEADDR, &value, socklen_t(MemoryLayout<Int32>.size)) == -1 {
            let details = ErrNumString.description()
            Socket.close(socketFileDescriptor)
            throw SocketError.socketSettingReUseAddrFailed(details)
        }
        Socket.setNoSigPipe(socketFileDescriptor)
        
        var bindResult: Int32 = -1
        
        var addr = sockaddr_in (
            sin_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin_family: UInt8(AF_INET),
            sin_port: port.bigEndian,
            sin_addr: in_addr(s_addr: in_addr_t(0)),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )

        bindResult = withUnsafePointer(to: &addr) {
            bind(socketFileDescriptor, UnsafePointer<sockaddr>(OpaquePointer($0)), socklen_t(MemoryLayout<sockaddr_in>.size))
        }
        
        if bindResult == -1 {
            let details = ErrNumString.description()
            Socket.close(socketFileDescriptor)
            throw SocketError.bindFailed(details)
        } else if listen(socketFileDescriptor, maxPendingConnection) == -1 {
            let details = ErrNumString.description()
            Socket.close(socketFileDescriptor)
            throw SocketError.listenFailed(details)
        }
        
        return Socket(socketFileDescriptor: socketFileDescriptor)
    }
}
