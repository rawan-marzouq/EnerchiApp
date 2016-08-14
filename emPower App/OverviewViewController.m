//
//  OverviewViewController.m
//  emPower App
//
//  Created by Majd Zayed on 2/11/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "OverviewViewController.h"
#import "SWRevealViewController.h"
#import "FSLineChart.h"
#import "UIColor+FSPalette.h"
#import "DSBarChart.h"

@interface OverviewViewController ()
{
    UIView *lineChart;
    UIView *barGraph;
}
// JSON file properties
@property (nonatomic, assign) float dailySpent;
@property (nonatomic,assign) float dailyPercentage;
@property (nonatomic,assign) float dailySmartSpent;
@property (nonatomic,assign) float monthlySpent;
@property (nonatomic,assign) float monthlySaved;
@property (nonatomic,assign) float monthlyImproved;

@property (nonatomic,assign) float monthlyProjected;
@property (nonatomic,assign) float monthlyOtherSpent;
@property (nonatomic,retain) NSMutableArray *monthlyTimestamp;
@property (nonatomic,retain) NSMutableArray *monthlyTimestampLabel;
@property (nonatomic,retain) NSMutableArray *monthlyCost;
@end

@implementation OverviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set menu button action
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    
    // set view gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    // set header title
    UILabel *navTitleView = (UILabel *)self.navigationItem.titleView;
    if (!navTitleView) {
        navTitleView = [[UILabel alloc] initWithFrame:CGRectZero];
        navTitleView.backgroundColor = [UIColor clearColor];
        navTitleView.font = [UIFont boldSystemFontOfSize:22.0];
        navTitleView.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = navTitleView;
    }
    navTitleView.text = @"Enerchi";
    [navTitleView sizeToFit];
    
    
    // add dial
    [self.pieChart setDataSource:self];
    [self.pieChart setPieCenter:CGPointMake(140, 140)];
    [self.pieChart setStartPieAngle:M_PI_2];
    [self.pieChart setPieBackgroundColor:[UIColor colorWithRed:231.0f/255.0f green:237.0f/255.0f blue:243.0f/255.0f alpha:1.0f]];
    [self.pieChart setAnimationSpeed:1.0];
    self.pieChart.showLabel = NO;
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setUserInteractionEnabled:NO];
    
    // dial slices colors
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:26.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f],// blue
                       [UIColor colorWithRed:205.0f/255.0f green:221.0f/255.0f blue:232.0f/255.0f alpha:1.0f],// light blue-gray
                       nil];
    // set overview page data
    [self setData];
    
    // dial data
    self.slices = [NSMutableArray arrayWithCapacity:2];
    
    // set dial value data
    NSNumber *value = [NSNumber numberWithFloat:(self.dailyPercentage / 100) * 50 + 25];
    NSLog(@"value: %@", value);
    NSNumber *rest = [NSNumber numberWithFloat:100 - ((self.dailyPercentage / 100) * 50 + 25)];
    [self.slices addObject:value];
    [self.slices addObject:rest];
    
    // dial center label
    [self.centerLabel.layer setCornerRadius:100];
    self.todaySpendLabel.text = [NSString stringWithFormat:@"$%.2f", self.dailySpent];
    self.smartAuditButton.layer.cornerRadius = 10;
    // set data labels text
    self.smartSpendLabel.text = [NSString stringWithFormat:@"$%.2f",self.dailySmartSpent];
    self.spentLabel.text = [NSString stringWithFormat:@"$%.0f",self.monthlySpent];
    self.SavedLabel.text = [NSString stringWithFormat:@"$%.0f",self.monthlySaved];
    self.ImprovedLabel.text = [NSString stringWithFormat:@"$%.0f",self.monthlyImproved];
    
    // add line chart
//    [self plotLineChart];
    
    // draw bar graph
    [self getBarGraphData];
}
-(void)viewDidAppear:(BOOL)animated
{
    // reload pie chart data
    [self.pieChart reloadData];
}
-(void)setData
{
    NSDictionary *jsonData = [self parseJsonWithName:@"overview"];
    for (NSDictionary *item in jsonData)
    {
        // daily data
        self.dailySpent = [[[[item objectForKey:@"overview"] objectForKey:@"dailyBudget"] objectForKey:@"spent"] floatValue];
        self.dailyPercentage = [[[[item objectForKey:@"overview"] objectForKey:@"dailyBudget"] objectForKey:@"percentage"] floatValue];
        self.dailySmartSpent = [[[[item objectForKey:@"overview"] objectForKey:@"dailyBudget"] objectForKey:@"smartSpent"] floatValue];
        
        // monthly data
        self.monthlySpent = [[[[item objectForKey:@"overview"] objectForKey:@"monthlyStats"] objectForKey:@"spent"] floatValue];
        self.monthlySaved = [[[[item objectForKey:@"overview"] objectForKey:@"monthlyStats"] objectForKey:@"saved"] floatValue];
        self.monthlyImproved = [[[[item objectForKey:@"overview"] objectForKey:@"monthlyStats"] objectForKey:@"improved"] floatValue];
        
        // monthly detailed, subDictionary - benchmarks
        self.monthlyTimestampLabel = [[NSMutableArray alloc]init];
        self.monthlyCost = [[NSMutableArray alloc]init];
        NSArray *monthlyDataArray = [[[item objectForKey:@"overview" ] objectForKey:@"monthlyStats"] objectForKey:@"data"];
        
        for(int i=0; i < [monthlyDataArray count]; i++)
        {
            NSDictionary *monthlyData = (NSDictionary *)[monthlyDataArray objectAtIndex:i];
            [self.monthlyTimestampLabel addObject:[self convertEpoch:[[monthlyData objectForKey:@"timestamp"] intValue] toHours:NO]];
            [self.monthlyCost addObject:[monthlyData objectForKey:@"cost"]];
        }
    }
}
-(NSString *)convertEpoch:(int)seconds toHours:(BOOL)hour
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if(hour)
    {
        [dateFormatter setDateFormat:@"hh:mm"];
    }
    else
    {
        [dateFormatter setDateFormat:@"dd"];
    }
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return jsonDictionary;
    
}
#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return [self.slices count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index]floatValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}
#pragma mark - Line Chart
-(FSLineChart*)lineChart {
    // seting chart data
    // monthly spent - yAxis
    // timestamp - xAxis
    
    // Creating line chart
    FSLineChart* lineChartGraph = [[FSLineChart alloc] initWithFrame:CGRectMake(10, 10, self.lineChartView.frame.size.width - 20 , self.lineChartView.frame.size.height - 20)];
    lineChartGraph.verticalGridStep = 5;
    lineChartGraph.horizontalGridStep = 8;
    lineChartGraph.color = [UIColor colorWithRed:26.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f],// blue
    lineChartGraph.fillColor = [lineChartGraph.color colorWithAlphaComponent:0.3];
    lineChartGraph.labelForIndex = ^(NSUInteger item) {
        return self.monthlyTimestampLabel[item];
    };
    lineChartGraph.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"$%.0f", value];
    };
    [lineChartGraph setChartData:self.monthlyCost];
    return lineChartGraph;
}
-(void)plotLineChart
{
    lineChart = [self lineChart];
    [self.lineChartView addSubview:lineChart];
}


#pragma mark - Bar Graph
-(void)getBarGraphData
{
//    self.monthlyTimestamp = [[NSMutableArray alloc]init];
//    self.monthlyKwh = [[NSMutableArray alloc]init];
//    NSDictionary *jsonData = [self parseJsonWithName:@"monthly"];
//    for(NSDictionary *item in jsonData)
//    {
//        self.monthlyData = [[[item objectForKey:@"utilizationData"] objectForKey:@"monthly"] objectForKey:@"data"];
//        for(int i=0; i< [self.monthlyData count]; i++)
//        {
//            NSDictionary *dataItem = (NSDictionary *)[self.monthlyData objectAtIndex:i];
//            [self.monthlyTimestamp addObject:[self convertEpoch:[[dataItem objectForKey:@"timestamp"] intValue] toHours:NO]];
//            [self.monthlyKwh addObject:[dataItem objectForKey:@"kWh" ]];
//        }
//    }
//    
//    for(int i =0; i<[self.monthlyData count]; i++)
//    {
//        NSLog(@"monthlyTimestamp: %@, kwh:%@", [self.monthlyTimestamp objectAtIndex:i],[self.monthlyKwh objectAtIndex:i]);
//    }
    [self plotBarGraphWithvalue:self.monthlyCost andRefrance:self.monthlyTimestampLabel];
    [self.barChartScrollingView addSubview:barGraph];
}

-(void)plotBarGraphWithvalue:(NSArray*)value andRefrance:(NSArray*)refrance
{
    self.barChartScrollingView.contentSize = CGSizeMake(1600,self.barChartScrollingView.frame.size.height);
    // data - Y axis (spent value)
    NSArray *vals = value;
    
    // data - X axis (day or month)
    NSArray *refs = refrance;
    
    DSBarChart *chrt = [[DSBarChart alloc] initWithFrame:self.barChartScrollingView.bounds
                                                   color:[UIColor colorWithRed:26.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f]
                                              references:refs
                                               andValues:vals];
    chrt.color = [UIColor colorWithRed:26.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
    chrt.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    chrt.bounds = self.barChartScrollingView.bounds;
    barGraph = chrt;
}
#pragma mark - IBActions
- (IBAction)smartAuditPressed:(id)sender {
}
@end
