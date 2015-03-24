//
//  GraphView.m
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "GraphView.h"

@interface GraphView ()


@property (nonatomic) CGRect workingBounds;
@property (nonatomic) NSInteger currentLine;
@property (nonatomic) NSArray *pointsForCurrentLine;


-(void)drawRect:(CGRect)rect;
-(void)drawBackground;

- (NSArray *)xValuesForAllLines;
- (NSArray *)yValuesForAllLines;
- (CGFloat)getScaledPoint;
- (void)plotPoints:(NSArray *)scaledAndSortedPoints forLineAtIndex:(NSInteger)index;
- (NSArray *)scalePoints:(NSArray *)originalPoints withOrigin:(CGPoint)origin;
- (NSArray *)sortGraphPoints:(NSArray *)unsortedPoints;
- (CGMutablePathRef) createPathForClippingWithRect:(CGRect)rect arcRadius:(CGFloat) arcRadius;

@end

static const int defaultLineDataWidth = 3;
static const int defaultWorkingBoundsXInset = 25;
static const int defaultWorkingBoundsYInset = 25;

@implementation GraphView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

-(instancetype)initWithLineData:(NSArray *)linedata lineColor:(NSArray *)colors lineWidths:(NSArray *)lineWidths {
    
    self = [super init];
    
    if (self) {
        self.lineData = linedata;
        self.lineColors = colors;
        self.lineWidths = lineWidths;
    }
    
    return self;
}


-(CGRect)prepareWorkingBounds {
    
    _workingBounds.size.width = self.bounds.size.width - (2 * defaultWorkingBoundsXInset);
    _workingBounds.size.height = self.bounds.size.height - ( 2 * defaultWorkingBoundsYInset);
    _workingBounds.origin.x = defaultWorkingBoundsXInset;
    _workingBounds.origin.y = defaultWorkingBoundsYInset;
    
    return _workingBounds;
}

-(void)reloadGraph {
    [self setNeedsDisplay];
}


-(void)drawRect:(CGRect)rect {
    
    [self prepareWorkingBounds];
    //Add a background gradient
    [self drawBackground];
    
    CGPoint origin = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
//    //Now plot the data
    for (NSInteger i = 0; i < [self.lineData count] ; i++) {
        
        self.currentLine = i;
    
        NSArray *scaledAndSortedPoints = [self scalePoints:[self sortGraphPoints:self.lineData[self.currentLine]]
                                                withOrigin:origin];
        
        [self plotPoints:scaledAndSortedPoints forLineAtIndex:i];
    }
    
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
    
    //comment why we're doing array this way for C primitives vs. in color primitives above
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


-(NSArray *)xValuesForAllLines {
    NSMutableArray *xValues = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [self.lineData count]; i++) {
        NSArray *points = self.lineData[self.currentLine];
        for (NSValue *coordinate in points) {
            [xValues addObject:@([coordinate CGPointValue].x)];
        }
    }
    
    return xValues;
}

//TODO: get rid of this method; use the above for both.
-(NSArray *)yValuesForAllLines {
    
    NSMutableArray *yValues = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < [self.lineData count]; i++) {
        
        NSArray *points = self.lineData[self.currentLine];
        for (NSValue *coordinate in points) {
            [yValues addObject:@([coordinate CGPointValue].y)];
        }
    }
    
    return yValues;
    
}

-(CGFloat)getScaledPoint {
    
    CGFloat minX = [[[self xValuesForAllLines] valueForKeyPath:@"@min.self"] floatValue];
    CGFloat maxX = [[[self xValuesForAllLines] valueForKeyPath:@"@max.self"] floatValue];
    CGFloat minY = [[[self yValuesForAllLines] valueForKeyPath:@"@min.self"] floatValue];
    CGFloat maxY = [[[self yValuesForAllLines] valueForKeyPath:@"@max.self"] floatValue];
    
    CGFloat maxRange = [[@[@(abs(minX)), @(abs(minY)), @(abs(maxX)), @(abs(maxY))] valueForKeyPath:@"@max.self"] floatValue];
    
    return self.workingBounds.size.height / (maxRange *2);
}


-(void)plotPoints:(NSArray *)scaledAndSortedPoints forLineAtIndex:(NSInteger)index {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ([self.lineWidths count] == 0) {
        CGContextSetLineWidth(context, defaultLineDataWidth);
    }
    else {
        CGContextSetLineWidth(context, [self.lineWidths[self.currentLine] integerValue]);
    }
    
    UIColor *lineColor = self.lineColors[index];
    
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
    
    [originalPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CGPoint point = [obj CGPointValue];
        
        CGFloat scaledPointX = point.x * [self getScaledPoint] + origin.x;
        CGFloat scaledPointY = -point.y * [self getScaledPoint] + origin.y;
        
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

- (CGMutablePathRef) createPathForClippingWithRect:(CGRect)rect arcRadius:(CGFloat) arcRadius {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + 5);
    
    for (NSInteger counter = 0; counter <= 3; counter++) {
        
        CGPoint latestPoint = CGPathGetCurrentPoint(path);
        CGPoint addPoint;
        CGFloat startAngle;
        CGFloat endAngle;
        CGPoint arcCenter;
        
        
        //TODO: Think on way to make this better perhaps using quadrants with an enum
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
    }
    
    return path;
}


@end
