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

- (NSInteger)numberOfLines;
- (UIColor *)colorForLineAtIndex:(NSInteger)index;
- (NSArray *)graphView:(GraphView *)graphView coordinatesForLineAtIndex:(NSInteger)index;


@end
