//
//  FavoritesViewController.swift
//  WhereInTheWorld
//
//  Created by Kiwiinthesky72 on 2/9/20.
//  Copyright © 2020 Kiwiinthesky72. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var dismissButton: UIButton!
    
    @IBOutlet var tableView: UITableView!
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var placeNames: [String]?
    weak var delegate: PlacesFavoritesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dismissButton.backgroundColor = UIColor.gray
        
        placeNames = UserDefaults.standard.array(forKey: "favorites") as? [String]
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let placeNames = placeNames {
            return placeNames.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Location", for: indexPath)
        if let placeNames = placeNames {
            cell.textLabel?.text = placeNames[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        if let placeNames = placeNames {
            delegate?.favoritePlace(name: placeNames[indexPath.row])
        }
    }


}
