//
//  NSSetExt.swift
//  syno-mobile
//
//  Created by Ирина Улитина on 19.12.2019.
//  Copyright © 2019 Christian Benua. All rights reserved.
//

import Foundation

extension NSSet {
    func toArray<T>() -> [T]? {
        return self.allObjects as? [T]
    }
}
