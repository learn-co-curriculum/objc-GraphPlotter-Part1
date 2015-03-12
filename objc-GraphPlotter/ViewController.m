//
//  ViewController.m
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSArray *lines;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.graphView.delegate = self;
    self.graphView.datasource = self;
    
    self.graphView.bottomColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000];;
    self.graphView.topColor = [UIColor magentaColor];
    self.graphView.backgroundColor = [UIColor clearColor];
}

-(NSArray *)lines {
    
    //TODO: make an objc wrapper around CGPoint so don't have to do NSValue stuff
    
    if (!_lines) {
        
        NSArray * pointsForLine1 = @[[NSValue valueWithCGPoint:CGPointMake(0, 1)], [NSValue valueWithCGPoint:CGPointMake(-1, -2)], [NSValue valueWithCGPoint:CGPointMake(-10, 1)], [NSValue valueWithCGPoint:CGPointMake(-10, 2)]];
        
        NSArray * pointsForLine2 = @[[NSValue valueWithCGPoint:CGPointMake(0, 5)], [NSValue valueWithCGPoint:CGPointMake(-1, -3)], [NSValue valueWithCGPoint:CGPointMake(-4, 2)], [NSValue valueWithCGPoint:CGPointMake(-4, 3)]];
        
        NSMutableArray *sampleData = [NSMutableArray arrayWithArray:@[pointsForLine1, pointsForLine2]];
        
        return sampleData;
    }
    
    return _lines;
}

//FIXME: Some sort of error if they choose 0 for both min and max...


#pragma mark - GraphViewDelegate Methods
-(AxesRange)rangeForGraphView:(GraphView *)graphView {
    
    AxesRange axesRange;
    axesRange.min.x = -15;
    axesRange.max.x = 5;
    axesRange.min.y  = -15;
    axesRange.max.y = 15;
    
    return axesRange;
}

-(UILabel *)labelForGraphPart:(GraphPart)graphPart atCoordinate:(CGPoint)point {
    
    UILabel *coordinateLabel = [[UILabel alloc] init];
    
    if (graphPart == VerticalAxis) {
        coordinateLabel.text = [NSString stringWithFormat:@"%.0f", point.y];
    }
    else if (graphPart == HorizontalAxis) {
        coordinateLabel.text = [NSString stringWithFormat:@"%.0f", point.x];
    }
    else if (graphPart == OriginPoint){
        coordinateLabel.text = @"0";
    }
    else {
        coordinateLabel = nil;
    }
    
    return coordinateLabel;
}


-(UIColor *)colorForAxesForGraphView:(GraphView *)graphView {
    return [UIColor greenColor];
}


//TODO: Switch case instead of if/else
-(NSInteger)graphView:(GraphView *)graphView intervalForGraphPart:(GraphPart)graphPart {
    
    CGFloat interval;
    
    switch (graphPart) {
        case HorizontalAxis:
            interval = 1.0;
            break;
        case VerticalAxis:
            interval = 2.0;
            break;
        case OriginPoint:
            break;
        case LineData:
            break;
    }
    
    return interval;
}

#pragma mark - GraphViewDatasource Methods
- (NSArray *)graphView:(GraphView *)graphView coordinatesForLineAtIndex:(NSInteger)index {
    
    return self.lines[index];
    
}

- (UIColor *)graphView:(GraphView *)graphView colorForLineAtIndex:(NSInteger)index {
    if (index == 0) {
        return [UIColor redColor];
    }
    else {
        return [UIColor blueColor];
    }
}

-(NSInteger)numberOfLinesForGraphView:(GraphView *)graphView {
    return [self.lines count];
}


@end
