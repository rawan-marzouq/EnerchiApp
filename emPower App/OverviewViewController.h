//
//  OverviewViewController.h
//  emPower App
//
//  Created by Majd Zayed on 2/11/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

@interface OverviewViewController : UIViewController<XYPieChartDelegate, XYPieChartDataSource>
// menu button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
// pie chart
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray *sliceColors;
@property (strong, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UILabel *todaySpendLabel;
// data view
@property (strong, nonatomic) IBOutlet UILabel *spentLabel;
@property (strong, nonatomic) IBOutlet UILabel *SavedLabel;
@property (strong, nonatomic) IBOutlet UILabel *ImprovedLabel;
@property (weak, nonatomic) IBOutlet UILabel *smartSpendLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayLabel;
// line chart
@property (strong, nonatomic) IBOutlet UIView *lineChartView;
// bar chart
@property (weak, nonatomic) IBOutlet UIScrollView *barChartScrollingView;

// buttons
@property (weak, nonatomic) IBOutlet UIButton *smartAuditButton;
// BTNs action
- (IBAction)smartAuditPressed:(id)sender;

@end
