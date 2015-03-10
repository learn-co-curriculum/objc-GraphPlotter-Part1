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

typedef enum {
    AxisX,
    AxisY,
    AxisOrigin,
    AxisOther
} Axis;

//struct axesIntervals
//{
//    CGFloat x;
//    CGFloat y;
//};
//
//typedef struct axesIntervals AxesIntervals;
@protocol GraphViewDelegate <NSObject>

-(AxesRange)rangeForGraphView:(GraphView *)graphView;
-(NSString *)labelForDataAtPoint:(CGPoint)point forAxis:(Axis)axis;

@optional

-(CGPoint)offsetForLabelAtPoint:(CGPoint)point;


@property (nonatomic) CGFloat intervalX;
@property (nonatomic) CGFloat intervalY;
@property (strong, nonatomic) UIColor *axesColor;

//ideally, all of the above properties would be optional, and our graph would figure out for itself what a baseline set of axes and intervals would look like based on the dataset provided. V1.0 does not include such an algorithm.

//ideally our graph would also dequeue points as they went off screen, but again V1.0 does not support scrolling or going off screen, so we will not worry about this just yet.

@end
