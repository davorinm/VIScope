//
//  ChartSeries.swift
//
//  Created by Giampaolo Bellavite on 07/11/14.
//  Copyright (c) 2014 Giampaolo Bellavite. All rights reserved.
//

import Foundation
import CoreGraphics

/**
The `ChartSeries` class create a chart series and configure its appearance and behavior.
*/
open class ChartSeries {
    /**
    The data used for the chart series.
    */
    open var data: [ChartPoint]

    /**
    When set to `false`, will hide the series line. Useful for drawing only the area with `area=true`.
    */
    open var line: Bool = true

    /**
    Draws an area below the series line.
    */
    open var area: Bool = false

    /**
    The series color.
    */
    open var color: UIColor = ChartColors.blueColor() {
        didSet {
            colors = (above: color, below: color, 0)
        }
    }

    /**
    A tuple to specify the color above or below the zero
    */
    open var colors: (
        above: UIColor,
        below: UIColor,
        zeroLevel: Double
    ) = (above: ChartColors.blueColor(), below: ChartColors.redColor(), 0)

    public init(_ data: [Double]) {
        self.data = []

        data.enumerated().forEach { (x, y) in
            self.data.append(ChartPoint(x: Double(x), y: y, color: nil))
        }
    }

    public init(data: [(x: Double, y: Double)]) {
        self.data = data.map { ChartPoint(x: $0.x, y: $0.y, color: nil) }
    }

    public init(data: [ChartPoint]) {
        self.data = data
    }

    public init(data: [(x: Int, y: Double)]) {
        self.data = data.map { ChartPoint(x: Double($0.x), y: $0.y, color: nil) }
    }

    public init(data: [(x: Float, y: Float)]) {
        self.data = data.map { ChartPoint(x: Double($0.x), y: Double($0.y), color: nil) }
    }
}

/**
 Represent the x- and the y-axis values for each point in a chart series.
 */
public struct ChartPoint {

    public let x: Double
    public let y: Double
    public var color: UIColor?

    public init(x: Double, y: Double, color: UIColor?) {
        self.x = x
        self.y = y
        self.color = color
    }
}
