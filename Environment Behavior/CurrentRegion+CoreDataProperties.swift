//
//  CurrentRegion+CoreDataProperties.swift
//  Environment Behavior
//
//  Created by JIAN LI on 9/8/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import CoreData


extension CurrentRegion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentRegion> {
        return NSFetchRequest<CurrentRegion>(entityName: "CurrentRegion")
    }

    @NSManaged public var swLatitude: Double
    @NSManaged public var swLongitude: Double
    @NSManaged public var neLatitude: Double
    @NSManaged public var neLongitude: Double

}
