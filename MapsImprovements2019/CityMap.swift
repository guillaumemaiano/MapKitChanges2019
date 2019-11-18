//
//  CityMap.swift
//  MapsImprovements2019
//
//  Created by guillaume MAIANO on 14/11/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import SwiftUI
import MapKit

struct CityMap: View {

    let places: [Place] = [Place(name: "Cathedral", location: .init(latitude: 50.640364, longitude: 3.062058))]
    let citymapManager = CityMapManager()

    var body: some View {
           MapView(places: places)
    }
}

struct CityMap_Previews: PreviewProvider {
    static var previews: some View {
        CityMap()
    }
}

struct MapView: UIViewRepresentable {
    
    var places: [Place]

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.640364, longitude: 3.062058), latitudinalMeters: 500.0, longitudinalMeters: 500.0), animated: false)
        map.showsUserLocation = true
        map.showsScale = true
        annotateLocalPOI(map: map)
        return map
    }
    
    func updateUIView(_ uiView:MKMapView, context: Context) {
        //
    }
    
    private func annotateLocalPOI(map: MKMapView) {
        
        let annotation = MKPointAnnotation()
        annotation.title = "Red Pin"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 50.64, longitude: 3.06)
        // add the annotation to the map (will use red pin, mapView:viewFor: allows changing the display)
        map.addAnnotation(annotation)
    }
}

// Identifiable so I may List/ForEach
struct Place: Identifiable {
    let id: UUID = UUID()
    let name: String
    let location: CLLocationCoordinate2D
}

class CityLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    
    var locationStatus = "Status not determined"
    var locationFixFound = false
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // We've (at least once) gone under a certain minimum accuracy required to consider we have a "fix"
        // we could use that to reflect that information on the UI (color, shape...)
        if !locationFixFound {
            for location in locations {
                if location.horizontalAccuracy < 25.0 {
                    locationFixFound = true
            }
        }
        
            if let coord = locations.last?.coordinate {
                print(coord.latitude)
                print(coord.longitude)
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                            didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Location manager stopped due to error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization Status changed")
        var shouldRequestLocationUpdates = false

        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldRequestLocationUpdates = true
        }

        if (shouldRequestLocationUpdates == true) {
            NSLog("Location to Allowed")
            // Start location services
            manager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
}

struct CityMapManager {
    
    let locationDelegate: CLLocationManagerDelegate
    let locationManager: CLLocationManager
    
    init() {
        locationDelegate = CityLocationManagerDelegate()
        locationManager = CLLocationManager()
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        // not sure why this exists at all
        locationManager.showsBackgroundLocationIndicator = false
    }
}
