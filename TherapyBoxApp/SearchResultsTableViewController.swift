//
//  SearchResultsTableViewController.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 14/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsTableViewController: UITableViewController {
    
    var matchingItems:[SearchLocations] = [] //Array of locations which the user may be searching for
    var mapView: MKMapView? = nil //Map view from the ViewController class
    var handleMapSearchDelegate:HandleMapSearch? = nil //Delegate which is the View Controller which allows this class to change the map view inside the View Controller class
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
}

/**
 Extension of the UISearchResultsUpdating protocol which searches every time the user updates the search bar text field.
 Parses the data received from the API into SearchLocation objects and updates the tableview
 */
extension SearchResultsTableViewController : UISearchResultsUpdating {
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        
        
        invokeLocationsApi(searchTerm: searchBarText){data,_,_ in
            DispatchQueue.main.async {
                
                if let locationsArray = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [String : Any] {
                    if let list = locationsArray?["geonames"] as? [[String : Any]] {
                        self.matchingItems.removeAll()

                        for item in list{

                            guard let long = item["lng"] as? String,
                                let lat = item["lat"] as? String,
                                let name = item["name"] as? String,
                                let countryName = item["countryName"] as? String
                                else { return }
                            
                            
                            
                            let locationObject = SearchLocations(_longitude : long, _latitude : lat, _countryName : countryName, _name : name)
                            
                            
                            self.matchingItems.append(locationObject)
                            
                        }
                        
                    }
                    
                }
                self.tableView.reloadData()

            }
        }
    }
    
    /**
     Invokes the geonames API and returns any locations which are similar to the search term. Returns the data as long as a 
     200 reponse code is received.
     - parameters:
     - searchTerm: String taken from the search bar
     */
    private func invokeLocationsApi(searchTerm: String, completion: @escaping (NSData?, URLResponse?, NSError?) -> Void){
        
        if !searchTerm.isEmpty {
            
            
            let url = URL(string: "http://api.geonames.org/searchJSON?q=\(searchTerm)&maxRows=10&startRow=0&lang=en&isNameRequired=true&username=holdom")
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            if let url = url {
                
                let request = NSURLRequest(url: url)
                
                let dataTask = session.dataTask(with: request as URLRequest) {
                    (data, response, error) in
                    if let httpResponse = response as? HTTPURLResponse {
                        switch(httpResponse.statusCode) {
                        case 200:
                            print(data)
                            completion(data! as NSData, response, error as NSError?)
                        default:
                            print("GET request not successful HTTP status code: \(httpResponse.statusCode)")
                        }
                    } else {
                        print("Error: Not a valid HTTP response")
                    }
                    
                }
                dataTask.resume()
                
            }
        }
        
    }
    
    
}



extension SearchResultsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        guard let latitude = Double(selectedItem.latitude), let longitude = Double(selectedItem.longitude) else {return}
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        handleMapSearchDelegate?.moveToLocation(location: coordinates)
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row]
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.countryName
        return cell
    }
    
}
