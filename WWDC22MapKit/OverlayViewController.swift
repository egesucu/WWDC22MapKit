//
//  OverlayViewController.swift
//  WWDC22MapKit
//
//  Created by Ege Sucu on 16.07.2022.
//

import UIKit
import MapKit

class OverlayViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapArea()
        
        if let location = locationManager.location{
            lookForLatestLocation(location: location)
        }
        
        addOverlays()
        
    }
    
    func configureMapArea(){
        let region = MKCoordinateRegion(center: .init(latitude: 39.925533, longitude: 32.866287), span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        mapView.isZoomEnabled = true
        
    }
    
    func lookForLatestLocation(location: CLLocation){
        
        self.mapView.showsUserLocation = true
        let region = MKCoordinateRegion(center: location.coordinate, span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapView.setCenter(location.coordinate, animated: true)
        self.mapView.setRegion(region, animated: true)
    }
    
    func addOverlays(){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Market"
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error as? MKError{
                print(error.localizedDescription)
            } else if let response{
                
                let locations = response.mapItems.sorted(by: { $0.placemark.coordinate.latitude < $1.placemark.coordinate.latitude })
                
                var points : [CLLocationCoordinate2D] = []
                
                locations.forEach { item in
                    points.append(CLLocationCoordinate2DMake(item.placemark.coordinate.latitude, item.placemark.coordinate.longitude))
                }
                
                points.forEach { point in
                    let circle = MKCircle(center: point, radius: 30)
                    self.mapView.addOverlay(circle)

                }
            }
        }
    }
}

extension OverlayViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = .green
        renderer.blendMode = .plusDarker
        return renderer
    }
}
