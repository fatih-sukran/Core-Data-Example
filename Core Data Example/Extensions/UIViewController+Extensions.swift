//
//  UIViewController+Extensions.swift
//  Core Data Example
//
//  Created by fatih.sukran on 23.09.2023.
//

import UIKit
import CoreData

extension UIViewController {
    
    func getManagedObjectContext() -> NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }
    
    func getFetchRequest(_ entityName: String) -> NSFetchRequest<NSFetchRequestResult>? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        return fetchRequest
    }
}
