//
//  Utilities.swift
//  Q3ServerBrowser
//
//  Created by Andrea Giavatto on 16/07/2017.
//
//

import Foundation

/// Convert a sockaddr structure into an IP address string and port.
func getEndpointFromSocketAddress(socketAddressPointer: inout sockaddr_storage) -> (host: String, port: Int)? {
    
    switch Int32(socketAddressPointer.ss_family) {
    case AF_INET:
        var socketAddressInet = withUnsafePointer(to: &socketAddressPointer) {
            $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                $0.pointee
            }
        }
        let length = Int(INET_ADDRSTRLEN) + 2
        var buffer = [CChar](repeating: 0, count: length)
        let hostCString = inet_ntop(AF_INET, &socketAddressInet.sin_addr, &buffer, socklen_t(length))
        let port = Int(UInt16(socketAddressInet.sin_port).byteSwapped)
        return (String(cString: hostCString!), port)
        
    case AF_INET6:
        var socketAddressInet6 = withUnsafePointer(to: &socketAddressPointer) {
            $0.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) {
                $0.pointee
            }
        }
        let length = Int(INET6_ADDRSTRLEN) + 2
        var buffer = [CChar](repeating: 0, count: length)
        let hostCString = inet_ntop(AF_INET6, &socketAddressInet6.sin6_addr, &buffer, socklen_t(length))
        let port = Int(UInt16(socketAddressInet6.sin6_port).byteSwapped)
        return (String(cString: hostCString!), port)
        
    default:
        return nil
    }
}
