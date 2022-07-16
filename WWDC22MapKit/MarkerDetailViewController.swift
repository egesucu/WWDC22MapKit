//
//  MarkerDetailViewController.swift
//  WWDC22MapKit
//
//  Created by Ege Sucu on 15.07.2022.
//

import UIKit
import MapKit

class MarkerDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    

    var selectedItem : MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedItem{
            titleLabel.text = selectedItem.name ?? ""
            contentLabel.text = selectedItem.placemark.title ?? ""
        }
        
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
    }
    
    @objc func buttonTapped(){
        if let selectedItem{
            selectedItem.openInMaps()
        }
    }

}
