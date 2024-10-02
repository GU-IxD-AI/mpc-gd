//
//  HKMath.swift
//  HUDKitDemo
//
//  Created by Rob Saunders on 8/10/16.
//  Copyright © 2016 Saunders, Rob. All rights reserved.
//

import Foundation
import CoreGraphics

// TODO: Figure out how to convert this to a set of (global) generic functions that cover Double, Float and CGFloat

// TODO: Implement a Lerpable protocol that is implemented with extensions to CGFloat, CGPoint, CGSize, CGRect, etc.


/** Linearly interpolates between the lower value and the upper value based on the
	fraction. Like Processing's lerp() */
public func lerp(lower: Double, upper: Double, fraction: Double) -> Double {
    return fraction * (upper - lower) + lower
}

/** Linearly interpolates between the lower value and the upper value based on the
	fraction. Like Processing's lerp() */
public func lerp(lower: Float, upper: Float, fraction: Float) -> Float {
    return fraction * (upper - lower) + lower
}

/** Linearly interpolates between the lower value and the upper value based on the
	fraction. Like Processing's lerp() */
public func lerp(lower: CGFloat, upper: CGFloat, fraction: CGFloat) -> CGFloat {
    return fraction * (upper - lower) + lower
}

/** Normalizes a number from another range into a value between 0 and 1.
 Like Processing's norm() */
public func norm(value: Double, lower: Double, upper: Double) -> Double {
    return (value - lower) / (upper - lower)
}

/** Normalizes a number from another range into a value between 0 and 1.
 Like Processing's norm() */
public func norm(value: Float, lower: Float, upper: Float) -> Float {
    return (value - lower) / (upper - lower)
}

/** Normalizes a number from another range into a value between 0 and 1.
 Like Processing's norm() */
public func norm(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
    return (value - lower) / (upper - lower)
}

/** Maps a value from one interval to another.
	Like Processing's map(). */
public func map(value: Double, from: (Double, Double), to: (Double, Double)) -> Double {
    return lerp(lower: to.0, upper: to.1, fraction: norm(value: value, lower: from.0, upper: from.1))
}

/** Maps a value from one interval to another.
	Like Processing's map(). */
public func map(value: Float, from: (Float, Float), to: (Float, Float)) -> Float {
    return lerp(lower: to.0, upper: to.1, fraction: norm(value: value, lower: from.0, upper: from.1))
}

/** Maps a value from one interval to another.
	Like Processing's map(). */
public func map(value: CGFloat, from: (CGFloat, CGFloat), to: (CGFloat, CGFloat)) -> CGFloat {
    return lerp(lower: to.0, upper: to.1, fraction: norm(value: value, lower: from.0, upper: from.1))
}

/** Clamps a value between the lower and upper values.
	Like Processing's clamp(). */
public func clamp(value: Double, lower: Double, upper: Double) -> Double {
    return min(max(value, lower), upper)
}

/** Clamps a value between the lower and upper values.
	Like Processing's clamp(). */
public func clamp(value: Float, lower: Float, upper: Float) -> Float {
    return min(max(value, lower), upper)
}

/** Clamps a value between the lower and upper values.
	Like Processing's clamp(). */
public func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
    return min(max(value, lower), upper)
}
