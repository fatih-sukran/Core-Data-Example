//
//  ViewController.swift
//  Core Data Example
//
//  Created by Fatih Şükran on 14.09.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var students: [Student] = []
    var selectStudentUUID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // add toolbar button
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(clickAddButton))
        
        fetchData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name:  addedNewStudent, object: nil)

    }
  
    @objc func fetchData() {
        
        guard let context = getManagedObjectContext() else { return }
        guard let fetchRequest = getFetchRequest(studentEntityName) else { return }
        
        do {
            let results = try context.fetch(fetchRequest)
            students.removeAll()
            for student in results as! [Student] {
                students.append(student)
            }
        } catch {
            print("Error while fetching student from core data")
        }
        tableView.reloadData()
    }
    
    // Add Button
    @objc func clickAddButton() {
        selectStudentUUID = nil
        self.performSegue(withIdentifier: detailPageSegue, sender: nil)
    }
    
    // Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = students[indexPath.row].name
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectStudentUUID = students[indexPath.row].id
        performSegue(withIdentifier: detailPageSegue, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = getManagedObjectContext() else { return }
            guard let fetchRequest = getFetchRequest(studentEntityName) else { return }
            fetchRequest.predicate = NSPredicate(format: "id = %@", students[indexPath.row].id!.uuidString)
            
            do {
                var studentResults = try context.fetch(fetchRequest) as? [Student]
                if let studentResults = studentResults, !studentResults.isEmpty {
                    context.delete(studentResults.first!)
                    try context.save()
                }
            } catch {
                print("error while deleting a student")
            }
            students.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == detailPageSegue) {
            let destinationController = segue.destination as! DetailPageViewController
            destinationController.selectedStudent = selectStudentUUID
        }
    }
    
}

