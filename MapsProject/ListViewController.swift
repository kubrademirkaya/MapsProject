//
//  ListViewController.swift
//  MapsProject
//
//  Created by Kübra Demirkaya on 2.12.2022.
//

import UIKit
import CoreData

/*extension ListViewController: UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "toDetailsVC") as! DetailsViewController
        let item = indexPath.row
        vc.selectedId = idSeries[item]
        vc.selectedName = nameSeries[item]
        vc.onDelete = { [weak self]  in
            self?.nameSeries.remove(at: item)
            self?.idSeries.remove(at: item)
            //collectionView.deleteItems(at: [indexPath])
            print("deleted")
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}*/

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var nameSeries = [String]()
    var idSeries = [UUID]()
    var selectedLocationName = ""
    var selectedLocationId : UUID?
    
    var deleteItem: (() -> Void)?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        fetchData()
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: NSNotification.Name("NewLocationAdded"), object: nil)
    }
 
    /*func tableView(_ tableView: UITableView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "toDetailsVC") as! DetailsViewController
        vc.selectedId = idSeries[indexPath.row]
        vc.selectedName = nameSeries[indexPath.row]
        vc.onDelete = { [weak self]  in
            self?.nameSeries.remove(at: indexPath.row)
            self?.idSeries.remove(at: indexPath.row)
            self?.tableView.reloadData()
            print("deleted")
        }
        navigationController?.pushViewController(vc, animated: true)
    }*/
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
            let uuidString = idSeries[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id == %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idSeries[indexPath.row] {
                                context.delete(result)
                                nameSeries.remove(at: indexPath.row)
                                idSeries.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                    print("silindi")
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
    
    @objc func fetchData() {
        
        nameSeries.removeAll(keepingCapacity: false)
        idSeries.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameSeries.append(name)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        idSeries.append(id)
                    }
              
                }
                
            }
            
            tableView.reloadData()
            
        } catch {
            print("hata var")
        }
    }
    
    @objc func addButtonClicked() {
        selectedLocationName = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameSeries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameSeries[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.selectedName = selectedLocationName
            destinationVC.selectedId = selectedLocationId
        }
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectedName = selectedLocationName
            destinationVC.selectedId = selectedLocationId
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocationName = nameSeries[indexPath.row]
        selectedLocationId = idSeries[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
        /*let detailsViewController = DetailsViewController()
        detailsViewController.delegate = self
        
        detailsViewController.selectedId = idSeries[indexPath.row]
        detailsViewController.selectedName = nameSeries[indexPath.row]
        
        func deleteItem() {
            self.nameSeries.remove(at: indexPath.row)
            self.idSeries.remove(at: indexPath.row)
            self.tableView.reloadData()
            print("deleted")
        }
        navigationController?.pushViewController(detailsViewController, animated: true)*/
        
    }
    
    /*func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let detailsViewController = DetailsViewController()
        detailsViewController.delegate = self
        
        detailsViewController.selectedId = idSeries[indexPath.row]
        detailsViewController.selectedName = nameSeries[indexPath.row]
        
        func deleteItem() {
            self.nameSeries.remove(at: indexPath.row)
            self.idSeries.remove(at: indexPath.row)
            self.tableView.reloadData()
            print("deleted")
        }
        navigationController?.pushViewController(detailsViewController, animated: true)
    }*/
    
    
    
    

}

