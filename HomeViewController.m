//
//  HomeViewController.m
//  emPower App
//
//  Created by Rawan on 3/13/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "Appliance.h"
#import "ApplianceTableViewCell.h"
#import "CCSPieChart.h"
#import "CCSTitleValueColor.h"
#import "ApplianceDetailsViewController.h"

@interface HomeViewController ()
{
    int efficiency;
    float yourSpent, smartSpending;
    NSMutableArray *spentGraphData;
    NSMutableArray *smartGraphData;
    NSMutableArray *timeStampGraph;
    NSMutableArray *appliances;
    NSMutableArray *sortedAppliances;
    NSMutableArray *grayLeavesPositionsArray;
    int greenLeafPosition;
    NSMutableArray *xArray;
    NSMutableArray *yArray;
}

@end

@implementation HomeViewController

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
    
    // set leaves positions arrays
    xArray = [[NSMutableArray alloc]initWithObjects:
                                                    @"200", @"176", @"193", @"215", @"230", @"236", @"242", @"236", @"230", @"215", @"193", @"176",
                                                    @"150", @"120", @"105", @"85", @"65", @"60", @"55", @"60", @"65", @"85", @"105", @"120", nil];
    yArray = [[NSMutableArray alloc]initWithObjects:
                                                    @"10", @"13", @"22", @"38", @"58", @"75", @"101", @"125", @"145", @"170", @"180", @"190", @"193", @"190",
                                                    @"180", @"170", @"145", @"125", @"101", @"75", @"58", @"38", @"22", @"13", nil];
    grayLeavesPositionsArray = [[NSMutableArray alloc]init];
    
    // reading JSON file
    [self setData];
    
    // arrange table data depending on: total time
    [self arrangeAppliances];
    
     // add Radar chart
     rc = [[RPRadarChart alloc] initWithFrame:CGRectMake(75, 89, 170, 170)];
     rc.backgroundColor = [UIColor clearColor];
     rc.drawGuideLines = NO;
     rc.showGuideNumbers = NO;
     rc.fillArea = NO;
     rc.showValues = NO;
     rc.dataSource = self;
     rc.delegate = self;
    
     [self.view addSubview:rc];
    
    // add efficience dial
    [self addEfficiencyDial];
    
    // set labels values
    self.youSpentLabel.text = [NSString stringWithFormat:@"$%.2f",yourSpent];
    self.smartSpendingLabel.text = [NSString stringWithFormat:@"$%.2f", smartSpending];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH"];
    NSString *nowString = [outputFormatter stringFromDate:now];
    // reload pie chart data
    [self.pieChart reloadData];
    // leaves
    self.greenLeaf.frame = CGRectMake([[xArray objectAtIndex:[nowString intValue]]floatValue], [[yArray objectAtIndex:[nowString intValue]]floatValue], self.greenLeaf.frame.size.width, self.greenLeaf.frame.size.height);
    int noNotificationFlag = 0;
    for(int i = 0; i<[grayLeavesPositionsArray count]; i++)
    {
        if ([nowString intValue] == [[grayLeavesPositionsArray objectAtIndex:i]intValue])
        {
            self.notificationLeaf.image = [UIImage imageNamed:@"green_leaf"];
            noNotificationFlag++;
        }
    }
    if(noNotificationFlag == 0)
    {
        self.notificationLeaf.image = [UIImage imageNamed:@"grey_leaf"];
    }
    int indexLeaf = [[grayLeavesPositionsArray objectAtIndex:0] intValue];
    self.grayLeaf1.frame = CGRectMake([[xArray objectAtIndex:indexLeaf]floatValue], [[yArray objectAtIndex:indexLeaf]floatValue], self.grayLeaf1.frame.size.width, self.grayLeaf1.frame.size.height);
    
    indexLeaf = [[grayLeavesPositionsArray objectAtIndex:1] intValue];;
    self.grayLeaf2.frame = CGRectMake([[xArray objectAtIndex:indexLeaf]floatValue], [[yArray objectAtIndex:indexLeaf]floatValue], self.grayLeaf2.frame.size.width, self.grayLeaf2.frame.size.height);
    indexLeaf = [[grayLeavesPositionsArray objectAtIndex:2] intValue];;
    self.grayLeaf3.frame = CGRectMake([[xArray objectAtIndex:indexLeaf]floatValue], [[yArray objectAtIndex:indexLeaf]floatValue], self.grayLeaf3.frame.size.width, self.grayLeaf3.frame.size.height);
}
-(void)addEfficiencyDial
{
    // add dial
    [self.pieChart setDataSource:self];
    [self.pieChart setPieCenter:CGPointMake(70, 70)];
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
    
    // set dial value data
    NSNumber *value = [NSNumber numberWithInt:efficiency];
    NSNumber *rest = [NSNumber numberWithFloat:100 - efficiency];
    [self.slices addObject:value];
    [self.slices addObject:rest];

    // efficiency number label
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20 ,20, 100, 100)];
    centerLabel.backgroundColor = [UIColor whiteColor];
    centerLabel.clipsToBounds = YES;
    [centerLabel.layer setCornerRadius:50];
    [centerLabel setNumberOfLines:2];
    centerLabel.font = [UIFont fontWithName:@"Helvetica" size:46];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor darkGrayColor];
    centerLabel.text = [NSString stringWithFormat:@"%i",efficiency];
    
    [self.pieChart addSubview:centerLabel];
    
    // % label
    UILabel *perLabel = [[UILabel alloc]initWithFrame:CGRectMake(95 ,20, 20, 100)];
    perLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    perLabel.textAlignment = NSTextAlignmentCenter;
    perLabel.textColor = [UIColor darkGrayColor];
    perLabel.text = [NSString stringWithFormat:@"%%"];
    
    [self.pieChart addSubview:perLabel];
    // efficiency text label
    UILabel *efficientLabel = [[UILabel alloc]initWithFrame:CGRectMake(45 ,70, 50, 50)];
    efficientLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    efficientLabel.textAlignment = NSTextAlignmentCenter;
    efficientLabel.textColor = [UIColor darkGrayColor];
    efficientLabel.text = [NSString stringWithFormat:@"Efficiet"];
    
    [self.pieChart addSubview:efficientLabel];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - utilities
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
        // Appliances
        NSArray *appliancesArray = [item objectForKey:@"appliances"];
        appliances = [[NSMutableArray alloc]init];
        for (int i = 0; i < [appliancesArray count]; i++) {
            NSDictionary *data = (NSDictionary*) [appliancesArray objectAtIndex:i];
            Appliance *appTempObject = [[Appliance alloc]init];
            appTempObject.name = [data objectForKey:@"name"];
            appTempObject.status = [data objectForKey:@"status"];
            appTempObject.spent = [data objectForKey:@"spent"];
            appTempObject.totalTime = [[data objectForKey:@"totalTime"]intValue];
            appTempObject.timePeriods = [data objectForKey:@"timePeriods"];
            [appliances addObject:appTempObject];
        }
        // Leaves
        // Gray
        NSArray *grayLeavesArray = [[item objectForKey:@"outerDial"] objectForKey:@"greyleaves"];
        for (int i = 0; i < [grayLeavesArray count]; i++) {
            NSDictionary *data = (NSDictionary*) [grayLeavesArray objectAtIndex:i];
            [grayLeavesPositionsArray addObject:[data objectForKey:@"position"]];
        }
        // Green
        greenLeafPosition = [[[[item objectForKey:@"outerDial"] objectForKey:@"greenLeaf"] objectForKey:@"position"] intValue];
    }
}

-(void)arrangeAppliances
{
    // arrabge on appliances
    NSMutableArray *onAppliances = [[NSMutableArray alloc]init];
    for (int i = 0; i < [appliances count]; i++) {
        Appliance *applianceObj = (Appliance*)[appliances objectAtIndex:i];
        if ([applianceObj.status isEqualToString:@"on"]) {
            [onAppliances addObject:applianceObj];
        }
    }
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalTime"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedOnArray;
    sortedOnArray = [onAppliances sortedArrayUsingDescriptors:sortDescriptors];
    
    //arrange off appliances
    NSMutableArray *offAppliances = [[NSMutableArray alloc]init];
    for (int i = 0; i < [appliances count]; i++) {
        Appliance *applianceObj = (Appliance*)[appliances objectAtIndex:i];
        if ([applianceObj.status isEqualToString:@"off"]) {
            [offAppliances addObject:applianceObj];
        }
    }
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"totalTime"
                                                 ascending:NO];
    sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedOffArray;
    sortedOffArray = [offAppliances sortedArrayUsingDescriptors:sortDescriptors];
    
    // fill sorted appliances array
    // fill on appliances
    sortedAppliances = [[NSMutableArray alloc]init];
    for (int i = 0; i < [sortedOnArray count]; i++) {
        Appliance *applianceOnObj = (Appliance*)[sortedOnArray objectAtIndex:i];
        [sortedAppliances addObject:applianceOnObj];
    }
    // fill off appliances
    for (int i = 0; i < [sortedOffArray count]; i++) {
        Appliance *applianceOnObj = (Appliance*)[sortedOffArray objectAtIndex:i];
        [sortedAppliances addObject:applianceOnObj];
    }
}
-(UIView*)drawTableWatchForAppliance:(Appliance*)appliance{
    Appliance *tempObj = appliance;
    NSDictionary *dic = [tempObj.timePeriods objectAtIndex:0];
    int starting = [[self convertEpoch:[[dic objectForKey:@"on"]intValue] toHours:YES]intValue];
    int ending = starting + tempObj.totalTime;
    CCSPieChart *piechart = [[CCSPieChart alloc] initWithFrame:CGRectMake(10, 5, 90, 90)];
    
    piechart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    NSMutableArray *piedata = [[NSMutableArray alloc] init];
    for (int i = 1 ; i <= 24; i++) {
        if (i == starting && i != ending) {
            [piedata addObject:[[CCSTitleValueColor alloc] initWithTitle:[NSString stringWithFormat:@"h%i",i] value:100/24 color:[UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0]]];
            starting++;
            continue;
        }
        [piedata addObject:[[CCSTitleValueColor alloc] initWithTitle:[NSString stringWithFormat:@"h%i",i] value:100/24 color:[UIColor lightGrayColor]]];
    }
    UILabel *centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 70, 70)];
    centerLabel.backgroundColor = [UIColor whiteColor];
    centerLabel.clipsToBounds = YES;
    [centerLabel.layer setCornerRadius:35];
    centerLabel.font = [UIFont fontWithName:@"Helvetica Neue-Bold" size:12];
    centerLabel.textAlignment = NSTextAlignmentCenter;
    centerLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];
    centerLabel.text = [NSString stringWithFormat:@"%ih",tempObj.totalTime];
    
    [piechart addSubview:centerLabel];
    
    piechart.data = piedata;
    piechart.displayValueTitle = NO;
    piechart.backgroundColor = [UIColor clearColor];
    
    
    //    [self.view addSubview:piechart];
    return piechart;
}

#pragma mark - Epoch
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


#pragma mark - Radar data chart source
// get number of spokes in radar chart
- (NSInteger)numberOfSopkesInRadarChart:(RPRadarChart*)chart
{
    return 24;
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
    for (int i = 0; i < [spentGraphData count]; i++)
    {
        if ([[spentGraphData objectAtIndex:i]floatValue] > maxValue)
        {
            maxValue = [[spentGraphData objectAtIndex:i]floatValue];
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
    switch (dataIndex) {
        case 0:
            return [[spentGraphData objectAtIndex:spokeIndex]floatValue];
            break;
        case 1:
            return [[smartGraphData objectAtIndex:spokeIndex]floatValue];
            break;
    }
    
    return 0;
}

// get color legend for a specefic data
- (UIColor*)radarChart:(RPRadarChart*)chart colorForData:(NSInteger)atIndex
{
    switch (atIndex) {
        case 0:
            return [UIColor orangeColor];
        case 1:
            return [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];
    }
    return [UIColor yellowColor];
}

#pragma mark - delegate for radar chart

- (void)radarChart:(RPRadarChart *)chart lineTouchedForData:(NSInteger)dataIndex atPosition:(CGPoint)point
{
    //    NSLog(@"Line %d touched at (%f,%f)", dataIndex, point.x, point.y);
}

#pragma mark - table view methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    Appliance *tempObj = (Appliance*)[sortedAppliances objectAtIndex:0];
    //    [self DrawWatch:tempObj.timePeriods];
    return [appliances count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    ApplianceTableViewCell *cell = (ApplianceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ApplianceCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Configure the cell appereance...
    Appliance *tempObj = (Appliance*)[sortedAppliances objectAtIndex:indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"$ %@",tempObj.spent];
    cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",tempObj.name]];
    if ([tempObj.status isEqualToString:@"off"])
    {
        cell.onOff.image = [UIImage imageNamed:@"red_small_circle"];
        cell.subTitleLabel.text = [NSString stringWithFormat:@"%@ is off", tempObj.name];
    }
    else
    {
        cell.onOff.image = [UIImage imageNamed:@"green_small_circle"];
        cell.subTitleLabel.text = [NSString stringWithFormat:@"%@ is on", tempObj.name];
    }
    UIView *watch = [self drawTableWatchForAppliance:tempObj];
    [cell.watch addSubview:watch];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 101;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Navigate to the Utilization View
    Appliance *tempObj = (Appliance*)[sortedAppliances objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setValue:tempObj.name forKey:@"applianceName"];
    UIViewController *detailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"applainceDetails"];
    [self.navigationController pushViewController:detailsVC animated:YES];
    //    [self presentViewController:utilVC animated:YES completion:nil];
}



@end
