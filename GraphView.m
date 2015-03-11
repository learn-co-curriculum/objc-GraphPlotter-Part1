//
//  GraphView.m
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "GraphView.h"

@interface GraphView ()

@property (nonatomic) AxesRange axesRange;
@property (nonatomic) CGRect workingBounds;

@end

static const int defaultIntervalOffset = 15;

@implementation GraphView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}


-(CGRect)workingBounds {
    
    NSInteger xInset = 25;
    NSInteger yInset = 25;
    
    _workingBounds.size.width = self.bounds.size.width - (2 * xInset);
    _workingBounds.size.height = self.bounds.size.height - ( 2 * yInset);
    _workingBounds.origin.x = xInset;
    _workingBounds.origin.y = yInset;
    
    return _workingBounds;
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawBackground];
    CGPoint origin = [self findOrigin];
    [self plotAxesWithOrigin:origin];
    
    for (NSInteger i = 0; i < [self.datasource numberOfLines]; i++) {
        
        NSArray *coordinatesForLineAtIndex = [self.datasource graphView:self coordinatesForLineAtIndex:i];
        
        NSArray *scaledAndSortedPoints = [self scalePoints:[self sortGraphPoints:coordinatesForLineAtIndex] withOrigin:origin];
        
        [self plotPoints:scaledAndSortedPoints ForLineAtIndex:i];
    }
    
    
    //FIXME: seems duplicative for "graphPart" -- ideal way to do this?
    NSArray *xIntervals = [self getIntervalsWithMin:self.axesRange.min.x Max:self.axesRange.max.x andInterval:[self.datasource graphView:self intervalForGraphPart:HorizontalAxis] andGraphPart:HorizontalAxis];
    
    NSArray *yIntervals = [self getIntervalsWithMin:self.axesRange.min.y Max:self.axesRange.max.y andInterval:[self.datasource graphView:self intervalForGraphPart:VerticalAxis] andGraphPart:VerticalAxis];
    
    [self plotIntervals:xIntervals withOrigin:origin forGraphPart:HorizontalAxis];
    
    [self plotIntervals:yIntervals withOrigin:origin forGraphPart:VerticalAxis];
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

-(AxesRange)axesRange {
    if ([self.delegate respondsToSelector:@selector(rangeForGraphView:)]) {
        return [self.delegate rangeForGraphView:self];
    }
    else {
        CGFloat minX = [[[self xValuesForAllLines] valueForKeyPath:@"@min.self"] floatValue];
        CGFloat maxX = [[[self xValuesForAllLines] valueForKeyPath:@"@max.self"] floatValue];
        CGFloat minY = [[[self yValuesForAllLines] valueForKeyPath:@"@min.self"] floatValue];
        CGFloat maxY = [[[self yValuesForAllLines] valueForKeyPath:@"@max.self"] floatValue];
        
        NSString *minXString = [[[self xValuesForAllLines] valueForKeyPath:@"@min.self"] stringValue];
        NSString *maxXString = [[[self xValuesForAllLines] valueForKeyPath:@"@max.self"] stringValue];
        NSString *minYString = [[[self yValuesForAllLines] valueForKeyPath:@"@min.self"] stringValue];
        NSString *maxYString = [[[self yValuesForAllLines] valueForKeyPath:@"@max.self"] stringValue];
        
        NSUInteger maxXStringLength =  [maxXString length];
        NSUInteger minXStringLength =  [minXString length];
        NSUInteger maxYStringLength =  [maxYString length];
        NSUInteger minYStringLength =  [minYString length];
        
        CGFloat minXRounded = roundf(minX / minXStringLength) *minXStringLength;
        CGFloat maxXRounded = roundf(maxX / maxXStringLength) *maxXStringLength;
        CGFloat minYRounded = roundf(minY / minYStringLength) *minYStringLength;
        CGFloat maxYRounded = roundf(maxY / maxYStringLength) *maxYStringLength;
        
        _axesRange.min.x = minXRounded;
        _axesRange.max.x = maxXRounded;
        _axesRange.min.y = minYRounded;
        _axesRange.max.y = maxYRounded;
    }
    
    return _axesRange;
}

-(NSArray *)xValuesForAllLines {
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [self.datasource numberOfLines]; i++) {
        NSArray *points = [self.datasource graphView:self coordinatesForLineAtIndex:i];
        for (NSValue *coordinate in points) {
            [xValues addObject:@([coordinate CGPointValue].x)];
        }
    }
    
    return xValues;
}

-(NSArray *)yValuesForAllLines {
    
    NSMutableArray *yValues = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [self.datasource numberOfLines]; i++) {
        
        NSArray *points = [self.datasource graphView:self coordinatesForLineAtIndex:i];
        for (NSValue *coordinate in points) {
            [yValues addObject:@([coordinate CGPointValue].y)];
        }
    }
    
    return yValues;
    
}
-(CGPoint)findOrigin {
    
    CGFloat minX = self.axesRange.min.x;
    CGFloat maxX = self.axesRange.max.x;
    CGFloat minY = self.axesRange.min.y;
    CGFloat maxY = self.axesRange.max.y;
    
    CGFloat height = self.workingBounds.size.height;
    CGFloat width = self.workingBounds.size.width;
    
    CGFloat yIntercept = self.workingBounds.origin.y;
    CGFloat xIntercept = self.workingBounds.origin.x ;
    
    CGFloat xRange = maxX - minX;
    CGFloat yRange = maxY - minY;
    
    
    //set yIntercept
    if (minY >= 0) {
        yIntercept += height;
        
    } else if (maxY > 0 && minY < 0) {
        yIntercept += (abs(maxY) / yRange) * height;
    }
    
    //set xIntercept
    if (minX > 0 || maxX == 0) {
        xIntercept += width;
    } else if (maxX > 0 && minX < 0) {
        xIntercept += (abs(minX) / xRange) * width;
    }
    
    
    return CGPointMake(xIntercept, yIntercept);
}

-(void)plotAxesWithOrigin:(CGPoint)origin {
    
    CGFloat height = self.workingBounds.size.height;
    CGFloat width = self.workingBounds.size.width;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 5);
    
    if ([self.delegate respondsToSelector:@selector(colorForAxesForGraphView:)]) {
    CGContextSetStrokeColorWithColor(context, [self.delegate colorForAxesForGraphView:self].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    }
    
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, self.workingBounds.origin.x, origin.y);
    CGContextAddLineToPoint(context,width + self.workingBounds.origin.x, origin.y);
    
    CGContextMoveToPoint(context, origin.x, self.workingBounds.origin.y);
    CGContextAddLineToPoint(context,origin.x, height + self.workingBounds.origin.y);
    
    CGContextStrokePath(context);
}

-(CGFloat)getXScaledPoint {
    return abs((self.workingBounds.size.width) / (self.axesRange.max.x - self.axesRange.min.x));
}

-(CGFloat)getYScaledPoint {
    return abs((self.workingBounds.size.height) / (self.axesRange.max.y - self.axesRange.min.y)) - 1;
}

-(void)plotPoints:(NSArray *)scaledAndSortedPoints ForLineAtIndex:(NSInteger)index {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 3);
    
    UIColor *lineColor = [self.datasource colorForLineAtIndex:index];
    
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    
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
        CGFloat scaledPointY = -point.y * yScaledPoint + origin.y;
        
        [scaledPoints addObject:[NSValue valueWithCGPoint:CGPointMake(scaledPointX, scaledPointY)]];
    }];
    
    return scaledPoints;
}

-(NSArray *)sortGraphPoints:(NSArray *)unsortedPoints {
    
    NSArray *sortedArray = [unsortedPoints sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        CGPoint p1 = [obj1 CGPointValue];
        CGPoint p2 = [obj2 CGPointValue];
        
        if (p1.x == p2.x) return p1.y < p2.y;
        
        return p1.x < p2.x;
    }];
    
    return sortedArray;
}

-(void)plotIntervals:(NSArray *)intervals withOrigin:(CGPoint)origin forGraphPart:(GraphPart)graphPart{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *scaledAndSortedIntervals = [self scalePoints:intervals withOrigin:origin];
    
    [scaledAndSortedIntervals enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGPoint scaledPoint = [obj CGPointValue];
        
        CGPoint originalPoint = [(NSValue *)intervals[idx] CGPointValue];
        
        UILabel *intervalLabel;
        if ([self.delegate respondsToSelector:@selector(labelForGraphPart:atCoordinate:)]) {
        intervalLabel = [self.delegate labelForGraphPart:graphPart atCoordinate:originalPoint];
        }
        else {
            
            intervalLabel = [[UILabel alloc] init];
            
            if (graphPart == VerticalAxis) {
                intervalLabel.text = [NSString stringWithFormat:@"%.0f", originalPoint.y];
            }
            else if (graphPart == HorizontalAxis) {
                intervalLabel.text = [NSString stringWithFormat:@"%.0f", originalPoint.x];
            }

        }
        
        [intervalLabel sizeToFit];
        
        CGPoint intervalLabelOffset;
        
        if ([self.delegate respondsToSelector:@selector(offsetForLabelAtPoint:forAxis:)]) {
            intervalLabelOffset = [self.delegate offsetForLabelForGraphPart:graphPart AtCoordinate:originalPoint];
        } else {
            
            if (graphPart == HorizontalAxis) {
                if (self.axesRange.max.x <= 0) {
                    intervalLabelOffset = CGPointMake(scaledPoint.x  , scaledPoint.y + defaultIntervalOffset);
                } else {
                    intervalLabelOffset = CGPointMake(scaledPoint.x  , scaledPoint.y - defaultIntervalOffset);
                }
            }
            else if (graphPart == VerticalAxis) {
                
                if (self.axesRange.max.y <= 0) {
                    intervalLabelOffset = CGPointMake(scaledPoint.x + defaultIntervalOffset, scaledPoint.y );
                } else {
                    intervalLabelOffset = CGPointMake(scaledPoint.x - defaultIntervalOffset, scaledPoint.y );
                }
            }
            else if (graphPart == OriginPoint) {
                intervalLabelOffset = CGPointMake(scaledPoint.x, scaledPoint.y);
            }
        }
        
        
        intervalLabel.center = intervalLabelOffset;
        
        [self addSubview:intervalLabel];
        
        
    }];
    
    CGMutablePathRef clippingPath = [self createPathForClippingWithRect:self.bounds arcRadius:25.0];
    CGContextAddPath(context, clippingPath);
    CGContextClip(context);
}

-(NSArray *)getIntervalsWithMin:(NSInteger)min Max:(NSInteger)max andInterval:(NSInteger)interval andGraphPart:(GraphPart)graphPart {
    
    //assuming only whole number intervals for the time being
    
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
        
        if (graphPart == HorizontalAxis) {
            newInterval = [NSValue valueWithCGPoint:CGPointMake(lastInterval, 0)];
        } else if (graphPart == VerticalAxis) {
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
                arcCenter = CGPointMake(self.bounds.size.width -arcRadius, self.bounds.size.height-arcRadius);
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
