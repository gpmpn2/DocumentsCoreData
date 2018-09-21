//
//  Note.swift
//  DocumentsCoreData
//
//  Created by Grant Maloney on 9/21/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let formatter = DateFormatter()

class Note {
    let title: String
    let size: Int
    let dateModified: Date
    let content: String
    
    var dateModifiedString: String {
        return "Modified: \(formatter.string(from: self.dateModified))"
    }
    
    var sizeString: String {
        return "Size: \(size) Bytes"
    }
    
    init(title: String, size: Int, dateModified: Date, content: String) {
        self.title = title
        self.size = size
        self.dateModified = dateModified
        self.content = content
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
    }
    
    func saveNote(isEdited: Bool, viewingData: NSManagedObject?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        var userEntity: NSManagedObject = NSManagedObject()
        
        if !isEdited {
            userEntity = NSEntityDescription.insertNewObject(forEntityName: "Document", into: managedContext)
        } else {
            if let data = viewingData {
                userEntity = data
            }
        }
        
        userEntity.setValue(title, forKey: "name")
        userEntity.setValue(content, forKey: "content")
        userEntity.setValue(size, forKey: "size")
        userEntity.setValue(dateModified, forKey: "dateModified")
        
        print("Saving")
        do {
            try managedContext.save()
            print("Saved Successfully")
        } catch {
            print("Failed saving")
        }
    }
    
    static func loadNotes(request: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext) -> ([Note], [NSManagedObject]) {
        request.returnsObjectsAsFaults = false
        
        var myNotes: [Note] = []
        var myDocuments: [NSManagedObject] = []
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let name = data.value(forKey: "name") as! String
                let size = data.value(forKey: "size") as! Int
                let dateModified = data.value(forKey: "dateModified") as! Date
                let content = data.value(forKey: "content") as! String
                myNotes.append(Note(title: name, size: size, dateModified: dateModified, content: content))
                myDocuments.append(data)
            }
            
        } catch {
            print("Failed to load notes")
        }
        
        return (myNotes, myDocuments)
    }
}
