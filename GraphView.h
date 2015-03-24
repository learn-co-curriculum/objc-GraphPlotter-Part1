//
//  GraphView.h
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface GraphView : UIView

@property (nonatomic) IBInspectable UIColor *bottomColor;
@property (nonatomic) IBInspectable UIColor *topColor;

@property (strong, nonatomic) NSArray *lineData;
@property (strong, nonatomic) NSArray *lineColors;
@property (strong, nonatomic) NSArray *lineWidths;

- (instancetype)initWithLineData:(NSArray *)linedata lineColor:(NSArray *)colors lineWidths:(NSArray *)lineWidths;

@end
