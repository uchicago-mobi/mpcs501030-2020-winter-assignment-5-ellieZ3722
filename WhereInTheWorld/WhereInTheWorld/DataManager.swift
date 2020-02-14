//
//  DataModel.swift
//  WhereInTheWorld
//
//  Created by Kiwiinthesky72 on 2/9/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import Foundation
import MapKit

public class DataManager {
  
    public static let sharedInstance = DataManager()
    var annotations: [String: Place] = [:]
    let defaults = UserDefaults.standard
    
    fileprivate init() {}

    func loadAnnotationFromPlist(mapView: MKMapView) {
        var nsDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: "Data", ofType: "plist") {
           nsDictionary = NSDictionary(contentsOfFile: path)
        }
        
        let placeArray: NSArray? = nsDictionary?.object(forKey: "places") as? NSArray
        
        //store the favorites into the user default
        let favorites = defaults.array(forKey: "favorites")
        if favorites == nil {
            let array: [String] = []
            defaults.set(array, forKey:"favorites")
        }
        
        if let placeArray = placeArray {
            for (place) in placeArray {
                let placeName: String? = (place as AnyObject).object(forKey: "name") as? String
                let placeDescription: String? = (place as AnyObject).object(forKey: "description") as? String
                let latitude: Double? = (place as AnyObject).object(forKey: "lat") as? Double
                let longitude: Double? = (place as AnyObject).object(forKey: "long") as? Double
                
                var coordinate: CLLocationCoordinate2D? = nil
                if let latitude = latitude, let longitude = longitude {
                    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                
                if let coordinate = coordinate, let placeName = placeName, let placeDescription = placeDescription {
                    let spot = Place(__coordinate: coordinate)
                    spot.title = placeName
                    spot.name = placeName
                    spot.longDescription = placeDescription
                    spot.latitude = latitude
                    spot.longitude = longitude
                    //adding the annotation to the mapview
                    mapView.addAnnotation(spot)
                    
                    //adding the annotations into a array to store the information
                    annotations[placeName] = spot
                    
                }
            }
        }
    }
    
    func saveFavorites(name: String) {
        var favorites = defaults.array(forKey: "favorites") as! [String]
        favorites.append(name)
        defaults.set(favorites, forKey: "favorites")
    }
    
    func deleteFavorite(name: String) {
        var favorites = defaults.array(forKey: "favorites") as! [String]
        for i in 0...favorites.count - 1 {
            if favorites[i] == name {
                favorites.remove(at: i)
                defaults.set(favorites, forKey: "favorites")
            }
        }
    }
    
    func listFavorites() -> [String] {
        return defaults.array(forKey: "favorites") as! [String]
    }
}
