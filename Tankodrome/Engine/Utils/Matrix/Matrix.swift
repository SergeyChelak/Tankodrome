//
//  Matrix.swift
//  Tankodrome
//
//  Created by Sergey on 24.03.2025.
//

import Foundation

enum Matrix {
    struct ArrayWrapper<T> {
        private var content: [T]
        let size: Size
        
        init(content: [T], size: Size) {
            self.content = content
            self.size = size
        }
        
        init(size: Size, value: T) {
            self.content = [T].init(
                repeating: value,
                count: size.count
            )
            self.size = size
        }
        
        func enumerated() -> EnumeratedSequence<Array<T>> {
            content.enumerated()
        }
        
        subscript(absoluteIndex: Int) -> T {
            get {
                content[absoluteIndex]
            }
            set {
                content[absoluteIndex] = newValue
            }
        }
        
        subscript(position: Position) -> T {
            get {
                content[position.index(in: size)]
            }
            set {
                content[position.index(in: size)] = newValue
            }
        }
        
        subscript(tuple: (Int, Int)) -> T {
            get {
                self[Position(row: tuple.0, col: tuple.1)]
            }
            set {
                self[Position(row: tuple.0, col: tuple.1)] = newValue
            }
        }
        
        static func empty() -> Self {
            Self.init(content: [], size: .zero())
        }
    }
}
