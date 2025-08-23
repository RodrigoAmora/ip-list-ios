//
//  TypeDevice.swift
//  ip-list
//
//  Created by Rodrigo Amora on 23/08/25.
//

import Foundation

enum TypeDevice: String, Decodable {
    case smartphone
    case printer
    case smartTV
    case consoleGame
    case computer
    case iotDevice
    case unknown
}
