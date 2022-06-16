//
//  Session.swift
//  TaskBoard
//
//  Created by Никита Мошенцев on 15.06.2022.
//

import Foundation

class Session {
    static let shared = Session()

    var tasks = [Task]()
    
    func update(tasks: [Task]) {
        self.tasks = tasks
    }
}
