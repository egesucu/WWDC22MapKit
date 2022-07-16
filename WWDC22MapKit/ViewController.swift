//
//  ViewController.swift
//  WWDC22MapKit
//
//  Created by Ege Sucu on 15.07.2022.
//

import UIKit
import MapKit


class ViewController: UIViewController {
    
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mapTypeSelector: UISegmentedControl!
    
    let locationManager = CLLocationManager()
    
    var foundLocations : [MKMapItem] = []
    var foundAnnotations : [MKAnnotation] = []
    var selectedAnnotation: MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        askUserLocation()
        
        configureMapArea()
        configureSegmentedControl()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let location = locationManager.location{
            lookForLatestLocation(location: location)
        }
    }
    
    func askUserLocation(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    func lookForLatestLocation(location: CLLocation){
        
        self.mapView.showsUserLocation = true
        let region = MKCoordinateRegion(center: location.coordinate, span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapView.setCenter(location.coordinate, animated: true)
        self.mapView.setRegion(region, animated: true)
    }
    
    func configureSegmentedControl(){
        mapTypeSelector.addTarget(self, action: #selector(selectionChanged), for: .valueChanged)
    }
    
    @objc func selectionChanged(){
        switch mapTypeSelector.selectedSegmentIndex{
        case 0:
            mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
        case 1:
            mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
        case 2:
            mapView.preferredConfiguration = MKImageryMapConfiguration(elevationStyle: .realistic)
        default:
            break
        }
    }
    
    func configureMapArea(){
        let region = MKCoordinateRegion(center: .init(latitude: 39.925533, longitude: 32.866287), span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        mapView.isZoomEnabled = true
        
    }
    
    func searchPlace(){
        mapView.removeAnnotations(foundAnnotations)
        foundAnnotations.removeAll()
        foundLocations.removeAll()
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchField.text
        request.region = MKCoordinateRegion(center: mapView.centerCoordinate, span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05))
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error as? MKError{
                print(error.localizedDescription)
            } else if let response {
                self.foundLocations = response.mapItems
                self.addPlacesToAnnotations()
            }
            search.cancel()
        }
        
    }
    
    func addPlacesToAnnotations(){
        for location in foundLocations{
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.placemark.coordinate
            annotation.title = location.name ?? ""
            self.foundAnnotations.append(annotation)
        }
        self.mapView.addAnnotations(foundAnnotations)
    }

}

extension ViewController : CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse{
            if let location = manager.location{
                self.mapView.showsUserLocation = true
                let region = MKCoordinateRegion(center: location.coordinate, span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005))
                self.mapView.setCenter(location.coordinate, animated: true)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            lookForLatestLocation(location: location)
        }
    }
}


extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let view = MKMarkerAnnotationView()
        view.animatesWhenAdded = true
        view.annotation = annotation
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if annotation is MKUserLocation { return }
        if annotation is MKMapFeatureAnnotation { return }
        selectedAnnotation = annotation
        presentWithSheet(item: annotation)
    }
    
    func presentWithSheet(item: MKAnnotation){
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MarkerDetailViewController") as? MarkerDetailViewController else { return }
        vc.selectedItem = foundLocations.filter({ $0.placemark.coordinate == item.coordinate }).first
        if let sheet = vc.sheetPresentationController {
            sheet.delegate = self
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
    
    
}

extension ViewController: UISheetPresentationControllerDelegate{
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let selectedAnnotation{
            mapView.deselectAnnotation(selectedAnnotation, animated: true)
            self.selectedAnnotation = nil
        }
    }
}

extension ViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text,
           !text.isEmpty{
            textField.resignFirstResponder()
            searchPlace()
        }
        return true
    }
    
}

extension CLLocationCoordinate2D : Equatable{
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude)
    }
    
    
    
}
