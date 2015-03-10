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

@synthesize intervalX;
@synthesize intervalY;

@synthesize axesColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.graphView.delegate = self;
    self.graphView.datasource = self;
    
    self.intervalX = 5;
    self.intervalY = 1;
    self.axesColor = [UIColor grayColor];
    
    self.graphView.bottomColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000];;
    self.graphView.topColor = [UIColor magentaColor];
    self.graphView.backgroundColor = [UIColor clearColor];
}

-(NSArray *)lines {
    if (!_lines) {
        
        NSArray * pointsForLine1 = @[[NSValue valueWithCGPoint:CGPointMake(0, 1)], [NSValue valueWithCGPoint:CGPointMake(-1, -2)], [NSValue valueWithCGPoint:CGPointMake(-10, 1)], [NSValue valueWithCGPoint:CGPointMake(-10, 2)]];
        
        NSArray * pointsForLine2 = @[[NSValue valueWithCGPoint:CGPointMake(0, 5)], [NSValue valueWithCGPoint:CGPointMake(-1, -3)], [NSValue valueWithCGPoint:CGPointMake(-4, 2)], [NSValue valueWithCGPoint:CGPointMake(-4, 3)]];
        
        NSMutableArray *sampleData = [NSMutableArray arrayWithArray:@[pointsForLine1, pointsForLine2]];
        
        return sampleData;
    }
    
    return _lines;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(AxesRange)rangeForGraphView:(GraphView *)graphView {
    AxesRange axesRange;
    axesRange.min.x = -15;
    axesRange.max.x = 5;
    axesRange.min.y  = -4;
    axesRange.max.y = 2;
    
    return axesRange;
}

- (NSArray *)graphView:(GraphView *)graphView coordinatesForLineAtIndex:(NSInteger)index {
    
    return self.lines[index];
    
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    if (index == 0) {
        return [UIColor redColor];
    }
    else {
        return [UIColor blueColor];
    }
}

-(NSInteger)numberOfLines {
    return [self.lines count];
}

-(NSString *)labelForDataAtPoint:(CGPoint)point forAxis:(Axis)axis {
    if (axis == AxisX) {
        return [NSString stringWithFormat:@"%.0f", point.x];
    }
    else if (axis == AxisY) {
        return [NSString stringWithFormat:@"%.0f", point.y];
    }
    
    return nil; //should have some sort of error handling
}

-(CGPoint)offsetForLabelAtPoint:(CGPoint)point {
    
}

@end
