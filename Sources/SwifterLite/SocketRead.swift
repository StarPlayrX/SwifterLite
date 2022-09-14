//
//  SocketRead.swift
//  Swifter
//
//  Copyright (c) 2014-2016 Damian Kołakowski. All rights reserved.
//

import Foundation

extension Socket {
    /// Read a single byte off the socket. This method is optimized for reading
    /// a single byte. For reading multiple bytes, use read(length:), which will
    /// pre-allocate heap space and read directly into it.
    ///
    /// - Returns: A single byte
    /// - Throws: SocketError.recvFailed if unable to read from the socket
    open func read(byte: inout UInt8) throws {
        Darwin.read(self.socketFileDescriptor as Int32, &byte, 1)
    }
    
    /// Read up to `length` bytes from this socket
    ///
    /// - Parameter length: The maximum bytes to read
    /// - Returns: A buffer containing the bytes read
    /// - Throws: SocketError.recvFailed if unable to read bytes from the socket
    open func read(length: Int) throws -> [UInt8] {
        return try [UInt8](unsafeUninitializedCapacity: length) { buffer, bytesRead in
            bytesRead = try read(into: &buffer, length: length)
        }
    }
    
    /// Read up to `length` bytes from this socket into an existing buffer
    ///
    /// - Parameter into: The buffer to read into (must be at least length bytes in size)
    /// - Parameter length: The maximum bytes to read
    /// - Returns: The number of bytes read
    /// - Throws: SocketError.recvFailed if unable to read bytes from the socket
    func read(into buffer: inout UnsafeMutableBufferPointer<UInt8>, length: Int) throws -> Int {
        var offset = 0
        guard let baseAddress = buffer.baseAddress else { return 0 }
        
        while offset < length {
            // Compute next read length in bytes. The bytes read is never more than kBufferLength at once.
            let readLength = offset + Socket.kBufferLength < length ? Socket.kBufferLength : length - offset
            let bytesRead = Darwin.read(self.socketFileDescriptor as Int32, baseAddress + offset, readLength)
            
            guard bytesRead > 0 else {
                throw SocketError.recvFailed(ErrNumString.description())
            }
            
            offset += bytesRead
        }
        
        return offset
    }
    
    public func readLine() throws -> String {
        var s: String = ""
        var b: UInt8 = 0
        repeat {
            try self.read(byte: &b)
            if b > Socket.CR {
                s.append(Character(UnicodeScalar(b)))
            }
        } while b != Socket.NL
        
        return s
    }
}
