//
//  Projects+CoreDataProperties.swift
//  project-manager-app
//
//  Created by Saiyaff Farouk on 5/27/19.
//  Copyright © 2019 Saiyaff Farouk. All rights reserved.
//
//

import Foundation
import CoreData


extension Projects {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Projects> {
        return NSFetchRequest<Projects>(entityName: "Projects")
    }

    @NSManaged public var projectAddedToCalendar: Bool
    @NSManaged public var projectDueDate: NSDate?
    @NSManaged public var projectId: String?
    @NSManaged public var projectName: String?
    @NSManaged public var projectNotes: String?
    @NSManaged public var projectPriority: Int16
    @NSManaged public var hasTasks: NSSet?

}

// MARK: Generated accessors for hasTasks
extension Projects {

    @objc(addHasTasksObject:)
    @NSManaged public func addToHasTasks(_ value: Tasks)

    @objc(removeHasTasksObject:)
    @NSManaged public func removeFromHasTasks(_ value: Tasks)

    @objc(addHasTasks:)
    @NSManaged public func addToHasTasks(_ values: NSSet)

    @objc(removeHasTasks:)
    @NSManaged public func removeFromHasTasks(_ values: NSSet)

}
