//
//  NetworkWifi.swift
//  ip-list
//
//  Created by Rodrigo Amora on 23/08/25.
//

import Foundation

struct NetworkWifi {
    let ssid: String?
    let bssid: String?
    let strength: Int?      // iOS não expõe -> pode ser nil
    let frequency: Int?     // iOS não expõe -> pode ser nil
    let linkSpeed: Int?     // iOS não expõe -> pode ser nil
    let networkId: Int?     // iOS não expõe -> pode ser nil
    let macAddress: String? // iOS não expõe -> nil ou "Não disponível"
    let ipAddress: String?
}
