//
//  GraphViewDatasource.h
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/9/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GraphView;

@protocol GraphViewDatasource <NSObject>


//TODO: Add graphView to all datasource methods
- (NSInteger)numberOfLinesForGraphView:(GraphView *)graphView;
- (UIColor *)graphView:(GraphView *)graphView colorForLineAtIndex:(NSInteger)index;
- (NSArray *)graphView:(GraphView *)graphView coordinatesForLineAtIndex:(NSInteger)index;

//ideally this would be optional
- (NSInteger)graphView:(GraphView *)graphView intervalForGraphPart:(GraphPart)axis;

@end
