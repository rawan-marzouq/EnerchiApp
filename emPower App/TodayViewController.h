//
//  TodayViewController.h
//  emPower App
//
//  Created by Rawan Marzouq on 6/20/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPRadarChart.h"
#import "XYPieChart.h"
#include "EAGLView.h"
#import "CorePlot-CocoaTouch.h"
#import "PlotItem.h"

@class PlotItem;
@interface TodayViewController : UIViewController<RPRadarChartDataSource, RPRadarChartDelegate, XYPieChartDelegate, XYPieChartDataSource>
{
    NSDate *now;
    UIView *rcView;
    RPRadarChart *rc;
    NSTimer *myTimer;
    
}
- (IBAction)tmGreenLeafPressed:(id)sender;

// menu button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIView *dialView;
// pie chart
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray *sliceColors;
// Leaves
@property (weak, nonatomic) IBOutlet UIBarButtonItem *notificationLeaf;
@property (weak, nonatomic) IBOutlet UIImageView *greenLeaf;
@property (weak, nonatomic) IBOutlet UILabel *nowLabel;

@property (weak, nonatomic) IBOutlet EAGLView *lineGraph;
@property (nonatomic, strong) CPTGraphHostingView *hostView;

@property (weak, nonatomic) IBOutlet UILabel *maxValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *cost;
@property (weak, nonatomic) IBOutlet UILabel *vampireLoadValue;

@end
