//
//  PlaceMarkerView.swift
//  WhereInTheWorld
//
//  Created by Kiwiinthesky72 on 2/9/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import UIKit
import MapKit

class PlaceMarkerView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            clusteringIdentifier = "Place"
            displayPriority = .defaultLow
            markerTintColor = .systemYellow
            glyphImage = UIImage(systemName: "pin.fill")
        }
    }

}
