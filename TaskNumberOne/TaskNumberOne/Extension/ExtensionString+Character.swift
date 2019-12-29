//
//  ExtensionCharacter.swift
//  TaskNumberOne
//
//  Created by Максим Егоров on 29/04/2019.
//  Copyright © 2019 Максим Егоров. All rights reserved.
//

extension String {
    var isWord: Bool {
        get {
            return self.maxCharacter() > 32
        }
    }

    func maxCharacter() -> Int {
        guard var max = self.first?.asciiValue else {
            return 0
        }
        self.forEach {
            if $0.asciiValue > max {
                max = $0.asciiValue
            }
        }
        return max
    }
}

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}
