//
//  DetailPageViewController.swift
//  Core Data Example
//
//  Created by fatih.sukran on 22.09.2023.
//

import UIKit
import CoreData

class DetailPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var image: CustomImageView!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var surnameInput: UITextField!
    @IBOutlet weak var birthYearInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var selectedStudent: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let uuid = selectedStudent {
            
            guard let context = getManagedObjectContext() else { return }
            guard let fetchRequest = getFetchRequest(studentEntityName) else { return }
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuid.uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest) as? [Student]
                if let results = results, !results.isEmpty {
                    let student = results.first!
                    nameInput.text = student.name
                    surnameInput.text = student.surname
                    birthYearInput.text = String(student.year)
                    image.image = UIImage(data: student.image!)
                }
            } catch {
                print("Error while fetch student")
            }
        }
        
        // Hide Keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(gestureRecognizer)
        
        // Select Image
        image.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        image.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true)
    }
    
    @IBAction func clickSaveButton(_ sender: UIButton) {
        
        guard let context = getManagedObjectContext() else { return }
        let student = NSEntityDescription.insertNewObject(forEntityName: studentEntityName, into: context)
        Student.validateForInsert(<#T##self: NSManagedObject##NSManagedObject#>)
        student.setValue(UUID(), forKey: "id")
        student.setValue(nameInput.text, forKey: "name")
        student.setValue(surnameInput.text, forKey: "surname")
        
        let year = Int(birthYearInput.text ?? "0")
        student.setValue(year, forKey: "year")
        
        let imageData = image.image?.jpegData(compressionQuality: 0.1)
        student.setValue(imageData, forKey: "image")
        
        do {
            try context.save()
            print("Success")
        } catch {
            print("error", error)
        }
        
        NotificationCenter.default.post(name: addedNewStudent, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
