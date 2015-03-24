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
    
    //self.graphView = [[GraphView alloc] initWithLineData:self.lines lineColor:@[[UIColor grayColor]] lineWidths:@[@(5)]];
    self.graphView.bottomColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000];;
    self.graphView.topColor = [UIColor magentaColor];
    self.graphView.backgroundColor = [UIColor clearColor];
    self.graphView.lineData = [[NSArray alloc] initWithArray:self.lines];
    self.graphView.lineColors = @[[UIColor grayColor]];
    self.graphView.lineWidths = @[@(5)];
    [self.graphView setNeedsDisplay];
}


-(NSArray *)lines {
    
    //TODO: make an objc wrapper around CGPoint so don't have to do NSValue stuff
    
    if (!_lines) {
        
        NSArray * pointsForLine1 = @[[NSValue valueWithCGPoint:CGPointMake(-1,0)], [NSValue valueWithCGPoint:CGPointMake(-5,2)], [NSValue valueWithCGPoint:CGPointMake(4,-2)], [NSValue valueWithCGPoint:CGPointMake(10,-1)], [NSValue valueWithCGPoint:CGPointMake(-2,-2)], [NSValue valueWithCGPoint:CGPointMake(-1,-1)], [NSValue valueWithCGPoint:CGPointMake(10,-5)], [NSValue valueWithCGPoint:CGPointMake(5,5)], [NSValue valueWithCGPoint:CGPointMake(5,6)],[NSValue valueWithCGPoint:CGPointMake(-6,1)]];
        
        NSMutableArray *sampleData = [NSMutableArray arrayWithArray:@[pointsForLine1]];
        
        return sampleData;
    }
    
    return _lines;
}

@end
