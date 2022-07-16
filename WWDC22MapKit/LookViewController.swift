//
//  LookViewController.swift
//  WWDC22MapKit
//
//  Created by Ege Sucu on 16.07.2022.
//

import UIKit
import MapKit

class LookViewController: UIViewController {
    
    @IBOutlet weak var lookView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedScene : MKLookAroundScene?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.339688, longitude: -6.236688), span: .init(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
        
        mapView.selectableMapFeatures = [.physicalFeatures,.pointsOfInterest,.territories]
        
        lookView.isHidden = true
        lookView.layer.masksToBounds = true
        lookView.layer.cornerRadius = 10
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MKLookAroundViewController{
            vc.scene = selectedScene
        }
    }
    
}

extension LookViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        let sceneRequest = MKLookAroundSceneRequest(coordinate: annotation.coordinate)
        sceneRequest.getSceneWithCompletionHandler { scene, error in
            if let error{
                print("Not Found Error", error)
                self.lookView.isHidden = true
            } else if let scene{
                self.lookView.isHidden = false
                self.selectedScene = scene
                let lookAroundViewController = self.children.compactMap { $0 as? MKLookAroundViewController }.first
                if let lookAroundViewController{
                    lookAroundViewController.scene = scene
                    lookAroundViewController.delegate = self
                }

            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
        self.selectedScene = nil
        self.lookView.isHidden = true
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let markerView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "LookAroundPlace")
        markerView.animatesWhenAdded = true
        markerView.titleVisibility = .adaptive
        return markerView
    }
}

extension LookViewController: MKLookAroundViewControllerDelegate{
    func lookAroundViewControllerWillUpdateScene(_ viewController: MKLookAroundViewController) {
        viewController.scene = selectedScene
    }
    
    func lookAroundViewControllerDidUpdateScene(_ viewController: MKLookAroundViewController) {
        viewController.scene = selectedScene
    }
}
