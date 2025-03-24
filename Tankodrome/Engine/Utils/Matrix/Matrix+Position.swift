//
//  Matrix+Position.swift
//  Tankodrome
//
//  Created by Sergey on 24.03.2025.
//

import Foundation

extension Matrix {
    struct Position {
        var row: Int
        var col: Int
        
        static func from(index: Int, of size: Size) -> Self {
            Self(
                row: index / size.cols,
                col: index % size.cols
            )
        }
        
        func index(in size: Size) -> Int {
            row * size.cols + col
        }
        
        func isInside(of size: Size) -> Bool {
            row >= 0 && col >= 0 && row < size.rows && col < size.cols
        }
        
        var up: Self {
            Self(row: row - 1, col: col)
        }
        
        var down: Self {
            Self(row: row + 1, col: col)
        }
        
        var left: Self {
            Self(row: row, col: col - 1)
        }
        
        var right: Self {
            Self(row: row, col: col + 1)
        }
        
        func adjacent(in size: Size) -> [Position] {
            [up, down, left, right]
                .filter {
                    $0.isInside(of: size)
                }
        }
    }
}
