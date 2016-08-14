//
//  HomeViewController.h
//  emPower App
//
//  Created by Rawan on 3/13/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RPRadarChart.h"
#import "XYPieChart.h"

@interface HomeViewController : UIViewController<RPRadarChartDataSource, RPRadarChartDelegate, UITableViewDataSource, UITableViewDelegate, XYPieChartDelegate, XYPieChartDataSource>
{
    RPRadarChart *rc;
}
// menu button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIView *dialView;
@property (weak, nonatomic) IBOutlet UITableView *applianceTable;
@property (weak, nonatomic) IBOutlet UILabel *youSpentLabel;
@property (weak, nonatomic) IBOutlet UILabel *smartSpendingLabel;
// pie chart
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray *sliceColors;
@property (strong, nonatomic) IBOutlet UILabel *centerLabel;
// Leaves
@property (weak, nonatomic) IBOutlet UIBarButtonItem *notificationLeaf;
@property (weak, nonatomic) IBOutlet UIImageView *greenLeaf;
@property (weak, nonatomic) IBOutlet UIImageView *grayLeaf1;
@property (weak, nonatomic) IBOutlet UIImageView *grayLeaf2;
@property (weak, nonatomic) IBOutlet UIImageView *grayLeaf3;

@end