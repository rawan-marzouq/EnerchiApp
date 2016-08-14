//
//  DisaggregationBarChartViewController.m
//  emPower App
//
//  Created by Rawan on 2/2/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "DisaggregationBarChartViewController.h"
#import "DSBarChart.h"

@interface DisaggregationBarChartViewController ()

@end

@implementation DisaggregationBarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addBarGraph];
}
#pragma mark - Bar Graph
-(void)addBarGraph
{
    // dummy data - Y axis (spent value)
    NSArray *vals = [NSArray arrayWithObjects:
                     [NSNumber numberWithInt:20],
                     [NSNumber numberWithInt:56],
                     [NSNumber numberWithInt:70],
                     [NSNumber numberWithInt:34],
                     [NSNumber numberWithInt:43],
                     nil];
    // dummy data - X axis (day or month)
    NSArray *refs = [NSArray arrayWithObjects:@"M", @"Tu", @"W", @"Th", @"F", @"Sa", @"Su", nil];
    
    DSBarChart *chrt = [[DSBarChart alloc] initWithFrame:self.barGraphView.bounds
                                                   color:[UIColor greenColor]
                                              references:refs
                                               andValues:vals];
//    chrt.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    chrt.bounds = self.barGraphView.bounds;
    [self.barGraphView addSubview:chrt];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
