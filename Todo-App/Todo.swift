//
//  Todo.swift
//  Todo-App
//
//  Created by Superdev on 18/09/2017.
//  Copyright © 2017 Superdev. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    
    dynamic var name = ""
    dynamic var createdAt = NSDate()
    dynamic var priority = 1
        
}
