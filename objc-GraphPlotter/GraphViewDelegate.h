//
//  GraphViewDelegate.h
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/9/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GraphView;

struct axesRange
{
    CGPoint min;
    CGPoint max;
};

typedef struct axesRange AxesRange;

typedef enum GraphPart {
    VerticalAxis,
    HorizontalAxis,
    OriginPoint,
    LineData
} GraphPart;

@protocol GraphViewDelegate <NSObject>

@optional
-(AxesRange)rangeForGraphView:(GraphView *)graphView;
-(CGPoint)offsetForLabelForGraphPart:(GraphPart)graphPart atCoordinate:(CGPoint)point;
-(UIColor *)colorForAxesForGraphView:(GraphView *)graphView;
-(UILabel *)labelForGraphPart:(GraphPart)graphPart atCoordinate:(CGPoint)point;

//ideally our graph would dequeue points as they went off screen, but  V1.0 does not support scrolling or going off screen, so we will not worry about this just yet.

@end
