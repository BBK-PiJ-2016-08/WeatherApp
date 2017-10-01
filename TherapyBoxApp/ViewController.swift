//
//  ViewController.swift
//  TherapyBoxApp
//
//  Created by Jake Holdom on 11/09/2017.
//  Copyright © 2017 Jake Holdom. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import MessageUI



protocol HandleMapSearch {
    func moveToLocation(location:CLLocationCoordinate2D)
}

class ViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    let API_KEY = "bd5e378503939ddaee76f12ad7a97608"
    @IBOutlet var mapCityLabel: UILabel!
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var mapCountryLabel: UILabel!
    @IBOutlet var getWeatherBtn: UIButton!
    @IBOutlet var locationView: MKMapView!
    @IBOutlet var isDaily: UISwitch!
    @IBOutlet var durationCounter: UIStepper!
    @IBOutlet var weatherCollectionView: UICollectionView!
    @IBOutlet var durationLabel: UILabel!
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
    var weatherObjectsArray = Array<Weather>()
    var signInView : SignInViewController? = nil
    var signOutView : SignOutViewController? = nil
    @IBOutlet var weatherLocationLabel: UILabel!
    @IBOutlet var pinImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.locationView.delegate = self
        self.locationView.showsUserLocation = true
        self.getWeatherBtn.layer.cornerRadius = (self.getWeatherBtn.frame.height)/10
        self.isDaily.layer.cornerRadius = (self.isDaily.frame.height)/2
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.weatherLocationLabel.isHidden = true
        
        if let location = self.locationManager.location?.coordinate {
            
            moveToLocation(location: location)
        }
        
        
        pinImage.frame = CGRect.init(x: self.locationView.center.x, y: self.locationView.center.y - pinImage.frame.height, width: 28, height: 67)

        initialiseSearchController()

    }
    
    private func initialiseSearchController(){
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "SearchResults") as! SearchResultsTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        locationSearchTable.mapView = self.locationView
        locationSearchTable.handleMapSearchDelegate = self

        
    }
    

    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        displayCityFromCoordinate(coordinate: self.locationView.centerCoordinate, isBrowsing: true)
    }
    
    /**
     Checks whether the user is logged in or not, and presents either a Sign in view or Sign
     out view depending on the outcome.
     - parameters:
     - sender: button object which sends the action
     */
   @IBAction public func loginPressed(_ sender: Any) {

        if LoggedInProfile.sharedInstance.loggedIn {
            
            if (self.signInButton.isSelected) {
                
                self.signOutView?.dismiss(animated: true, completion: nil)
                navigationItem.titleView?.isHidden = false
                self.signInButton.isSelected = false;
                if LoggedInProfile.sharedInstance.username == "" {
                    LoggedInProfile.sharedInstance.loggedIn = false

                }

            }
            else{
                signOutView = storyboard?.instantiateViewController(withIdentifier: "SignOut") as? SignOutViewController
                signOutView?.modalPresentationStyle = .overCurrentContext //Allows for a opaque background to see the view behind
                signOutView?.parentView = self //Parses the current view controller instance to allow the loginPressed function to be run from the new view
                self.present(signOutView!, animated: true, completion: nil)
                navigationItem.titleView?.isHidden = true
                self.signInButton.isSelected = true;
                
            }
        }else{
            
            if (self.signInButton.isSelected) {
                
                self.signInView?.dismiss(animated: true, completion: nil)
                navigationItem.titleView?.isHidden = false
                self.signInButton.isSelected = false;
                if LoggedInProfile.sharedInstance.username != "" {
                    LoggedInProfile.sharedInstance.loggedIn = true
                    
                }

                
            }
            else{
                signInView = storyboard?.instantiateViewController(withIdentifier: "SignIn") as? SignInViewController
                signInView?.modalPresentationStyle = .overCurrentContext
                signInView?.parentView = self
                self.present(signInView!, animated: true, completion: nil)
                navigationItem.titleView?.isHidden = true
                self.signInButton.isSelected = true;
                
            }
            

        }
    
        

    
    }
    
    /**
     Checks whether the user is logged in or not, and presents either a Sign in view or Sign
     out view depending on the outcome.
     - parameters:
     - coordinate: The current coordinate located in the middle of the map view
     - isBrowsing: Determines whether the function is being run because the user clicked on the 'Get Weather' button
    or is moving around the map view in order to choose which labels get changed.
     */
    func displayCityFromCoordinate(coordinate: CLLocationCoordinate2D, isBrowsing : Bool) {
        let geocoder = CLGeocoder()
        let location = CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: Date())
        geocoder.reverseGeocodeLocation(location) { response , error in // gets the city name from the coordinates given
            
            if isBrowsing{
                if let address = response?.first {
                    
                    self.mapCityLabel.text = "City: \(address.locality ?? ("N/A"))"
                    self.mapCountryLabel.text = "Country: \(address.country ?? ("N/A"))"
                    
                }
                
            }else{
                if let address = response?.first {
                    self.weatherLocationLabel.isHidden = false
                    self.weatherLocationLabel.text = "City: \(address.locality ?? ("N/A"))"
                    
                }
                
            }
            
        }
    }
    
    /**
     Runs an API call to the OpenWeatherMap to retrieve the weather data.
     */
    @IBAction func getWeather(_ sender: Any) {
        
        self.weatherObjectsArray.removeAll() // removes all previous weather data stored in the array
        displayCityFromCoordinate(coordinate: self.locationView.centerCoordinate, isBrowsing: false)

        invokeWeatherApi(longitude: self.locationView.centerCoordinate.longitude, latitude: self.locationView.centerCoordinate.latitude, isDaily: isDaily.isOn, length: Int(self.durationCounter.value), completion: {data,_,_ in
            
            DispatchQueue.main.async { // runs on the main thread due to concurrency issues on reloading the tableview

            
            
            if let weatherArray = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [String : Any] {
                if let list = weatherArray?["list"] as? [[String : Any]] {
                    for item in list{

                        if self.isDaily.isOn{
                            
                            guard let temperature = item["temp"] as? [String: Any],
                                let date = item["dt"] as? Double,
                                let min = temperature["min"] as? Double,
                                let max = temperature["max"] as? Double,
                                let weather = item["weather"] as? [[String:Any]],
                                let weatherDescription = weather[0]["description"] as? String
                                
                                
                                else { return }
                            
                                let weatherDate = Date(timeIntervalSince1970: date)
                                let weatherObject = Weather(_date: weatherDate, _minTemp: String(min), _maxTemp: String(max), _weatherDescription: weatherDescription)
                            
                                self.weatherObjectsArray.append(weatherObject)

                            
                        }else{
                            
                            print(item)
                            guard let temperature = item["main"] as? [String: Any],
                                let date = item["dt"] as? Double,
                                let min = temperature["temp_min"] as? Double,
                                let max = temperature["temp_max"] as? Double,
                                let weather = item["weather"] as? [[String:Any]],
                                let weatherDescription = weather[0]["description"] as? String
                                
                                else { return }
                            
                                let weatherDate = Date(timeIntervalSince1970: date)
                                let weatherObject = Weather(_date: weatherDate, _minTemp: String(min), _maxTemp: String(max), _weatherDescription: weatherDescription)
                            
                            self.weatherObjectsArray.append(weatherObject)

                        }
                       

                        
                       
                        
                        
                    }
                    print(self.weatherObjectsArray)
                    self.weatherCollectionView.reloadData()

                }

                
            }
            }
        })
        
        

    }
    
    
    /**
     Invokes the API call to the openWeather map and returns the data as long as a response code of 200 is received
     - parameters:
     - longitude: The longitude number currently in the located in the middle of the mapview
     - latitude: The latitude number currently in the located in the middle of the mapview
     - isDaily: Hourly or daily weather data
     - length: The number of days or hours of data to get, taken from the UIStepper
     - completion: Completion handler which lets the function that called this method know it has finished
     */
    private func invokeWeatherApi(longitude: CLLocationDegrees, latitude : CLLocationDegrees, isDaily : Bool, length : Int, completion: @escaping (NSData?, URLResponse?, NSError?) -> Void){
        
        var url : URL? = nil
        
        if isDaily{
            url = URL(string: "https://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&cnt=\(length)&units=metric&appid=\(API_KEY)")
            
        }else{
            url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&units=metric&cnt=\((length / 3))&appid=\(API_KEY)")
            
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let request = NSURLRequest(url: url!)
        
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
    
    /**
     Updates the labels which display the number of hours or days the user wants for their weather data
     */
    @IBAction func durationChanged(_ sender: Any) {
        if isDaily.isOn {
            if durationCounter.value > 1 {
                self.durationLabel.text = "\(Int(durationCounter.value)) Days"
            }else{
                
                self.durationLabel.text = "\(Int(durationCounter.value)) Day"
            }
        }else{
            if durationCounter.value > 1 {
                self.durationLabel.text = "\(Int(durationCounter.value)) Hours"
            }else{
                
                self.durationLabel.text = "\(Int(durationCounter.value)) Hour"
            }
        }
        
    }
    

    
    
    /**
     Attempts to run a mail compose view controller as long as their is weather data available, and the user has configured
     their mail account.
     */
    @IBAction func sendEmail(_ sender: Any) {
        
        if weatherObjectsArray.count > 0 {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }else{
            
            self.showNoWeatherDataErrorAlert()
        }
        
        
        
    }

    
    /**
     Configures the counter values depending on whether the user has chosen an hourly or daily weather data type.
     */
    @IBAction func switchedTimeFrame(_ sender: Any) {
        
        if self.isDaily.isOn {
            self.durationCounter.maximumValue = 16
            self.durationCounter.minimumValue = 1
            self.durationCounter.value = 7
            self.durationCounter.stepValue = 1
        }else{
            self.durationCounter.maximumValue = 30
            self.durationCounter.minimumValue = 3
            self.durationCounter.value = 3
            self.durationCounter.stepValue = 3
        }
        
        durationChanged(self)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension ViewController : CLLocationManagerDelegate {
    /**
     Updates user location as long as the app is authorised to do so.
     */
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }

}

extension ViewController : MFMailComposeViewControllerDelegate {
    
    /**
     Initialises a new Mail controller and creates a string by looping through all of the weather data.
     */
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("The weather forecast for \(self.weatherLocationLabel.text ?? (""))...")
        
        var messageBodyString = "Hi, \nHere is the weather forecast for \(self.weatherLocationLabel.text ?? ("")) \n"
        
        for entry in self.weatherObjectsArray {
            
            messageBodyString.append("Date: \(entry.date.formatDate() ?? ("")), \n")
            messageBodyString.append("Description: \(entry.weatherDescription), \n")
            messageBodyString.append("Min Temperature: \(entry.minTemp)°C, \n")
            messageBodyString.append("Max Temperature: \(entry.maxTemp)°C \n")
            messageBodyString.append("------------------------------------------ \n")
            
        }
        mailComposerVC.setMessageBody(messageBodyString, isHTML: false)
        
        return mailComposerVC
    }
    
    /**
     Display error if the user has not configured their mail
     */
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    /**
     Display error if the user has not got any weather data to share
     */
    func showNoWeatherDataErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "No data to send", message: "Please find the weather for a location before sending an email.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

    /**
     Dismisses mail view controller on completion.
     */
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.weatherObjectsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath as IndexPath) as? WeatherCollectionViewCell
        
        cell?.descLabel.text = weatherObjectsArray[indexPath.row].weatherDescription
        cell?.minTempLabel.text = "Min: \(weatherObjectsArray[indexPath.row].minTemp)°C"
        cell?.maxTempLabel.text = "Max: \(weatherObjectsArray[indexPath.row].maxTemp)°C"
        
        
        cell?.dateLabel.text = "\(weatherObjectsArray[indexPath.row].date.formatDate() ?? ("No date found"))"
        
        
        return cell!
        
        
        
    }
    
    
    /**
     Speaks to the user telling them the weather data when they click on a cell.
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let phraseToSay = "On \(weatherObjectsArray[indexPath.row].date.formatDate() ?? ("No date found")) the forecast is set to be \(weatherObjectsArray[indexPath.row].weatherDescription) with a maximum temperature of \(weatherObjectsArray[indexPath.row].maxTemp) degrees celcius and a minimum temperature of \(weatherObjectsArray[indexPath.row].minTemp) degrees celcius" //String which will be spoken.
        let utterance = AVSpeechUtterance(string: phraseToSay)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.4
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        
    }
    
    
}

extension ViewController: HandleMapSearch {
    
    /**
     Sets the map view to zoom in on the given location
     - parameters:
     - location: Coordinates of where is needed to be zoomed in to
     */
    func moveToLocation(location:CLLocationCoordinate2D){
        
        let span = MKCoordinateSpanMake(30.00, 30.00)
        let region = MKCoordinateRegion(center: location, span: span)
        self.locationView.setRegion(region, animated: true)
      
    }
}

extension Date {
    /**
     Formats a date object into a more easily readable format.
     - returns:
     - String: Formatted date into the required String
     */

    func formatDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM - HH:mm"
        return dateFormatter.string(from: self).capitalized
    }
}

