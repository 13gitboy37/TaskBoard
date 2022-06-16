//
//  Task.swift
//  TaskBoard
//
//  Created by Никита Мошенцев on 14.06.2022.
//

import Foundation

class Task {
    var name: String
    var subtasks: [Task] = []
    
    init(name: String) {
        self.name = name
    }
}

extension Task: Equatable {
    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.name == rhs.name
    }
}
