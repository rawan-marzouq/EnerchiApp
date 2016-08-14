//
//  DisaggregationViewController.h
//  emPower App
//
//  Created by Rawan on 1/22/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

@interface DisaggregationViewController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate, XYPieChartDataSource,XYPieChartDelegate>
// Menu button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
// period segment
@property (weak, nonatomic) IBOutlet UISegmentedControl *periodSegment;
// pie chart
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;
@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray *sliceColors;
@property (strong, nonatomic) IBOutlet UILabel *centerLabel;
// details slider view
@property (weak, nonatomic) IBOutlet UIView *detailsView;
@property (nonatomic, retain) NSMutableArray *viewControllersArray;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@end
