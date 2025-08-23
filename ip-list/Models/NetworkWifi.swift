//
//  NetworkWifi.swift
//  ip-list
//
//  Created by Rodrigo Amora on 23/08/25.
//

import Foundation

class NetworkWifi {
    var ssid: String = ""
    var bssid: String?
    var strength: Int? // em dBm
    var frequency: Int? // em MHz
    var linkSpeed: Int? // em Mbps
    var networkId: Int?
    var macAddress: String?
    var ipAddress: Int?
}
