//
//  BillingPeriodViewController.h
//  emPower App
//
//  Created by Rawan on 5/18/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYPieChart.h"
#import "FSCalendar.h"
#import <ABCalendarPicker/ABCalendarPicker.h>

@interface BillingPeriodViewController : UIViewController<XYPieChartDelegate, XYPieChartDataSource, FSCalendarDataSource, FSCalendarDelegate, ABCalendarPickerDelegateProtocol,UIAccelerometerDelegate>{
NSArray *arr;
    int count;

}

- (IBAction)tmGreenLeafPressed:(id)sender;

// menu button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
// pie chart
@property (weak, nonatomic) IBOutlet XYPieChart *pieChart;
@property(nonatomic, strong) NSMutableArray *slices;
@property(nonatomic, strong) NSArray *sliceColors;
@property (strong, nonatomic) IBOutlet UILabel *centerLabel;
// current month label
@property (weak, nonatomic) IBOutlet UILabel *currentMonthLabel;
// monthly data
@property (weak, nonatomic) IBOutlet UILabel *monthlySpentLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthlySavedLabel;
// calendar
@property (weak,   nonatomic) IBOutlet FSCalendar *calendar;
@property (assign, nonatomic) NSInteger      theme;
@property (assign, nonatomic) FSCalendarFlow flow;
@property (assign, nonatomic) BOOL           lunar;
@property (copy,   nonatomic) NSDate         *selectedDate;
@property (assign, nonatomic) NSUInteger     firstWeekday;
// budget button
@property (weak, nonatomic) IBOutlet UIButton *budgetButton;
- (IBAction)setBudget:(id)sender;

// yearly calendar
@property (weak, nonatomic) IBOutlet ABCalendarPicker *yearlyCalendar;
- (IBAction)calButtonPressed:(id)sender;


@end
