//
//  BillingPeriodViewController.m
//  emPower App
//
//  Created by Rawan on 5/18/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "BillingPeriodViewController.h"
#import "SWRevealViewController.h"
#import "NSDate+FSExtension.h"
#import "SSLunarDate.h"
#import "AppDelegate.h"

#define kPink [UIColor colorWithRed:198/255.0 green:51/255.0 blue:42/255.0 alpha:1.0]
#define kBlue [UIColor colorWithRed:31/255.0 green:119/255.0 blue:219/255.0 alpha:1.0]
#define kBlueText [UIColor colorWithRed:14/255.0 green:69/255.0 blue:221/255.0 alpha:1.0]


@interface BillingPeriodViewController ()
{
    NSString *currentMonth;
    int progressDialPercentage, dateIndex;
    float monthlySpent, monthlySaved;
    NSMutableArray *calendarDailyCost, *calendarDate;
    
    UITextField *budgetTextField;
    float budget;
    
    NSDate *now;
    NSDate *startOfThisMonth;
    NSDate *viewDate;

    NSCalendar *calendarObj;
    
}
@property (strong, nonatomic) NSCalendar *currentCalendar;
@property (strong, nonatomic) SSLunarDate *lunarDate;

@end

@implementation BillingPeriodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateIndex = 0;
    
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
        navTitleView.textColor = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];
        self.navigationItem.titleView = navTitleView;
    }
    navTitleView.text = @"Billing period";
    [navTitleView sizeToFit];
    
    // get page data
    [self callREST]; //REST API
    //    [self parseJSONData]; // Local data
    
    
    [self.yearlyCalendar setState:ABCalendarPickerStateMonths animated:NO];
    self.yearlyCalendar.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated
{
    // reload pie chart data
    [self.pieChart reloadData];
    
    // calendar data
    now = [NSDate date];
    NSDate *tempStartOfThisMonth = nil;
    calendarObj = [NSCalendar currentCalendar];
    [calendarObj rangeOfUnit:NSMonthCalendarUnit startDate:&tempStartOfThisMonth interval:NULL forDate:now];
    startOfThisMonth = tempStartOfThisMonth;
    viewDate=tempStartOfThisMonth;
    
    // update month label
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMMM YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    self.currentMonthLabel.text = dateString;
    
}

-(void)addTasksDial
{
    NSLog(@"addTaskDial: %f",[self.budgetButton.titleLabel.text floatValue]);
    // add dial
    [self.pieChart setDataSource:self];
    [self.pieChart setPieCenter:CGPointMake(80, 75)];
    [self.pieChart setStartPieAngle:M_PI_2];
    [self.pieChart setPieBackgroundColor:[UIColor clearColor]];
    [self.pieChart setAnimationSpeed:1.0];
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
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[NSDate date]];
    //NSUInteger numberOfDaysInMonth = rng.length;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd"];
    NSDate *date = [NSDate date];
    //int today = [[dateFormatter stringFromDate:date]intValue];
    
    NSNumber *value;
    NSNumber *rest;

    if(monthlySpent <= 0) {
        monthlySpent = 50;
    }
    
    
    NSString *spentStr = [NSString stringWithFormat:@"%i", (int) monthlySpent];
    NSString *budgetStr = [NSString stringWithFormat:@"%i", (int) budget];
    
    if (budget > 0) {
        value = [NSNumber numberWithInt:monthlySpent];
        rest = [NSNumber numberWithInt:budget];
    } else {
        value = [NSNumber numberWithInt: 50];
        rest = [NSNumber numberWithInt: 100];
    }
    
    NSLog(@"SpentValue: %@",value);
    NSLog(@"budgetRest: %@",rest);
    
    [self.slices addObject:value];
    [self.slices addObject:rest];
    
    // efficiency number label
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20 ,15, 120, 120)];
    centerLabel.backgroundColor = [UIColor whiteColor];
    centerLabel.clipsToBounds = YES;
    [centerLabel.layer setCornerRadius:60];
    [centerLabel setNumberOfLines:2];
    centerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];
    centerLabel.text = [NSString stringWithFormat:@"$%@%@$%@", spentStr, @"/", budgetStr];
    
    [self.pieChart addSubview:centerLabel];
    
    // % label
    UILabel *perLabel = [[UILabel alloc]initWithFrame:CGRectMake(30 ,80, 100, 30)];
    perLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    perLabel.textAlignment = NSTextAlignmentCenter;
    perLabel.textColor = [UIColor darkGrayColor];
    perLabel.text = [NSString stringWithFormat:@"budget"];
    
    [self.pieChart addSubview:perLabel];
    // text label
    /*UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(30 , 90, 100, 30)];
    textLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor darkGrayColor];
    textLabel.text = [NSString stringWithFormat:@"remaining"];
    
    [self.pieChart addSubview:textLabel];*/
    [self.pieChart reloadData];
}

#pragma mark - REST
-(void)callREST
{
    NSLog(@"REEESSSSTTT");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/billing/monthly"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
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
             NSLog(@"BillingcallResult: %@",jsonObjects);
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 
                 // Handle Error and return
                 return;
                 
             }
             
             // current month
             currentMonth = [[[jsonObjects objectForKey:@"overview"] objectForKey:@"currentMonth"] objectForKey:@"month"];
             
             // tasks dial
             progressDialPercentage = [[[[jsonObjects objectForKey:@"overview"] objectForKey:@"progressDial"] objectForKey:@"percentage"] intValue];
             // monthly data
             monthlySpent = [[[[[jsonObjects objectForKey:@"overview"] objectForKey:@"monthData"] objectForKey:@"spent"]stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
             monthlySaved = [[[[jsonObjects objectForKey:@"overview"] objectForKey:@"monthData"] objectForKey:@"saved"] floatValue];
             
             // calendar data
             calendarDailyCost = [[NSMutableArray alloc]init];
             calendarDate = [[NSMutableArray alloc]init];
             
             NSArray *calendarData = [jsonObjects objectForKey:@"monthCalendar"];
             for (int i = 0; i < [calendarData count]; i++) {
                 NSDictionary *data = (NSDictionary*) [calendarData objectAtIndex:i];
                 [calendarDailyCost addObject:[data objectForKey:@"cost"]];
                 
                 double milliSeconds = [[data objectForKey:@"date"]doubleValue];
                 [calendarDate addObject:[self convertEpoch:milliSeconds toHours:NO]];
             }
             NSLog(@"monthlySpent: %f",monthlySpent);
             self.monthlySpentLabel.text = [NSString stringWithFormat:@"$ %.2f",monthlySpent];
             self.monthlySavedLabel.text = [NSString stringWithFormat:@"$ %.2f",monthlySaved];
             
             // add tasks dial
             [self addTasksDial];
             NSLog(@"calendarDailyCost: %@",calendarDailyCost);
             
             // set calendar properties
             _currentCalendar = [NSCalendar currentCalendar];
             _flow = _calendar.flow;
             _firstWeekday = _calendar.firstWeekday;
             [self setLunar:YES];
             [self setTheme:1];
             [self setFlow:FSCalendarFlowVertical];
             
             // reload pie chart data
             [self.pieChart reloadData];
             
             // update month label
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
             [dateFormatter setDateFormat:@"MMMM yyyy"];
             self.currentMonthLabel.text = [dateFormatter stringFromDate:[NSDate date]];
         }
     }];
}
#pragma mark - Epoch
-(NSString *)convertEpoch:(double)seconds toHours:(BOOL)hour
{
    NSLog(@"convertEpoch");
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:seconds/1000];
    NSLog(@"Seconds: %f, dateEpoch: %@",seconds, date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    if(hour)
    {
        [dateFormatter setDateFormat:@"hh"];
    }
    else
    {
        [dateFormatter setDateFormat:@"EEE, dd MMM YYYY HH:mm:ss "];
    }
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSLog(@"dateString: %@", dateString);
    return dateString;
}
#pragma mark - JSON parsing

-(NSDictionary*)parseJsonWithName:(NSString*)fileName
{
    NSLog(@"parseJsonWithName");

    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSString *jsonFile = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if (!jsonFile) {
        NSLog(@"File couldn't be read!");
        return NULL;
    }
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[jsonFile dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSLog(@"JSON: %@", jsonDictionary);
    return jsonDictionary;
    
}

-(void)parseJSONData
{
    NSLog(@"parseJsondata");

    NSDictionary *jsonData = [self parseJsonWithName:@"billingPeriod"];
    for (NSDictionary *item in jsonData)
    {
        NSLog(@"callResult: %@",item);
        // current month
        currentMonth = [[[item objectForKey:@"overview"] objectForKey:@"currentMonth"] objectForKey:@"month"];
        NSLog(@"currentMonth: %@",currentMonth);
        // tasks dial
        progressDialPercentage = [[[[item objectForKey:@"overview"] objectForKey:@"progressDial"] objectForKey:@"percentage"] intValue];
        // monthly data
        monthlySpent = [[[[item objectForKey:@"overview"] objectForKey:@"monthData"] objectForKey:@"spent"] floatValue];
        monthlySaved = [[[[item objectForKey:@"overview"] objectForKey:@"monthData"] objectForKey:@"saved"] floatValue];
        
        // calendar data
        calendarDailyCost = [[NSMutableArray alloc]init];
        calendarDate = [[NSMutableArray alloc]init];
        
        NSArray *calendarData = [item objectForKey:@"monthCalendar"];
        for (int i = 0; i < [calendarData count]; i++) {
            NSDictionary *data = (NSDictionary*) [calendarData objectAtIndex:i];
            [calendarDailyCost addObject:[data objectForKey:@"cost"]];
            
            double milliSeconds = [[data objectForKey:@"date"]doubleValue];
            [calendarDate addObject:[self convertEpoch:milliSeconds toHours:NO]];
        }
        
    }
    
    self.currentMonthLabel.text = currentMonth;
    self.monthlySpentLabel.text = [NSString stringWithFormat:@"$ %.2f",monthlySpent];
    self.monthlySavedLabel.text = [NSString stringWithFormat:@"$ %.2f",monthlySaved];
    
    // add tasks dial
    [self addTasksDial];
    
    // set calendar properties
    _currentCalendar = [NSCalendar currentCalendar];
    _flow = _calendar.flow;
    _firstWeekday = _calendar.firstWeekday;
    [self setLunar:YES];
    [self setTheme:1];
    [self setFlow:FSCalendarFlowVertical];
    // reload pie chart data
    [self.pieChart reloadData];
    
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

#pragma mark - FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendarView subtitleForDate:(NSDate *)date
{
    NSString *subTitle = @"";
    
    if (!_lunar) {
        return nil;
        
    }

    ///////////////////////////////
    now = [NSDate date];
  
    
    
    NSInteger comps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    
    NSDateComponents *date1Components = [calendarObj components:comps
                                                       fromDate: date];
    NSDateComponents *date2Components = [calendarObj components:comps
                                                       fromDate: now];
    
    date = [calendarObj dateFromComponents:date1Components];
    now = [calendarObj dateFromComponents:date2Components];
    count++;
    NSLog(@" startOfThisMonth: %@ ",startOfThisMonth);
    NSComparisonResult result = [date compare:startOfThisMonth];
    if (result == NSOrderedAscending)
    {
       
    }
    else if (result == NSOrderedDescending)
    {
    }
    else if(result==0) {
          
        //the same
        NSLog(@"same");
        NSLog(@"Now: %@, Date: %@",now,date);
        if (dateIndex < calendarDailyCost.count) {
            subTitle = [calendarDailyCost objectAtIndex:dateIndex];
            dateIndex++;
            startOfThisMonth = [startOfThisMonth dateByAddingTimeInterval:60*60*24*1];
            viewDate = [startOfThisMonth dateByAddingTimeInterval:60*60*48*1];

        }
 
        
    }
    
    /*
     //////////////////////////////
     //    NSDate * now = [NSDate date];
     //    NSComparisonResult result = [now compare:date];
     
     NSLog(@"Now: %@", now);
     NSLog(@"date: %@", date);
     
     switch (result)
     {
     case NSOrderedAscending:
     {
     NSLog(@"%@ is in future from %@", date, now);
     }
     break;
     case NSOrderedDescending:
     {
     NSLog(@"%@ is in past from %@", date, now);
     subTitle = [calendarDailyCost objectAtIndex:dateIndex];
     
     }
     break;
     case NSOrderedSame:
     {
     NSLog(@"%@ is the same as %@", date, now);
     subTitle = [calendarDailyCost objectAtIndex:dateIndex];
     }
     break;
     default:
     NSLog(@"erorr dates %@, %@", date, now); break;
     }
     
     */
    return subTitle;
}

- (BOOL)calendar:(FSCalendar *)calendarView hasEventForDate:(NSDate *)date
{
    return date.fs_day == 3;
}
#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date
{
    BOOL shouldSelect = date.fs_day != 32;
    if (!shouldSelect) {
        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
                                    message:[NSString stringWithFormat:@"FSCalendar delegate forbid %@  to be selected",[date fs_stringWithFormat:@"yyyy/MM/dd"]]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil] show];
    }
    return shouldSelect;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"did select date %@",[date fs_stringWithFormat:@"yyyy/MM/dd"]);
}

- (void)calendarCurrentMonthDidChange:(FSCalendar *)cal
{
    NSLog(@"did change to month %@",[cal.currentMonth fs_stringWithFormat:@"MMMM yyyy"]);
    NSLog(@"newDate: %@",cal.currentMonth);
    NSDate *tempStartOfThisMonth = nil;
    calendarObj = [NSCalendar currentCalendar];
    [calendarObj rangeOfUnit:NSMonthCalendarUnit startDate:&tempStartOfThisMonth interval:NULL forDate:cal.currentMonth];
    viewDate = tempStartOfThisMonth;
    // set calendar properties
    dateIndex = 0;
    // calendar data
    now = [NSDate date];
    calendarObj = [NSCalendar currentCalendar];
    [calendarObj rangeOfUnit:NSMonthCalendarUnit startDate:&tempStartOfThisMonth interval:NULL forDate:now];
    startOfThisMonth = tempStartOfThisMonth;
    
    NSLog(@"start: %@",startOfThisMonth);
    [_calendar reloadData];
    
    // update month label
    NSString *dateString = [cal.currentMonth fs_stringWithFormat:@"MMMM yyyy"];
    self.currentMonthLabel.text = dateString;
    
    //
    NSLog(@"currently month is%@+%@",startOfThisMonth,viewDate);
    NSComparisonResult result = [startOfThisMonth compare:viewDate];

    if (result==0) {
        NSLog(@"heresiequal");
        [_calendar layoutSubviews];
      
    }

}

#pragma mark - Setter
- (void)setTheme:(NSInteger)theme
{
    theme = 2;
    if (_theme != theme) {
        _theme = theme;
        switch (theme) {
            case 0:
            {
                [_calendar setWeekdayTextColor:kBlueText];
                [_calendar setHeaderTitleColor:kBlueText];
                [_calendar setEventColor:[kBlueText colorWithAlphaComponent:0.75]];
                [_calendar setSelectionColor:kBlue];
                [_calendar setHeaderDateFormat:@"MMMM yyyy"];
                [_calendar setMinDissolvedAlpha:0.2];
                [_calendar setTodayColor:kPink];
                [_calendar setCellStyle:FSCalendarCellStyleCircle];
                break;
            }
            case 1:
            {
                [_calendar setWeekdayTextColor:[UIColor redColor]];
                [_calendar setHeaderTitleColor:[UIColor darkGrayColor]];
                [_calendar setEventColor:[UIColor greenColor]];
                [_calendar setSelectionColor:[UIColor blueColor]];
                [_calendar setHeaderDateFormat:@"yyyy-MM"];
                [_calendar setMinDissolvedAlpha:1.0];
                [_calendar setTodayColor:[UIColor redColor]];
                [_calendar setCellStyle:FSCalendarCellStyleCircle];
                break;
            }
            case 2:
            {
                [_calendar setWeekdayTextColor:[UIColor darkGrayColor]];
                [_calendar setHeaderTitleColor:[UIColor redColor]];
                [_calendar setEventColor:[UIColor clearColor]];
                [_calendar setSelectionColor:[UIColor lightGrayColor]];
                [_calendar setHeaderDateFormat:@"yyyy/MM"];
                [_calendar setMinDissolvedAlpha:1.0];
                [_calendar setCellStyle:FSCalendarCellStyleRectangle];
                [_calendar setTodayColor:[UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0]];
                break;
            }
            default:
                break;
        }
        
    }
}

- (void)setLunar:(BOOL)lunar
{
    lunar = YES;
    if (_lunar != lunar) {
        _lunar = lunar;
        [_calendar reloadData];
    }

}

- (void)setFlow:(FSCalendarFlow)flow
{
   
    if (_flow != flow) {
        _flow = flow;
        _calendar.flow = flow;
        //        [[[UIAlertView alloc] initWithTitle:@"FSCalendar"
        //                                    message:[NSString stringWithFormat:@"Now swipe %@",@[@"Vertically", @"Horizontally"][_calendar.flow]]
        //                                   delegate:nil
        //                          cancelButtonTitle:@"OK"
        //                          otherButtonTitles:nil, nil] show];
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _calendar.selectedDate = selectedDate;
}

- (void)setFirstWeekday:(NSUInteger)firstWeekday
{
    if (_firstWeekday != firstWeekday) {
        _firstWeekday = firstWeekday;
        _calendar.firstWeekday = firstWeekday;
    }
}

#pragma mark - buttons
- (IBAction)setBudget:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Budget"
                                                    message:@"please set your budget"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) // Done Pressed
    {
        NSLog(@"%@", [alertView textFieldAtIndex:0].text);
        [self.budgetButton setTitle:[NSString stringWithFormat:@"%@%@",@"$",[alertView textFieldAtIndex:0].text] forState:UIControlStateNormal];
        
        self.budgetButton.tag = [[alertView textFieldAtIndex:0].text floatValue];
        budget =  [[alertView textFieldAtIndex:0].text intValue];
        
    }
    // reload pie chart da2ta
    [self performSelector:@selector(addTasksDial) withObject:nil afterDelay:0.2];
    
}
- (IBAction)calButtonPressed:(id)sender
{
    self.yearlyCalendar.hidden = NO;
}

#pragma mark - yearly calnedar
-(void)calendarPicker:(ABCalendarPicker *)calendarPicker dateSelected:(NSDate *)date withState:(ABCalendarPickerState)state
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSLog(@"SELECTED: %@",date);
    
    // update month label
    [dateFormatter setDateFormat:@"MMMM YYYY"];
    dateString = [dateFormatter stringFromDate:date];
    self.currentMonthLabel.text = dateString;
    
    
    // update monthly calendar
    dateIndex = 0;
    // calendar data
    now = [NSDate date];
    NSDate *tempStartOfThisMonth = nil;
    calendarObj = [NSCalendar currentCalendar];
    [calendarObj rangeOfUnit:NSMonthCalendarUnit startDate:&tempStartOfThisMonth interval:NULL forDate:now];
    startOfThisMonth = tempStartOfThisMonth;
    
    // update monthly calendar
    [self.calendar setSelectedDate:date];
    
    [_calendar reloadData];
    
    
    self.yearlyCalendar.hidden = YES;
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
