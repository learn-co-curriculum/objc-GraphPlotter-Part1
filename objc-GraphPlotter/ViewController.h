//
//  ViewController.h
//  objc-GraphPlotter
//
//  Created by Zachary Drossman on 3/3/15.
//  Copyright (c) 2015 Zachary Drossman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface ViewController : UIViewController <GraphViewDelegate, GraphViewDatasource>

@property (weak, nonatomic) IBOutlet GraphView *graphView;

@end

