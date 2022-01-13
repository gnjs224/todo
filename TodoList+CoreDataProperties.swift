//
//  TodoList+CoreDataProperties.swift
//  
//
//  Created by 김지훈 on 2022/01/12.
//
//

import Foundation
import CoreData


extension TodoList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoList> {
        return NSFetchRequest<TodoList>(entityName: "TodoList")
    }

    @NSManaged public var date: Date?
    @NSManaged public var todo: String?

}
