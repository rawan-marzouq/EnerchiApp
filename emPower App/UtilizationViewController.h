//
//  UtilizationViewController.h
//  emPower App
//
//  Created by Rawan on 1/20/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"

@interface UtilizationViewController : UIViewController<XYPieChartDelegate, XYPieChartDataSource>

// dial details
@property (weak, nonatomic) IBOutlet UILabel *remainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysLeftLabel;

// comparison bar
@property (weak, nonatomic) IBOutlet UIImageView *comparisonBar;
@property (weak, nonatomic) IBOutlet UIView *userScoreView;
@property (weak, nonatomic) IBOutlet UIView *benchmarkScoreView;
@property (weak, nonatomic) IBOutlet UILabel *benchmarkNameLabel;

// DynamoDB properties
@property (nonatomic, readonly) NSMutableArray *tableRows;
@property (nonatomic, readonly) NSLock *lock;
@property (nonatomic, strong) NSDictionary *lastEvaluatedKey;
@property (nonatomic, assign) BOOL doneLoading;
// line chart data arrays
@property (nonatomic,retain) NSMutableArray* energyKW;
@property (nonatomic,retain) NSMutableArray* time;
@property (nonatomic,retain) NSMutableArray* timeLabel;
// pie chart
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray *sliceColors;
@property (strong, nonatomic) IBOutlet UILabel *centerLabel;
// menu button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
// today/month segment
@property (weak, nonatomic) IBOutlet UISegmentedControl *PeriodSegment;
- (IBAction)PeriodChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *spentView;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UIButton *chartButton;
- (IBAction)chartButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@end
