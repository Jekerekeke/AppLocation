//
//  ExtensionArray.swift
//  TaskNumberOne
//
//  Created by Максим Егоров on 29/04/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
