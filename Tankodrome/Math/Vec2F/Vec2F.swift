//
//  Vec2F.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

public protocol Vec2F {
    var first: CGFloat { get set }
    var second: CGFloat { get set }
    static func new(_ first: CGFloat, _ second: CGFloat) -> Self
}
