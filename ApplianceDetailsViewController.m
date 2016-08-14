//
//  ApplianceDetailsViewController.m
//  emPower App
//
//  Created by Rawan on 3/23/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "ApplianceDetailsViewController.h"
#import "FSLineChart.h"
#import "UIColor+FSPalette.h"
#import "CCSPieChart.h"
#import "CCSTitleValueColor.h"

@interface ApplianceDetailsViewController ()
{
    NSString *applName, *status, *onOff;
    int percent, hoursOn;
    float spent;
    NSMutableArray *graphTimestampLabel, *graphSpent, *graphSmart, *applianceData;
    UIView *lineChart;
}
@end

@implementation ApplianceDetailsViewController
@synthesize applianceIndex;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.applianceName = [[NSUserDefaults standardUserDefaults] stringForKey:@"applianceName"];
    NSLog(@"ApplianceName: %@", self.applianceName);
    [self setData];
    self.applienceOnOffStatus.text = [NSString stringWithFormat:@"%@ is %@", applName, onOff];
    self.spentLabel.text = [NSString stringWithFormat:@"%.2f$",spent];
    
    if([status isEqualToString:@"On"])
        self.onOffIcon.image = [UIImage imageNamed:@"green_small_circle"];
    else
        self.onOffIcon.image = [UIImage imageNamed:@"red_small_circle"];
    
    self.onOffPeriodLabel.text = [NSString stringWithFormat:@"%i", hoursOn];
    self.consumptionLabel.text = [NSString stringWithFormat:@"%i%%", percent];
    self.statusLabel.text = [NSString stringWithFormat:@"%@",status];
    self.applianceIcon.image = [UIImage imageNamed:self.applianceName];
    self.smartKeyLabel.text = [NSString stringWithFormat:@"Smart %@", self.applianceName];
    [self plotLineChart];
    [self drawTableWatchForAppliance];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)setValue:(NSString*)name
//{
//    self.applianceName = name;
//}

-(void)setData
{
    NSDictionary *jsonData = [self parseJsonWithName:self.applianceName];
    for (NSDictionary *item in jsonData)
    {
        applName = [[item objectForKey:@"applianceDetail"] objectForKey:@"name"];
        status = [[item objectForKey:@"applianceDetail"] objectForKey:@"status"];
        onOff = [[item objectForKey:@"applianceDetail"] objectForKey:@"onOff"];
        spent = [[[item objectForKey:@"applianceDetail"] objectForKey:@"spent"] floatValue];
        percent = [[[item objectForKey:@"applianceDetail"] objectForKey:@"percent"]intValue];
        hoursOn = [[[item objectForKey:@"applianceDetail"] objectForKey:@"hoursOn"]intValue];
        
        // monthly detailed, subDictionary - benchmarks
        applianceData = [[NSMutableArray alloc]init];
        graphTimestampLabel = [[NSMutableArray alloc]init];
        graphSpent = [[NSMutableArray alloc]init];
        graphSmart = [[NSMutableArray alloc]init];

            applianceData = [item objectForKey:@"graphData"];
            for(int i=0; i< [applianceData count]; i++)
            {
                NSDictionary *dataItem = (NSDictionary *)[applianceData objectAtIndex:i];
                [graphTimestampLabel addObject:[self convertEpoch:[[dataItem objectForKey:@"timestamp"] intValue] toHours:YES]];
                [graphSpent addObject:[dataItem objectForKey:@"spent"]];
                [graphSmart addObject:[dataItem objectForKey:@"smart"]];
            }
    }
}
#pragma mark - Draw Watch
-(void)drawTableWatchForAppliance{
    
    CCSPieChart *piechart = [[CCSPieChart alloc] initWithFrame:CGRectMake(0, 5, 34, 34)];
    piechart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    NSMutableArray *piedata = [[NSMutableArray alloc] init];
    for (int i = 1 ; i <= 24; i++) {
        if (i <= hoursOn) {
            [piedata addObject:[[CCSTitleValueColor alloc] initWithTitle:[NSString stringWithFormat:@"h%i",i] value:100/24 color:[UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0]]];
            
            continue;
        }
        [piedata addObject:[[CCSTitleValueColor alloc] initWithTitle:[NSString stringWithFormat:@"h%i",i] value:100/24 color:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.7]]];
    }
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 24, 24)];
    centerLabel.backgroundColor = [UIColor whiteColor];
    centerLabel.clipsToBounds = YES;
    [centerLabel.layer setCornerRadius:12];

//    [piechart addSubview:centerLabel];
    
    piechart.data = piedata;
    piechart.displayValueTitle = NO;
    piechart.displayRadius = NO;
    piechart.circleBorderColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    piechart.backgroundColor = [UIColor clearColor];
    
    [self.watch addSubview:piechart];
//    return piechart;
}

#pragma mark - Line Chart
-(void)plotLineChart
{
    lineChart = [self lineChartSmart:NO];
    [self.lineChartView addSubview:lineChart];
    lineChart = [self lineChartSmart:YES];
    [self.lineChartView addSubview:lineChart];
}
-(FSLineChart*)lineChartSmart: (BOOL)smart {
    // seting chart data
    // monthly spent - yAxis
    // timestamp - xAxis
    
    // Creating line chart
    FSLineChart* lineChartGraph = [[FSLineChart alloc] initWithFrame:CGRectMake(15, 10, self.lineChartView.frame.size.width - 20 , self.lineChartView.frame.size.height - 20)];
    lineChartGraph.verticalGridStep = 5;
    lineChartGraph.horizontalGridStep = 5;
    lineChartGraph.valueLabelFont = [UIFont fontWithName:@"Helvetica Neue" size:10];
    lineChartGraph.fillColor = [UIColor clearColor];
    lineChartGraph.labelForIndex = ^(NSUInteger item) {
        return graphTimestampLabel[item];
    };
    lineChartGraph.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.0f", value];
    };
    
//    NSMutableArray *test = [[NSMutableArray alloc]init];NSMutableArray *test2 = [[NSMutableArray alloc]init];
//    for (int i = 0; i < 4; i++) {
//        [test addObject:[graphSpent objectAtIndex:i]];[test2 addObject:[NSString stringWithFormat:@"%i",i]];
//    }
    if (smart) {
        lineChartGraph.color = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];// green
        [lineChartGraph setChartData:graphSmart];
    }
    else
    {
        lineChartGraph.showlabelForValue = YES;
//        lineChartGraph.showPointLabel = YES;
        lineChartGraph.color = [UIColor orangeColor],// Orange
        [lineChartGraph setChartData:graphSpent];
    }
    
    return lineChartGraph;
}

#pragma mark - JSON
-(NSDictionary*)parseJsonWithName:(NSString*)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSString *jsonFile = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if (!jsonFile) {
        NSLog(@"File couldn't be read!");
        return NULL;
    }
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[jsonFile dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//    NSLog(@"JSON: %@", jsonDictionary);
    return jsonDictionary;
    
}

#pragma mark - Accessories
-(NSString *)convertEpoch:(int)seconds toHours:(BOOL)hour
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if(hour)
    {
        [dateFormatter setDateFormat:@"hh"];
    }
    else
    {
        [dateFormatter setDateFormat:@"dd"];
    }
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}




@end
