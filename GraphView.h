//
//  GraphView.h
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphViewDelegate.h"
#import "GraphViewDatasource.h"


IB_DESIGNABLE
@interface GraphView : UIView

@property (weak, nonatomic) id<GraphViewDelegate>delegate;
@property (weak, nonatomic) id<GraphViewDatasource>datasource;
@property (nonatomic) IBInspectable UIColor *bottomColor;
@property (nonatomic) IBInspectable UIColor *topColor;

@property (nonatomic) NSInteger axesLineWidth;
@property (nonatomic) NSInteger lineDataWidth;

@end
