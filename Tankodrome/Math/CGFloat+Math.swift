//
//  CGFloat+Math.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

// MARK: function wrappers
extension CGFloat {
    func sqr() -> Self {
        self * self
    }
    
    func sqrt() -> Self {
        Darwin.sqrt(self)
    }
    
    func abs() -> Self {
        Swift.abs(self)
    }
    
    func min(_ other: Self) -> Self {
        Swift.min(self, other)
    }
    
    func max(_ other: Self) -> Self {
        Swift.max(self, other)
    }
}

// MARK: conversion
extension CGFloat {
    func degreesToRadians() -> Self {
        self * .pi / 180.0
    }
    
    func radiansToDegrees() -> Self {
        self * 180.0 / .pi
    }
}

// MARK: angle processing
extension CGFloat {
    static let doublePi = 2.0 * .pi
    
    func normalizeToPositiveRadians() -> Self {
        var val = self.truncatingRemainder(dividingBy: Self.doublePi)
        if val < 0.0 {
            val += 2.0 * .pi
        }
        return val
    }
    
    func signedAngleDifference(_ other: Self) -> Self {
        var difference = (self - other).truncatingRemainder(dividingBy: Self.doublePi)
        if difference > .pi {
            difference -= Self.doublePi
        } else if difference < -.pi {
            difference += Self.doublePi
        }
        return difference
    }
}
