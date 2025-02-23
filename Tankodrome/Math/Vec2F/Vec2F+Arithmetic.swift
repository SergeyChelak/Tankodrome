//
//  Vec2F+Arithmetic.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension Vec2F {
    public static func +(lhs: Self, rhs: Self) -> Self {
        .new(
            lhs.first + rhs.first,
            lhs.second + rhs.second
        )
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        .new(
            lhs.first - rhs.first,
            lhs.second - rhs.second
        )
    }
    
    public static func *(lhs: Self, scalar: CGFloat) -> Self {
        .new(
            lhs.first * scalar,
            lhs.second * scalar
        )
    }
    
    public static func *(lhs: Self, rhs: Self) -> Self {
        .new(
            lhs.first * rhs.first,
            lhs.second * rhs.second
        )
    }
    
    public static func /(lhs: Self, scalar: CGFloat) -> Self {
        .new(
            lhs.first / scalar,
            lhs.second / scalar
        )
    }
    
    public static prefix func -(val: Self) -> Self {
        .new(
            -val.first,
            -val.second
        )
    }
}

public func +=<T: Vec2F>(lhs: inout T, rhs: T) {
    lhs = lhs + rhs
}

public func -=<T: Vec2F>(lhs: inout T, rhs: T) {
    lhs = lhs - rhs
}

public func *=<T: Vec2F>(lhs: inout T, scalar: CGFloat) {
    lhs = lhs * scalar
}

public func /=<T: Vec2F>(lhs: inout T, scalar: CGFloat) {
    lhs = lhs / scalar
}
