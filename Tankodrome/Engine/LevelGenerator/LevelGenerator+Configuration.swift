//
//  LevelGenerator+Configuration.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

extension LevelGenerator {
    final class Configuration {
        let elementsFileName: String
        let elementsFileType: String
        let tileSetName: String
        
        init(elementsFileName: String, elementsFileType: String, tileSetName: String) {
            self.elementsFileName = elementsFileName
            self.elementsFileType = elementsFileType
            self.tileSetName = tileSetName
        }
    }
}
