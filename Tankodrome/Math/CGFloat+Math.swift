//
//  CGFloat+Math.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

// MARK: function wrappers
extension CGFloat {
    public func sqr() -> Self {
        self * self
    }
    
    public func sqrt() -> Self {
        Darwin.sqrt(self)
    }
    
    public func abs() -> Self {
        Swift.abs(self)
    }
    
    public func min(_ other: Self) -> Self {
        Swift.min(self, other)
    }
    
    public func max(_ other: Self) -> Self {
        Swift.max(self, other)
    }
}

// MARK: conversion
extension CGFloat {
    public func degreesToRadians() -> Self {
        self * .pi / 180.0
    }
    
    public func radiansToDegrees() -> Self {
        self * 180.0 / .pi
    }
}

// MARK: angle processing
extension CGFloat {
    public static let doublePi = 2.0 * .pi
    
    public func normalizeToPositiveRadians() -> Self {
        var val = self.truncatingRemainder(dividingBy: Self.doublePi)
        if val < 0.0 {
            val += 2.0 * .pi
        }
        return val
    }
    
    public func signedAngleDifference(_ other: Self) -> Self {
        var difference = (self - other).truncatingRemainder(dividingBy: Self.doublePi)
        if difference > .pi {
            difference -= Self.doublePi
        } else if difference < -.pi {
            difference += Self.doublePi
        }
        return difference
    }
}
