//
//  GraphView.h
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    IntervalTypeX,
    IntervalTypeY
} IntervalType;

@protocol GraphViewProtocol <NSObject>


//-(GraphView *)graphviewWithMinX:(CGFloat)minX maxX:(CGFloat)maxX minY:(CGFloat)minY maxY:(CGFloat)maxY withIntervalForXAxis:(CGFloat)intervalX andIntervalForYAxis:(CGFloat)intervalY;

-(NSString *)labelForDataAtPoint:(CGPoint)point;

@property (nonatomic) CGFloat minX;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat intervalX;
@property (nonatomic) CGFloat intervalY;
@property (strong, nonatomic) NSArray *points;
@property (strong, nonatomic) UIColor *lineColor;
@property (strong, nonatomic) UIColor *axesColor;

@optional
//ideally, all of the above properties would be optional, and our graph would figure out for itself what a baseline set of axes and intervals would look like based on the dataset provided. V1.0 does not include such an algorithm.

//ideally our graph would also dequeue points as they went off screen, but again V1.0 does not support scrolling or going off screen, so we will not worry about this just yet.

@end

IB_DESIGNABLE
@interface GraphView : UIView

@property (nonatomic) id<GraphViewProtocol>delegate;
@property (nonatomic) IBInspectable UIColor *bottomColor;
@property (nonatomic) IBInspectable UIColor *topColor;



@end
