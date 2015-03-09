//
//  GraphView.m
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "GraphView.h"


@implementation GraphView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawBackground];
    CGPoint origin = [self findOrigin];
    [self plotAxesWithOrigin:origin];
    
    NSArray *scaledAndSortedPoints = [self scalePoints:[self sortGraphPoints] withOrigin:origin];
    
    [self plotPoints:scaledAndSortedPoints];
    
    NSArray *xIntervals = [self getIntervalsWithMin:self.delegate.minX Max:self.delegate.maxX andInterval:self.delegate.intervalX andintervalType:IntervalTypeX];
    
    NSArray *yIntervals = [self getIntervalsWithMin:self.delegate.minY Max:self.delegate.maxY andInterval:self.delegate.intervalY andintervalType:IntervalTypeY];

    [self plotIntervals:xIntervals withOrigin:origin];
    [self plotIntervals:yIntervals withOrigin:origin];
}

-(void)drawBackground {
    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(20.0,20.0)];
//    
//    [path addClip];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGMutablePathRef clippingPath = [self createPathForClippingWithRect:self.bounds arcRadius:25.0];
    CGContextAddPath(context, clippingPath);
    CGContextClip(context);
    
    NSArray *colors = @[(id)self.bottomColor.CGColor, (id)self.topColor.CGColor];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat colorLocations[] = {0.0, 1.0};
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, colorLocations);
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(0,self.bounds.size.height);
    CGContextDrawLinearGradient(context,
                                gradient,
                                startPoint,
                                endPoint,
                                0);
    

}

-(CGPoint)findOrigin {
    CGFloat minX = self.delegate.minX;
    CGFloat maxX = self.delegate.maxX;
    CGFloat minY = self.delegate.minY;
    CGFloat maxY = self.delegate.maxY;
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    CGFloat yIntercept = self.frame.origin.y;
    CGFloat xIntercept = self.frame.origin.x ;
    
    CGFloat xRange = self.delegate.maxX - self.delegate.minX;
    CGFloat yRange = self.delegate.maxY - self.delegate.minY;
    
    
    //set yIntercept
    if (minY >= 0) {
        yIntercept += height;
        
    } else if (maxY > 0 && minY < 0) {
        yIntercept += (abs(maxY) / yRange) * height;
    }
    
    //set xIntercept
    if (minX >= 0) {
        xIntercept += width;
    } else if (maxX > 0 && minX < 0) {
        xIntercept += (abs(minX) / xRange) * width;
    }
    
    return CGPointMake(xIntercept, yIntercept);
}

-(void)plotAxesWithOrigin:(CGPoint)origin {
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
//    CGFloat widthInset = 5;
//    CGFloat heightInset = 5;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5);
    CGContextSetStrokeColorWithColor(context, self.delegate.axesColor.CGColor);
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, 0, origin.y);
    CGContextAddLineToPoint(context,width, origin.y);
    
    CGContextMoveToPoint(context, origin.x, 0);
    CGContextAddLineToPoint(context,origin.x, height);
    
    CGContextStrokePath(context);

}

-(CGFloat)getXScaledPoint {
    return abs(self.frame.size.width / (self.delegate.maxX - self.delegate.minX));
}

-(CGFloat)getYScaledPoint {
    return abs(self.frame.size.height / (self.delegate.maxY - self.delegate.minY));
}

-(void)plotPoints:(NSArray *)scaledAndSortedPoints {
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 3);
    CGContextSetStrokeColorWithColor(context, self.delegate.lineColor.CGColor);
    
    [scaledAndSortedPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGPoint point = [obj CGPointValue];
        
        if (idx == 0) {
            CGContextBeginPath(context);
            CGContextMoveToPoint(context, point.x, point.y);
        }
        else {
            CGContextAddLineToPoint(context, point.x, point.y);
        }
        
    }];
    
    CGContextStrokePath(context);

}

-(NSArray *)scalePoints:(NSArray *)originalPoints withOrigin:(CGPoint)origin {
    
    NSMutableArray *scaledPoints = [[NSMutableArray alloc] init];

    CGFloat xScaledPoint = [self getXScaledPoint];
    CGFloat yScaledPoint = [self getYScaledPoint];

    [originalPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        

        CGPoint point = [obj CGPointValue];

        CGFloat scaledPointX = point.x * xScaledPoint + origin.x;
        CGFloat scaledPointY = point.y * yScaledPoint + origin.y;
        
        [scaledPoints addObject:[NSValue valueWithCGPoint:CGPointMake(scaledPointX, scaledPointY)]];
    }];
    
    return scaledPoints;
}

-(NSArray *)sortGraphPoints {
    
    NSArray *sortedArray = [self.delegate.points sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        CGPoint p1 = [obj1 CGPointValue];
        CGPoint p2 = [obj2 CGPointValue];
        
        if (p1.x == p2.x) return p1.y < p2.y;
        
        return p1.x < p2.x;
    }];
    
    return sortedArray;
}

-(void)plotIntervals:(NSArray *)intervals withOrigin:(CGPoint)origin {
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    NSArray *scaledAndSortedXIntervals = [self scalePoints:intervals withOrigin:origin];
    
    [scaledAndSortedXIntervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
       
        CGPoint scaledPoint = [obj CGPointValue];

        CGContextMoveToPoint(context, scaledPoint.x, scaledPoint.y);
        UILabel *intervalLabel = [[UILabel alloc] init];

        CGPoint originalPoint = [(NSValue *)intervals[idx] CGPointValue];
        
        BOOL xInterval = originalPoint.x != 0 ? YES : NO;
        BOOL yInterval = originalPoint.y != 0 ? YES : NO;
        intervalLabel.text = xInterval ? [NSString stringWithFormat:@"%.0f",ceil(originalPoint.x)] : [NSString stringWithFormat:@"%.0f",ceil(originalPoint.y)];
        
        [intervalLabel sizeToFit];

        intervalLabel.center = xInterval ? CGPointMake(scaledPoint.x, scaledPoint.y + 15) : CGPointMake(scaledPoint.x - 15, scaledPoint.y);
        
        if (!xInterval && !yInterval) {
            intervalLabel.center = CGPointMake(scaledPoint.x - 15, scaledPoint.y + 15);
        }
        
        
        [self addSubview:intervalLabel];

        
    }];
    
}

-(NSArray *)getIntervalsWithMin:(NSInteger)min Max:(NSInteger)max andInterval:(NSInteger)interval andintervalType:(IntervalType)intervalType {  //assuming only whole number intervals for the time being
    
    CGFloat startingPoint;
    
    if (min < 0) {
        startingPoint = min + (min % interval);
    }
    else {
        startingPoint = min + (min % interval);
    }
    
    NSInteger lastInterval = startingPoint;
    
    NSMutableArray *intervals = [[NSMutableArray alloc] init];
    
    while (lastInterval <= max) {
        
        NSValue *newInterval;
        
        if (intervalType == IntervalTypeX) {
            newInterval = [NSValue valueWithCGPoint:CGPointMake(lastInterval, 0)];
        } else {
            newInterval = [NSValue valueWithCGPoint:CGPointMake(0, lastInterval)];
        }
        
        [intervals addObject:newInterval];
        lastInterval += interval;
    }
    
    return intervals;
}

- (CGMutablePathRef) createPathForClippingWithRect:(CGRect)rect arcRadius:(CGFloat) arcRadius {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + 5);
    
    NSInteger counter = 0;
    
    while (path) {
        
        CGPoint latestPoint = CGPathGetCurrentPoint(path);
        CGPoint addPoint;
        CGFloat startAngle;
        CGFloat endAngle;
        CGPoint arcCenter;
        
        switch (counter) {
            case 0:
                startAngle = M_PI;
                endAngle = 3 * M_PI/2;
                addPoint = CGPointMake(self.bounds.size.width - arcRadius, 0);
                arcCenter = CGPointMake(arcRadius, arcRadius);
                break;
                
            case 1:
                startAngle = 3 * M_PI/2;
                endAngle = 2 * M_PI;
                addPoint = CGPointMake(0, self.bounds.size.height - arcRadius);
                arcCenter = CGPointMake(self.bounds.size.width -arcRadius, arcRadius);
                break;

            case 2:
                startAngle = 2 * M_PI;
                endAngle = M_PI/2;
                addPoint = CGPointMake(-self.bounds.size.width + arcRadius, 0);
                arcCenter = CGPointMake(self.bounds.size.width-arcRadius, self.bounds.size.height-arcRadius);
                break;
                
            case 3:
                startAngle = M_PI/2;
                endAngle = M_PI;
                addPoint = CGPointMake(0, -self.bounds.size.height + arcRadius);
                arcCenter = CGPointMake(arcRadius, self.bounds.size.height - arcRadius);
                break;
                
            default:
                break;
        }
        
        CGPathAddArc(path, NULL, arcCenter.x, arcCenter.y, arcRadius, startAngle, endAngle, 0);
        
        latestPoint = CGPathGetCurrentPoint(path);
        
        CGPathAddLineToPoint(path, NULL, latestPoint.x + addPoint.x, latestPoint.y + addPoint.y);
        
        if ( counter == 3 ) { //this is not 100% perfect...
            break;
        }
                                                                                                                                                        
        counter ++;
    }

    return path;
}


@end
