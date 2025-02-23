//
//  Vec2F+Arithmetic.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension Vec2F {
    static func +(lhs: Self, rhs: Self) -> Self {
        .new(
            lhs.first + rhs.first,
            lhs.second + rhs.second
        )
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        .new(
            lhs.first - rhs.first,
            lhs.second - rhs.second
        )
    }
    
    static func *(lhs: Self, scalar: CGFloat) -> Self {
        .new(
            lhs.first * scalar,
            lhs.second * scalar
        )
    }
    
    static func *(lhs: Self, rhs: Self) -> Self {
        .new(
            lhs.first * rhs.first,
            lhs.second * rhs.second
        )
    }
    
    static func /(lhs: Self, scalar: CGFloat) -> Self {
        .new(
            lhs.first / scalar,
            lhs.second / scalar
        )
    }
    
    static prefix func -(val: Self) -> Self {
        .new(
            -val.first,
            -val.second
        )
    }
}

func +=<T: Vec2F>(lhs: inout T, rhs: T) {
    lhs = lhs + rhs
}

func -=<T: Vec2F>(lhs: inout T, rhs: T) {
    lhs = lhs - rhs
}

func *=<T: Vec2F>(lhs: inout T, scalar: CGFloat) {
    lhs = lhs * scalar
}

func /=<T: Vec2F>(lhs: inout T, scalar: CGFloat) {
    lhs = lhs / scalar
}
