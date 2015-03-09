//
//  ViewController.m
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()



@end

@implementation ViewController

@synthesize minX;
@synthesize maxX;
@synthesize minY;
@synthesize maxY;
@synthesize intervalX;
@synthesize intervalY;
@synthesize points;
@synthesize lineColor;
@synthesize axesColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.graphView.delegate = self;
    
    self.minX = -15.0;
    self.minY = -4.0;
    self.maxX = 5.0;
    self.maxY = 2.0;
    self.intervalX = 5;
    self.intervalY = 1;
    self.lineColor = [UIColor whiteColor];
    self.axesColor = [UIColor grayColor];
    
    self.points = @[[NSValue valueWithCGPoint:CGPointMake(0, 1)], [NSValue valueWithCGPoint:CGPointMake(-1, -2)], [NSValue valueWithCGPoint:CGPointMake(-10, 1)], [NSValue valueWithCGPoint:CGPointMake(-10, 2)]];
    
    self.graphView.bottomColor = [UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000];;
    self.graphView.topColor = [UIColor magentaColor];
    self.graphView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
