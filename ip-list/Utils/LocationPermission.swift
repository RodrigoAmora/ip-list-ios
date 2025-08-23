//
//  LocationPermission.swift
//  ip-list
//
//  Created by Rodrigo Amora on 23/08/25.
//

import CoreLocation

class LocationPermission: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    func request() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Localização permitida, SSID poderá ser acessado")
        case .denied, .restricted:
            print("❌ Permissão de localização negada")
        case .notDetermined:
            print("⌛ Permissão de localização ainda não escolhida")
        @unknown default:
            break
        }
    }
}
