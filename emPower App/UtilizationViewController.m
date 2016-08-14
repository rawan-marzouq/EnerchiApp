//
//  UtilizationViewController.m
//  emPower App
//
//  Created by Rawan on 1/20/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "UtilizationViewController.h"
#import "SWRevealViewController.h"
#import "FSLineChart.h"
#import "UIColor+FSPalette.h"
#import "DSBarChart.h"

@interface UtilizationViewController ()
{
    NSNumber *stop;
    NSNumber *start;
    int chartflag;
    UIView *lineChart;
    UIView *barGraph;
}
// JSON file keys for budget
@property (nonatomic,assign) float currentMonthCost;
@property (nonatomic, assign) float totalBudget;
@property (nonatomic, assign) float paceBudget;
@property (nonatomic, assign) int daysLeft;
@property (nonatomic, assign) int userScore;
@property (nonatomic, assign) int benchmarkScore;
@property (nonatomic, retain) NSString *benchmarkName;

// JSON monthly data properties
@property (nonatomic,retain) NSArray *monthlyData;
@property (nonatomic,retain) NSMutableArray *monthlyTimestamp;
@property (nonatomic,retain) NSMutableArray *monthlyKwh;
@end

@implementation UtilizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // chart button is off - default value
    chartflag = 0;
    // hide chart view, and show spent view (text)
    self.chartView.hidden = YES;
    self.spentView.hidden = NO;
    
    // show loading view
    self.loadingView.hidden = NO;
    
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
    navTitleView.text = @"Utilization";
    [navTitleView sizeToFit];
    
    // adjest period segment font
    UIFont *font = [UIFont boldSystemFontOfSize:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:UITextAttributeFont];
    [self.PeriodSegment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    // set budget data
    [self setBudgetData];
    
    // add dial
    [self.pieChart setDataSource:self];
    [self.pieChart setPieCenter:CGPointMake(77, 91)];
    [self.pieChart setStartPieAngle:M_PI_2];
    [self.pieChart setPieBackgroundColor:[UIColor colorWithWhite:1 alpha:1]];
    [self.pieChart setAnimationSpeed:1.0];
    self.pieChart.showLabel = NO;
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setUserInteractionEnabled:NO];
    
    // dial slices colors
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:23.0f/255.0f green:127.0f/255.0f blue:53.0f/255.0f alpha:1.0f],// green
                       [UIColor colorWithRed:224.0f/255.0f green:224.0f/255.0f blue:224.0f/255.0f alpha:1.0f],// light gray
                       nil];
    
    // dial data
    self.slices = [NSMutableArray arrayWithCapacity:2];
    
    // set dial value data
    NSNumber *value = [NSNumber numberWithFloat:(self.currentMonthCost/self.totalBudget) * 100];
    NSNumber *rest = [NSNumber numberWithFloat:100 - (self.currentMonthCost/self.totalBudget)];
    [self.slices addObject:value];
    [self.slices addObject:rest];
    
    // dial center label
    [self.centerLabel.layer setCornerRadius:40];
    if (self.currentMonthCost <= (self.paceBudget + 0.02 * self.totalBudget))
    {
        self.centerLabel.text = @"on track";
    }
    else
    {
        self.centerLabel.text = @"not on track";
    }
    
    // set dial details
    self.remainingLabel.text = [NSString stringWithFormat:@"$%.2f",self.totalBudget - self.currentMonthCost];
    self.daysLeftLabel.text = [NSString stringWithFormat:@"%i",self.daysLeft];
    
    // comparison bar
    float step =  self.comparisonBar.frame.size.width / 100;
    
    // remove markers from supper view
    [self.userScoreView removeFromSuperview];
    [self.benchmarkScoreView removeFromSuperview];
    
    // set user location
    float userLocation = step * self.userScore;
    self.userScoreView.frame = CGRectMake(userLocation, self.userScoreView.frame.origin.y, self.userScoreView.frame.size.width, self.userScoreView.frame.size.height);
    
    //set benchmark location
    float benchmarkLocation = step * self.benchmarkScore;
    self.benchmarkScoreView.frame = CGRectMake(benchmarkLocation, self.benchmarkScoreView.frame.origin.y, self.benchmarkScoreView.frame.size.width, self.benchmarkScoreView.frame.size.height);
    
    // add markers
    [self.view addSubview:self.userScoreView];
    [self.view addSubview:self.benchmarkScoreView];
    
    // set benchmark name
    self.benchmarkNameLabel.text = self.benchmarkName;
    
    // assign DynamoDB properties
    _tableRows = [NSMutableArray new];
    _lock = [NSLock new];
    
    // load DynamoDB table contents
//    [self setupTable];
    
    // set start and stop timestamp values
    stop = [NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970]];
    start = [NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970] - (24 * 60 * 60)];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    // reload pie chart data
    [self.pieChart reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)chartButtonPressed:(id)sender
{
    [lineChart removeFromSuperview];
    [barGraph removeFromSuperview];
    if(chartflag == 0)
    {
        if(self.PeriodSegment.selectedSegmentIndex == 0) // line chart
        {
            // re-plot the line chart
            [self performSelector:@selector(rePlotLineChart) withObject:nil afterDelay:1];
        }
        else // bar graph
        {
            // draw bar graph
            [self getBarGraphData];
        }
        
        // flipping view animation
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.spentView cache:NO];
                         }];
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.chartView cache:NO];
                         }];
        chartflag = 1;
        self.spentView.hidden = YES;
        self.chartView.hidden = NO;
        // change chart button image
        [self.chartButton setBackgroundImage:[UIImage imageNamed:@"chartButtonOn.png"] forState:UIControlStateNormal];
    }
    else
    {
        // flipping animation
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.chartView cache:NO];
                         }];
        [UIView animateWithDuration:0.75
                         animations:^{
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.spentView  cache:NO];
                         }];
        chartflag = 0;
        self.spentView.hidden = NO;
        self.chartView.hidden = YES;
        // change chart button image
        [self.chartButton setBackgroundImage:[UIImage imageNamed:@"chartButtonOff.png"] forState:UIControlStateNormal];
    }
    
    
}

- (IBAction)PeriodChanged:(id)sender
{
    [lineChart removeFromSuperview];
    [barGraph removeFromSuperview];
    if (self.PeriodSegment.selectedSegmentIndex == 0) // day - Line Chart
    {
        // set start and stop timestamp values for one day
        stop = [NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970] - (61 * 24 * 60 * 60)];
        start = [NSNumber numberWithFloat:[[NSDate date] timeIntervalSince1970] - (60 * 24 * 60 * 60)];
        // reload DynamoDB table contents
//        [self setupTable];
        // re-plot the line chart
        [self performSelector:@selector(rePlotLineChart) withObject:nil afterDelay:1];
    }
    else // month
    {
        // draw bar graph
        [self getBarGraphData];
        
    }
    
}


// convert timestamp to HH:MM format

#pragma mark - Accessories
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


-(void)setBudgetData
{
    NSDictionary *jsonData = [self parseJsonWithName:@"summary"];
    for (NSDictionary *item in jsonData)
    {
        self.currentMonthCost = [[[[item objectForKey:@"consumption"] objectForKey:@"currentMonth"] objectForKey:@"cost"] floatValue];
        self.totalBudget = [[[item objectForKey:@"budget"] objectForKey:@"total"] floatValue];
        self.paceBudget = [[[item objectForKey:@"budget"] objectForKey:@"pace"] floatValue];
        self.daysLeft = [[[item objectForKey:@"budget"] objectForKey:@"daysRemaining"] intValue];
        self.userScore = [[[item objectForKey:@"efficiency"] objectForKey:@"userScore"] intValue];
        // subDictionary - benchmarks
        NSArray *benchmarks = [[item objectForKey:@"efficiency" ] objectForKey:@"benchmarks"];
        NSDictionary *benchmark = (NSDictionary *)[benchmarks objectAtIndex:0];
        self.benchmarkScore = [[benchmark objectForKey:@"score"] intValue];
        self.benchmarkName = [benchmark objectForKey:@"name"];
    }
}


#pragma mark - Bar Graph
-(void)getBarGraphData
{
    self.monthlyTimestamp = [[NSMutableArray alloc]init];
    self.monthlyKwh = [[NSMutableArray alloc]init];
    NSDictionary *jsonData = [self parseJsonWithName:@"monthly"];
    for(NSDictionary *item in jsonData)
    {
        self.monthlyData = [[[item objectForKey:@"utilizationData"] objectForKey:@"monthly"] objectForKey:@"data"];
        for(int i=0; i< [self.monthlyData count]; i++)
        {
            NSDictionary *dataItem = (NSDictionary *)[self.monthlyData objectAtIndex:i];
            [self.monthlyTimestamp addObject:[self convertEpoch:[[dataItem objectForKey:@"timestamp"] intValue] toHours:NO]];
            [self.monthlyKwh addObject:[dataItem objectForKey:@"kWh" ]];
        }
    }
    
    for(int i =0; i<[self.monthlyData count]; i++)
    {
        NSLog(@"monthlyTimestamp: %@, kwh:%@", [self.monthlyTimestamp objectAtIndex:i],[self.monthlyKwh objectAtIndex:i]);
    }
    [self plotBarGraphWithvalue:self.monthlyKwh andRefrance:self.monthlyTimestamp];
    [self.chartView addSubview:barGraph];
}

-(void)plotBarGraphWithvalue:(NSArray*)value andRefrance:(NSArray*)refrance
{
    // data - Y axis (spent value)
    NSArray *vals = value;
    
    // data - X axis (day or month)
    NSArray *refs = refrance;
    
    DSBarChart *chrt = [[DSBarChart alloc] initWithFrame:self.chartView.bounds
                                                   color:[UIColor greenColor]
                                              references:refs
                                               andValues:vals];
    chrt.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    chrt.bounds = self.chartView.bounds;
    barGraph = chrt;
}
#pragma mark - Line Chart
-(FSLineChart*)lineChart {
    // seting chart data
    self.energyKW = [[NSMutableArray alloc]init];
    self.time = [[NSMutableArray alloc]init];
    self.timeLabel = [[NSMutableArray alloc]init];
    
    // fill energyKW array with data from DynamoDB table - yAxis
    // plot specific numbers of rows
    for (int numberOfRows = 0; numberOfRows < [self.tableRows count]; numberOfRows = numberOfRows+2)
    {
//        DDBTableRow *item = [self.tableRows objectAtIndex:numberOfRows];
//        [self.energyKW addObject:item.energy_kw];
    }
    // plot all data
    //    for (DDBTableRow *item in self.tableRows) {
    //        NSLog(@"item.energy_kw %@",item.energy_kw);
    //        [self.energyKW addObject:item.energy_kw];
    //    }
    
    
    // fill time and timeLabel arrays with data from DynamoDB table - xAxis
    // plot specific numbers of rows
    for (int numberOfRows = 0; numberOfRows < [self.tableRows count]; numberOfRows = numberOfRows+2)
    {
//        DDBTableRow *item = [self.tableRows objectAtIndex:numberOfRows];
//        [self.time addObject:item.timestamp];
//        [self.timeLabel addObject:[self convertEpoch:[item.timestamp intValue] toHours:YES]];
    }
    // plot all data
    //    for (DDBTableRow *item in self.tableRows) {
    //        NSLog(@"item.timestamp %@",item.timestamp);
    //        [self.time addObject:item.timestamp];
    //
    //        [self.timeLabel addObject:[self convertEpoch:[item.timestamp intValue] toHours:YES]];
    //        NSLog(@"timeLabel: %@",[self convertEpoch:[item.timestamp intValue] toHours:YES]);
    //    }
    
    // Creating the line chart
    FSLineChart* lineChartGraph = [[FSLineChart alloc] initWithFrame:CGRectMake(0, 0, self.chartView.frame.size.width - 10 , self.chartView.frame.size.height - 10)];
    lineChartGraph.verticalGridStep = 2;
    lineChartGraph.horizontalGridStep = 10;
    lineChartGraph.color = [UIColor colorWithRed:23.0f/255.0f green:127.0f/255.0f blue:53.0f/255.0f alpha:1.0f];
    lineChartGraph.fillColor = [lineChartGraph.color colorWithAlphaComponent:0.3];
    lineChartGraph.displayDataPoint = NO;
    lineChartGraph.displayDataPointLabel = NO;
    lineChartGraph.labelForIndex = ^(NSUInteger item) {
        return self.timeLabel[item];
    };
    lineChartGraph.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.0f kw", value];
    };
    [lineChartGraph setChartData:self.energyKW];
    return lineChartGraph;
}

-(void)rePlotLineChart
{
    lineChart = [self lineChart];
    [self.chartView addSubview:lineChart];
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
#pragma mark - DynamoDB management
/*
- (void)setupTable {
    // See if the test table exists.
    [[DDBDynamoDBManager describeTable]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         // If the test table doesn't exist.
         if ([task.error.domain isEqualToString:AWSDynamoDBErrorDomain]
             && task.error.code == AWSDynamoDBErrorResourceNotFound) {
             NSLog(@"There is no such table");
         } else {
             //load table contents
             [self refreshList:YES];
         }
         
         return nil;
     }];
}

- (BFTask *)refreshList:(BOOL)startFromBeginning {
    if ([self.lock tryLock]) {
        if (startFromBeginning) {
            self.lastEvaluatedKey = nil;
            self.doneLoading = NO;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        // query method
        AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
        // set conditions - get values depending on start/stop values
        NSMutableDictionary *conditions = [[NSMutableDictionary alloc] init];
        AWSDynamoDBCondition *timeStampCond = [[AWSDynamoDBCondition alloc] init];
        timeStampCond.comparisonOperator = AWSDynamoDBComparisonOperatorBetween;
        // create stop attribute value
        AWSDynamoDBAttributeValue * timestampStop = [AWSDynamoDBAttributeValue new];
        // set stop attribute value with string
        timestampStop.N = [stop stringValue];
        // create start attribute value
        AWSDynamoDBAttributeValue * timestampStart = [AWSDynamoDBAttributeValue new];
        // set start attribute value with string
        timestampStart.N = [start stringValue];
        // create attributes list
        NSArray *attrList = [[NSArray alloc]initWithObjects:timestampStart,timestampStop, nil];
        timeStampCond.attributeValueList = attrList;
        [conditions setObject:timeStampCond forKey:@"timestamp"];
        
        // setting query parameters
        queryExpression.hashKeyValues = @"1234567";
        queryExpression.rangeKeyConditions = conditions;
        queryExpression.exclusiveStartKey = self.lastEvaluatedKey;
        //        queryExpression.limit = @20;
        
        return [[[dynamoDBObjectMapper query:[DDBTableRow class]
                                  expression:queryExpression]
                 continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task)
                 
                 {
                     if (!self.lastEvaluatedKey) {
                         [self.tableRows removeAllObjects];
                     }
                     
                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (DDBTableRow *item in paginatedOutput.items) {
                         [self.tableRows addObject:item];
                     }
                     
                     self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey;
                     if (!paginatedOutput.lastEvaluatedKey) {
                         self.doneLoading = YES;
                         
                     }
                     
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     // hide loading view
                     self.loadingView.hidden = YES;
                     return nil;
                 }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                     if (task.error) {
                         NSLog(@"Error: [%@]", task.error);
                     }
                     
                     [self.lock unlock];
                     
                     return nil;
                 }];
    }
    
    return nil;
}
*/

@end
