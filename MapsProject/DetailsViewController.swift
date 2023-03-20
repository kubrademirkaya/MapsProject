//
//  DetailsViewController.swift
//  MapsProject
//
//  Created by Kübra Demirkaya on 10.03.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class DetailsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var selectedName = ""
    var selectedId : UUID?
  
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    let listViewController = ListViewController()
    weak var delegate: ListViewController?
    
    //var onDelete: (() -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        
        //fetchData()
        
        if selectedName != "" {
            if let uuidString = selectedId?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        
                        for result in results as! [NSManagedObject] {
                            if let name = result.value(forKey:  "name") as? String {
                                annotationTitle = name
                                
                                if let comment = result.value(forKey: "comment") as? String {
                                    annotationSubtitle = comment
                                    
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        
                                        if let longitude = result.value(forKey: "longitude") as? Double {
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            locationNameLabel.text = annotationTitle
                                            commentLabel.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                            
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                } catch {
                    
                }
                
                
            }
        } else {
            print("hata var")
        }
        
    }
   
    
    
    /*@objc func fetchData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.predicate = NSPredicate(format: "id == %@", selectedId! as CVarArg)
        request.returnsObjectsAsFaults = false
        
        
        
        do {
            let results = try context.fetch(request)
            for result in results as! [NSManagedObject] {
                if let id = result.value(forKey: "id") as? UUID {
                    print("sonuç:", id)
                }
                if let name = result.value(forKey: "name") as? String {
                    print("sonuç2:", name)
                    selectedName = name
                    self.locationNameLabel.text = selectedName
                }
                if let comment = result.value(forKey: "comment") as? String {
                    print("sonuç2:", comment)
                    self.commentLabel.text = comment
                }
                if let latitude = result.value(forKey: "latitude") as? Double {
                    self.annotationLatitude = latitude
                    print(annotationLatitude)
                }
                if let longitude = result.value(forKey: "longitude") as? Double {
                    self.annotationLongitude = longitude
                    print(annotationLongitude)
                }
            }
            
        } catch {
            print("hata var")
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.selectedName = selectedName
            destinationVC.selectedId = selectedId
            destinationVC.annotationLatitude = annotationLatitude
            destinationVC.annotationLongitude = annotationLongitude
            destinationVC.annotationTitle = annotationTitle
            destinationVC.annotationSubtitle = annotationSubtitle
        }
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let uuidString = selectedId
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuidString! as CVarArg)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? UUID {
                        if id == selectedId {
                            delegate?.deleteItem!()
                            context.delete(result)
                            
                            
                            
                            
                            let alert = UIAlertController(title: "Successfully", message: "Data successfully deleted.", preferredStyle: .alert)
                            let okButton = UIAlertAction(title: "OK", style: .default) { UIAlertAction in
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                            alert.addAction(okButton)
                            self.present(alert, animated: true)
                            
                            
                            
                            
                            do {
                                try context.save()
                            } catch {
                                
                            }
                            break
                        }
                    }
                }
            }
        } catch {
            
        }
        
        
    }
    
}
