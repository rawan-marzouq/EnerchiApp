//

//  TodayViewController.m

//  emPower App

//

//  Created by Rawan Marzouq on 6/20/15.

//  Copyright (c) 2015 HundW. All rights reserved.

//



#import "TodayViewController.h"
#import "SWRevealViewController.h"
#import "CCSPieChart.h"
#import "CCSTitleValueColor.h"
#import "NSDate+FSExtension.h"
#import "SSLunarDate.h"
#import "JTCalendar.h"
#import "CPDConstants.h"
#import "RealTimePlot.h"


@interface TodayViewController ()<JTCalendarDataSource>

{
    
    int efficiency;
    int currMaxValue;
    float yourSpent, smartSpending;
    NSMutableArray *spentGraphData;
    NSMutableArray *smartGraphData;
    NSMutableArray *timeStampGraph;
    NSMutableArray *appliances;
    NSMutableArray *sortedAppliances;
    
    int greenLeafPosition;
    
    NSMutableArray *xArray;
    NSMutableArray *yArray;
    
    
    
    // parsed JSON data
    
    // daily
    NSMutableArray *hoursArray;
    float dailyConsumed;
    NSMutableArray *dailyAvgDemandArray;
    NSArray* rcDataArray;
    
    // weekly data
    NSMutableArray *daysArray;
    NSMutableArray *weeklyConsumedArray;
    
    // now data
    NSMutableArray *nowArray;
    NSMutableArray *nowDemandMax;
    NSMutableArray *nowDemandMin;
    float nowTotalConsumed;

    float minimumW;
    float runningTotal;
    
    NSURL *nowURL;
    NSURL *todayURL;
    NSString *token;
}

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTCalendarContentView *calendarContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarContentViewHeight;

@property (strong, nonatomic) JTCalendar *calendar;

@property (nonatomic, readwrite, strong) NSMutableArray *plotData;
@property (nonatomic, readwrite, assign) NSUInteger currentIndex;
@property (nonatomic, readwrite, strong) NSTimer *dataTimer;
@property (nonatomic, strong) PlotItem *detailItem;
@property (nonatomic, strong) IBOutlet UIView *hostingView;
@property (nonatomic, copy) NSString *currentThemeName;

@end


@implementation TodayViewController
@synthesize hostView = hostView_;
@synthesize plotData;
@synthesize currentIndex;
@synthesize dataTimer;

#pragma mark -
#pragma mark  UIViewController lifecycle methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
     // set menu button action
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
       // set view gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    todayURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/today"]];
    nowURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/today/now"]];
    
    NSLog(@"token@today: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]);
    token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    
    // set header title
    UILabel *navTitleView = (UILabel *)self.navigationItem.titleView;
    if (!navTitleView) {
        
        navTitleView = [[UILabel alloc] initWithFrame:CGRectZero];
        navTitleView.backgroundColor = [UIColor clearColor];
        navTitleView.font = [UIFont boldSystemFontOfSize:22.0];
        navTitleView.textColor = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];
        self.navigationItem.titleView = navTitleView;
    }
    
    navTitleView.text = @"Enerchi";
    [navTitleView sizeToFit];
    
    // set leaves positions arrays
    
    xArray = [[NSMutableArray alloc]initWithObjects:
              @"200", @"176", @"193", @"215", @"230", @"236", @"242", @"236", @"230", @"215", @"193", @"176",
              @"150", @"120", @"105", @"85", @"65", @"60", @"55", @"60", @"65", @"85", @"105", @"120", nil];
    
    yArray = [[NSMutableArray alloc]initWithObjects:
              @"10", @"13", @"22", @"38", @"58", @"75", @"101", @"125", @"145", @"170", @"180", @"190", @"193", @"190",
              @"180", @"170", @"145", @"125", @"101", @"75", @"58", @"38", @"22", @"13", nil];
    
    
    
    // reading JSON file
    
    [self setData];
    
    // call REST API
    [self callREST];
    
    
    NSLog(@"viewDidLoad");
    
    
    
    // radar View
    rcView = [[UIView alloc]init];
    rcView.backgroundColor = [UIColor clearColor];
    [rcView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dialView addSubview:rcView];
    [self AddConstraintToRC];
    [self addCalendarView];
    
    
    [self addEfficiencyDial];
    
}



-(void)viewDidAppear:(BOOL)animated
{
    NSDate *nowVar = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH"];
    NSString *nowString = [outputFormatter stringFromDate:nowVar];
    
    
    // leaves
    self.greenLeaf.frame = CGRectMake([[xArray objectAtIndex:[nowString intValue]]floatValue], [[yArray objectAtIndex:[nowString intValue]]floatValue], self.greenLeaf.frame.size.width, self.greenLeaf.frame.size.height);
    
    
    // line graph Up-Right clock
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss a"];
    nowString = [dateFormatter stringFromDate:nowVar];
    self.nowLabel.text = nowString;
    [self.lineGraph startAnimation];
    [self startTimer];
   
    // new real time graph
    self.detailItem = [[RealTimePlot alloc]init];
    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
    
    // reload pie chart data
    [self.pieChart reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [self.lineGraph stopAnimation];
    [self stopTimer];
}

#pragma mark -
#pragma mark Rel Time Graph Theme Selection
-(CPTTheme *)currentTheme
{
    CPTTheme *theme;
    
    theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    
    
    return theme;
}

#pragma mark - REST
-(void)callREST

{
    
    //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/ios-data/today"]];
    //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/today"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:todayURL];
    
    [request setValue:token forHTTPHeaderField:@"X-Access-Token"];
    
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     
     {
         
         if (data.length > 0 && connectionError == nil)
         {
             NSError *error = nil;
             id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingMutableContainers
                                                                error:&error];
             
             NSLog(@"TodayCallResult: %@",jsonObjects);
             
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 // Handle Error and return
                 return;
             }
             
             
             
             // daily data
             hoursArray = [[NSMutableArray alloc]init];
             dailyAvgDemandArray = [[NSMutableArray alloc]init];
             dailyConsumed = 0.0;
             runningTotal = 0.0;
             
             minimumW = [[[jsonObjects objectForKey:@"data"]objectForKey:@"minimumW"] floatValue];
             NSLog(@"Vampire Load: %f", minimumW);
             
//             self.cost.text = [NSString stringWithFormat:@"%i", (int) runningTotal];
             self.vampireLoadValue.text = [NSString stringWithFormat:@"%i", (int) minimumW];
             
             NSArray *dailyData = [[jsonObjects objectForKey:@"data"] objectForKey:@"daily"];
             
             for (int i = 0; i < [dailyData count]; i++)
                 
             {
                 NSDictionary *data = (NSDictionary*) [dailyData objectAtIndex:i];
                 NSString *dateStr = [data objectForKey:@"date"];
                 NSTimeInterval sec = [dateStr doubleValue];
                 
                 [hoursArray addObject:[self convertEpoch:sec/1000 toHours:YES]];
                 
                 
                 dailyConsumed += [[data objectForKey:@"consumed"] floatValue];
                 [dailyAvgDemandArray addObject:[data objectForKey:@"avgDemand"]];
                 
             }
             NSMutableArray *dataArray = [[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"",
                                          @"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",
                                          nil];
             for (int i = 0 ; i < hoursArray.count; i++)
             {
                 int index = [[hoursArray objectAtIndex:i]intValue];
                 [dataArray insertObject:[dailyAvgDemandArray objectAtIndex:i] atIndex:index];
             }
             
             rcDataArray = [[dataArray reverseObjectEnumerator] allObjects];
             
             
             // weekly data
             daysArray = [[NSMutableArray alloc]init];
             weeklyConsumedArray = [[NSMutableArray alloc]init];
             NSArray *weeklyData = [[jsonObjects objectForKey:@"data"] objectForKey:@"weekly"];
             
             for (int i = 0; i < [weeklyData count]; i++)
             {
                 
                 NSDictionary *data = (NSDictionary*) [weeklyData objectAtIndex:i];
                 NSString *dateStr = [data objectForKey:@"date"];
                 NSTimeInterval sec = [dateStr doubleValue];
                 
                 [daysArray addObject:[self convertEpoch:sec/1000 toHours:NO]];
                 float consumed =[[data objectForKey:@"consumed"] floatValue] * 0.11;
                 [weeklyConsumedArray addObject: [NSString stringWithFormat:@"%.2f",consumed]];
                 
             }
             
             // now data
             nowArray = [[NSMutableArray alloc]init];
             nowDemandMax = [[NSMutableArray alloc]init];
             nowDemandMin = [[NSMutableArray alloc]init];
             nowTotalConsumed = 0.0;
             NSArray *nowData = [[jsonObjects objectForKey:@"data"] objectForKey:@"now"];
             
             for (int i = 0; i < [nowData count]; i++)
             {
                 
                 NSDictionary *data = (NSDictionary*) [nowData objectAtIndex:i];
                 [nowArray addObject:[self convertEpoch:[[data objectForKey:@"date"]intValue] toHours:YES]];
                 [nowDemandMax addObject:[data objectForKey:@"demandW"]];
                 
             }
             
             NSLog(@"dailyConsumed: %f",dailyConsumed);
             NSLog(@"callREST");
  
             self.lineGraph.allPointsArray = nowDemandMax;
             [self.lineGraph reloadInputViews];
             currMaxValue = 0;

             for (int i = 0; i < nowDemandMax.count; i++) {
                 if ([[nowDemandMax objectAtIndex:i]intValue] > currMaxValue) {
                     currMaxValue = [[nowDemandMax objectAtIndex:i]intValue];
                 }
             }

             self.maxValueLabel.text = [NSString stringWithFormat:@"%i",currMaxValue];
             
         }
         
             else
             
         {
             
             NSLog(@"connectionError: %@", connectionError);
             
         }
         
         }];
    
}

#pragma mark - Add Subviews to the main view

-(void)setSubviews

{
    
    NSLog(@"setSubviews");
    
    // add Radar chart
//    if (hoursArray)
//    {
//        rc = [[RPRadarChart alloc] initWithFrame:CGRectMake(0, 0, rcView.frame.size.width, rcView.frame.size.height)];
//        rc.backgroundColor = [UIColor clearColor];
//        rc.drawGuideLines = NO;
//        rc.showGuideNumbers = NO;
//        rc.fillArea = NO;
//        rc.showValues = NO;
//        rc.dataSource = self;
//        rc.delegate = self;
//        [rcView addSubview:rc];
//    }
//    
//    
    
    
    // add efficience dial
    [self addEfficiencyDial];
    
    // add weekly calendar
    [self addCalendarView];
    
    
}


-(void)addEfficiencyDial

{
    // add dial
    [self.pieChart setDataSource:self];
    [self.pieChart setDelegate:self];
    [self.pieChart setPieCenter:CGPointMake(70, 70)];
    [self.pieChart setStartPieAngle:M_PI_2];
    [self.pieChart setPieBackgroundColor:[UIColor clearColor]];
    [self.pieChart setAnimationSpeed:0.01];
    self.pieChart.showLabel = NO;
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setUserInteractionEnabled:NO];
    
    
    
    // dial slices colors
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0],// Green
                       [UIColor lightGrayColor],// light-gray
                       nil];
    
    
    
    // dial data
    self.slices = [NSMutableArray arrayWithCapacity:2];
    
    // set dial value data
    NSNumber *value = [NSNumber numberWithInt:100];
    NSNumber *rest = [NSNumber numberWithFloat:0];
    [self.slices addObject:value];
    [self.slices addObject:rest];
    
    
    
    // efficiency number label
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20 ,20, 100, 100)];
    centerLabel.backgroundColor = [UIColor whiteColor];
    centerLabel.clipsToBounds = YES;
    [centerLabel.layer setCornerRadius:50];
    [centerLabel setNumberOfLines:2];
    centerLabel.font = [UIFont fontWithName:@"Helvetica" size:26];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];// Green
    centerLabel.text = [NSString stringWithFormat:@"$%.2f",dailyConsumed * 0.11];
    [self.pieChart addSubview:centerLabel];
    
    
    // efficiency text label
    UILabel *efficientLabel = [[UILabel alloc]initWithFrame:CGRectMake(45 ,70, 50, 50)];
    efficientLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    efficientLabel.textAlignment = NSTextAlignmentCenter;
    efficientLabel.textColor = [UIColor darkGrayColor];
    efficientLabel.text = [NSString stringWithFormat:@"spent"];
    [self.pieChart addSubview:efficientLabel];
//    [self.pieChart setBackgroundColor:[UIColor redColor]];
}

-(void)updateMaxDemand:(NSTimer*)theTimer {
    runningTotal = runningTotal + 1;
//    self.cost.text = [NSString stringWithFormat:@"%i", (int) runningTotal];
    
    NSURL *urlNow = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/today/now?seconds=1"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nowURL];
    
    [request setValue:token forHTTPHeaderField:@"X-Access-Token"];
    
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     
     {
         
         if (data.length > 0 && connectionError == nil)
         {
             NSError *error = nil;
             id jsonObjects = [NSJSONSerialization JSONObjectWithData:data
                                                              options:NSJSONReadingMutableContainers
                                                                error:&error];
             
             NSLog(@"updateMaxDemand: %@",jsonObjects);
             
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 // Handle Error and return
                 return;
             }
             
             //NSArray *arr = [[NSMutableArray alloc] init];
             
             NSString *arr = [[[jsonObjects valueForKey:@"data"] valueForKey:@"demandW"] objectAtIndex:0];
             NSLog(@"arr %@", arr);
             self.cost.text = [NSString stringWithFormat:@"$%@", arr];
             self.maxValueLabel.text = [NSString stringWithFormat:@"%@", arr];
         }
         
         else
         {
             NSLog(@"connectionError: %@", connectionError);
             
         }
         
     }];
 
}



-(void)addCalendarView
{
    
    // set calendar properties
    self.calendar = [JTCalendar new];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    
    {
        self.calendar.calendarAppearance.calendar.firstWeekday = 2; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 9. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 2.;
        self.calendar.calendarAppearance.focusSelectedDayChangeMode = YES;
        self.calendarContentView.subtitlesArray = weeklyConsumedArray;
        self.calendarContentView.dateArray = daysArray;
        NSLog(@"daysArray: %@",daysArray);
        
        
        // Customize the text for each month
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            static NSDateFormatter *dateFormatter;
            
            if(!dateFormatter){
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
                
            }
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%ld %@", (long)comps.year, monthText];
            
        };
        
    }
    
    
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    self.calendar.calendarAppearance.isWeekMode = YES;
    [self.calendar reloadAppearance];
    [self.calendar reloadData];
    
}


#pragma mark - utilities

-(void)AddConstraintToRC

{
    
    // Width constraint, half of parent view width
    [self.dialView addConstraint:[NSLayoutConstraint constraintWithItem:rcView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:170]];
    
    
    
    // Height constraint, half of parent view height
    [self.dialView addConstraint:[NSLayoutConstraint constraintWithItem:rcView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:170]];
    
    
    
    // Center horizontally
    [self.dialView addConstraint:[NSLayoutConstraint constraintWithItem:rcView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.dialView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    // Center vertically
    [self.dialView addConstraint:[NSLayoutConstraint constraintWithItem:rcView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.dialView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:25]];
    
    NSLog(@"CONSTRAINT");
    
}

-(void)setData

{
    
    NSDictionary *jsonData = [self parseJsonWithName:@"Home"];
    
    for (NSDictionary *item in jsonData)
    {
        // Inner dial
        efficiency = [[[item objectForKey:@"innerDial"] objectForKey:@"percentage"] intValue];
        
        // Spending
        yourSpent = [[[item objectForKey:@"spending"] objectForKey:@"spent"] floatValue];
        smartSpending = [[[item objectForKey:@"spending"] objectForKey:@"smart"] floatValue];
        
        // Graph
        spentGraphData = [[NSMutableArray alloc]init];
        smartGraphData = [[NSMutableArray alloc]init];
        timeStampGraph = [[NSMutableArray alloc]init];
        
        NSArray *graphData = [item objectForKey:@"graphData"];
        
        for (int i = 0; i < [graphData count]; i++) {
            NSDictionary *data = (NSDictionary*) [graphData objectAtIndex:i];
            [spentGraphData addObject:[data objectForKey:@"spent"]];
            [smartGraphData addObject:[data objectForKey:@"smart"]];
            [timeStampGraph addObject:[self convertEpoch:[[data objectForKey:@"timestamp"]intValue] toHours:NO]];
            
        }
        
        // Leaves
        // Green
        greenLeafPosition = [[[[item objectForKey:@"outerDial"] objectForKey:@"greenLeaf"] objectForKey:@"position"] intValue];
    }
    
}


#pragma mark - Epoch

-(NSString *)convertEpoch:(NSInteger)seconds toHours:(BOOL)hour

{
    NSDate * date = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if(hour)
    {
        [dateFormatter setDateFormat:@"HH"];
    }
    else
    {
        [dateFormatter setDateFormat:@"dd"];
    }
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
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

#pragma mark - XYPieChart Data Source
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    NSLog(@"numberOfSlicesInPieChart");
    return self.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[self.slices objectAtIndex:index]floatValue];
}


- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}


#pragma mark - Radar data chart source
// get number of spokes in radar chart
- (NSInteger)numberOfSopkesInRadarChart:(RPRadarChart*)chart
{
    return [rcDataArray count];
}


// get number of datas
- (NSInteger)numberOfDatasInRadarChart:(RPRadarChart*)chart
{
    return 2;
}

// get max value for this radar chart
- (float)maximumValueInRadarChart:(RPRadarChart*)chart
{
    float maxValue = 0;
    for (int i = 0; i < [rcDataArray count]; i++)
    {
        if ([[rcDataArray objectAtIndex:i]floatValue] > maxValue)
        {
            maxValue = [[rcDataArray objectAtIndex:i]floatValue];
        }
    }
    
    return maxValue;
    
}



// get title for each spoke
- (NSString*)radarChart:(RPRadarChart*)chart titleForSpoke:(NSInteger)atIndex
{
    return @"";
}


// get data value for a specefic data item for a spoke
- (float)radarChart:(RPRadarChart*)chart valueForData:(NSInteger)dataIndex forSpoke:(NSInteger)spokeIndex
{
    if (dataIndex == 0) {
        //        NSLog(@"SpokeValue: %.2f",[[rcDataArray objectAtIndex:spokeIndex]floatValue]);
        return [[rcDataArray objectAtIndex:spokeIndex]floatValue];
    }
    else{
        return 0;
    }
}


// get color legend for a specefic data
- (UIColor*)radarChart:(RPRadarChart*)chart colorForData:(NSInteger)atIndex
{
    //    if ([[rcDataArray objectAtIndex:atIndex]floatValue] == 0) {
    //        return [UIColor whiteColor];
    //    }
    if (atIndex == 0) {
        NSLog(@"dataAtIndex: %li",(long)atIndex);
        return [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];//green
    }
    else
        return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];//white
}



#pragma mark - delegate for radar chart
- (void)radarChart:(RPRadarChart *)chart lineTouchedForData:(NSInteger)dataIndex atPosition:(CGPoint)point
{
    //    NSLog(@"Line %d touched at (%f,%f)", dataIndex, point.x, point.y);
    
}

#pragma mark - Calendar
- (void)viewDidLayoutSubviews
{
    [self.calendar repositionViews];
}

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
    NSLog(@"%@", [date dateByAddingTimeInterval:60*60*24]);
}

#pragma mark - line graph
- (void) startTimer
{
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                               target:self
                                             selector:@selector(timerFired:)
                                             userInfo:nil
                                              repeats:YES];
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                               target:self
                                             selector:@selector(updateMaxDemand:)
                                             userInfo:nil
                                              repeats:YES];
}

- (void) stopTimer
{
    [myTimer invalidate];
    myTimer=nil;
}



- (void) timerFired:(NSTimer*)theTimer
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss a"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    self.nowLabel.text = dateString;
}


#pragma mark - Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tmGreenLeafPressed:(id)sender {
    //Navigate to the Task manager View Controller
    UIViewController *tmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"tmViewController"];
    [self.navigationController pushViewController:tmVC animated:YES];
}
@end

