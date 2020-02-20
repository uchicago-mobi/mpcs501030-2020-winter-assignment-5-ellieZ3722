//
//  MapViewController.swift
//  WhereInTheWorld
//
//  Created by Kiwiinthesky72 on 2/9/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import UIKit
import MapKit

protocol PlacesFavoritesDelegate: class {
  func favoritePlace(name: String) -> Void
}

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var locationTitle: UILabel!
    @IBOutlet var locationDescription: UITextView!
    @IBOutlet var locationView: UIView!
    @IBOutlet var starButton: UIButton!
    
    @IBOutlet var favoriteButton: UIButton!
    
    let emptyStarImage = UIImage(systemName: "star")?.withTintColor(UIColor.yellow)
    let filledStarImage = UIImage(systemName: "star.fill")?.withTintColor(UIColor.yellow)
    
    let defaults = UserDefaults.standard
    
    var originLatitude: Double?
    var originLongitude: Double?
    var latDelta: Double?
    var longDelta: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initializing the point of interest view
        locationView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        locationTitle.textColor = UIColor.white
        locationDescription.textColor = UIColor.white
        locationView.isHidden = true
        
        locationTitle.lineBreakMode = .byWordWrapping
        locationTitle.numberOfLines = 0
    
        starButton.setImage(emptyStarImage, for: .normal)
        starButton.tintColor = UIColor.yellow
        starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
        
        //setting the favorite button at bottom
        favoriteButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        favoriteButton.tintColor = UIColor.yellow
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //initializing the map view
        mapView.delegate = self
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        
        loadOriginalSpot()
        
        DataManager.sharedInstance.loadAnnotationFromPlist(mapView: mapView)
    }
    
    //load the original point from the data plist
    func loadOriginalSpot() {
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Data", ofType: "plist") {
           nsDictionary = NSDictionary(contentsOfFile: path)
        }
        let regionArray: NSArray? = nsDictionary?.object(forKey: "region") as? NSArray
        
        if let regionArray = regionArray {
            originLatitude = regionArray[0] as? Double
            originLongitude = regionArray[1] as? Double
            latDelta = regionArray[2] as? Double
            longDelta = regionArray[3] as? Double
            
            if let latitude = originLatitude, let longitude = originLongitude, let latDelta = latDelta, let longDelta = longDelta {
                let zoomLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                let viewRegion = MKCoordinateRegion(center: zoomLocation, span: span)
                mapView.setRegion(viewRegion, animated: true)
            }
            
        }
    }
    
    //implement the star and unstar function
    @objc func starTapped(_ button: UIButton) {
        let name = locationTitle.text!
        let favorites = defaults.array(forKey: "favorites") as! [String]
        if favorites.contains(name) {
            DataManager.sharedInstance.deleteFavorite(name: name)
            starButton.setImage(emptyStarImage, for: .normal)
        } else {
            DataManager.sharedInstance.saveFavorites(name: name)
            starButton.setImage(filledStarImage, for: .normal)
        }
    }
    
    //implement the popup of the information view with the updated information
    func updateLocationView(name: String) {
        locationTitle.text = name
        locationDescription.text = DataManager.sharedInstance.annotations[name]?.longDescription
        
        let favorites = defaults.array(forKey: "favorites") as! [String]
        if favorites.contains(name) {
            starButton.setImage(filledStarImage, for: .normal)
        } else {
            starButton.setImage(emptyStarImage, for: .normal)
        }

        locationView.isHidden = false
    }
    
    //when any spot outside the information view is tapped , the information view is dismissed
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         let touch = touches.first
         if touch?.view != locationView {
            locationView.isHidden = true
        }
    }
    
    //setting up the delegate for the FavoritesViewController
    override func prepare(for segue: UIStoryboardSegue,
                 sender: Any?) {
        if segue.identifier == "show", let fvc = segue.destination as? FavoritesViewController {
            fvc.delegate = self
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? Place {
            
            let identifier = "Place"
            var markerView: PlaceMarkerView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlaceMarkerView {
                dequeuedView.annotation = annotation
                markerView = dequeuedView
            } else {
                markerView = PlaceMarkerView(annotation: annotation, reuseIdentifier: "Place")
                markerView.canShowCallout = false
            }
            return markerView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotationView: MKAnnotationView) {
        if let annotation = annotationView.annotation as? Place {
            updateLocationView(name: annotation.name!)
        }
    }
    
}

extension MapViewController: PlacesFavoritesDelegate {
    func favoritePlace(name: String) {
        //move the center of the map to the selected annotation
        let annotation = DataManager.sharedInstance.annotations[name]!
        if let latitude = annotation.latitude, let longitude = annotation.longitude, let latDelta = latDelta, let longDelta = longDelta {
            let zoomLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let viewRegion = MKCoordinateRegion(center: zoomLocation, span: span)
            mapView.setRegion(viewRegion, animated: true)
        }
        
        //update the information on the info view for display
        updateLocationView(name: name)
    }
}

