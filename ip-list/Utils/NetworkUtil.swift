//
//  NetworkUtil.swift
//  ip-list
//
//  Created by Rodrigo Amora on 23/08/25.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import Network

class NetworkUtil {
    
    // Identifica fabricante pelo prefixo do MAC
    private func identifyManufacturer(macAddress: String?) -> String? {
        guard let mac = macAddress else { return nil }
        
        if mac.hasPrefix("00:0C:E7") { return "Nokia" }
        if mac.hasPrefix("00:17:AB") { return "Nintendo" }
        if mac.hasPrefix("00:25:00") { return "Apple" }
        if mac.hasPrefix("18:E7:F4") { return "Samsung" }
        if mac.hasPrefix("00:1A:11") { return "Google" }
        if mac.hasPrefix("00:12:17") { return "Cisco" }
        if mac.hasPrefix("74:D4:35") { return "Xiaomi" }
        return "Unknown"
    }
    
    // Identifica tipo de dispositivo
    private func identifyTypeDevice(macAddress: String?, hostname: String) -> TypeDevice {
        let host = hostname.lowercased()
        
        if host.contains("iphone") || host.contains("android") || host.contains("smartphone") {
            return .smartphone
        }
        if host.contains("printer") || host.contains("impressora") {
            return .printer
        }
        if host.contains("tv") || host.contains("samsung") || host.contains("lg") {
            return .smartTV
        }
        if host.contains("playstation") || host.contains("xbox") || host.contains("nintendo") {
            return .consoleGame
        }
        if host.contains("desktop") || host.contains("laptop") || host.contains("pc") {
            return .computer
        }
        
        // fallback pelo MAC
        if let mac = macAddress {
            if mac.hasPrefix("00:25:00") || mac.hasPrefix("18:E7:F4") || mac.hasPrefix("74:D4:35") {
                return .smartphone
            }
            if mac.hasPrefix("00:17:AB") {
                return .consoleGame
            }
            if mac.hasPrefix("00:12:17") {
                return .iotDevice
            }
        }
        
        return .unknown
    }
    
    // Pega informações da rede Wi-Fi atual
    func informationNetwork() -> NetworkWifi? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String],
              let interfaceName = interfaces.first,
              let info = CNCopyCurrentNetworkInfo(interfaceName as CFString) as? [String: AnyObject] else {
            return nil
        }
        
        let ssid = info[kCNNetworkInfoKeySSID as String] as? String
        let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String
        
        return NetworkWifi(
            ssid: ssid,
            bssid: bssid,
            strength: nil,
            frequency: nil,
            linkSpeed: nil,
            networkId: nil,
            macAddress: nil,
            ipAddress: getWiFiAddress()
        )

    }
    
    // Retorna IP local
    private func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) {
                    if let name = String(validatingUTF8: interface.ifa_name),
                       name == "en0" {
                        var addr = interface.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    // Scanner simples de IPs da rede (ping)
    func detectDevicesOnTheNetwork(timeout: TimeInterval = 1.0, completion: @escaping ([NetworkDevice]) -> Void) {
        guard let baseIP = getWiFiAddress()?.split(separator: ".").dropLast().joined(separator: ".") else {
            completion([])
            return
        }
        
        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()
        var devices: [NetworkDevice] = []
        
        for i in 1...254 {
            group.enter()
            let ip = "\(baseIP).\(i)"
            queue.async {
                let host = NWEndpoint.Host(ip)
                let connection = NWConnection(host: host, port: 80, using: .tcp)
                
                connection.stateUpdateHandler = { state in
                    switch state {
                    case .ready:
                        let device = NetworkDevice(
                            hostName: host.interface?.name ?? "",
                            ipAddress: ip,
                            isReachable: true,
                            macAddress: nil,
                            typeDevice: .unknown,
                            manufacturer: nil
                        )
                        DispatchQueue.main.async {
                            devices.append(device)
                        }
                        connection.cancel()
                        group.leave()
                    case .failed(_), .waiting(_):
                        connection.cancel()
                        group.leave()
                    default: break
                    }
                }
                
                connection.start(queue: queue)
            }
        }
        
        group.notify(queue: .main) {
            completion(devices.sorted { $0.ipAddress ?? "" < $1.ipAddress ?? "" })
        }
    }
}
