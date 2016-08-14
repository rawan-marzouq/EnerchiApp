//
//  FamilyInfoViewController.m
//  emPower App
//
//  Created by Rawan Marzouq on 7/28/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "FamilyInfoViewController.h"
#import "YStepperView.h"
#import "PAStepper.h"

@interface FamilyInfoViewController ()
{
    NSMutableArray      *detailsArray;
    NSMutableArray  *infoArray;
    // family info
    NSMutableArray  *familyInfoArray;
    NSString        *numAdults;
    NSString        *numAdultsAway;
    NSString        *numChildren;
    NSString        *numChildrenAway;
    
    // appliances
    NSMutableArray  *appliancesArray;
    NSString        *numAc;
    NSString        *numFridge;
    NSString        *numWaterHeater;
    NSString        *numWasher;
    NSString        *numDryer;
    NSString        *numDishwasher;
    NSString        *numStove;
    NSString        *numOven;
    NSString        *numPoolPump;
}
@end

@implementation FamilyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set header title
    UILabel *navTitleView = (UILabel *)self.navigationItem.titleView;
    if (!navTitleView) {
        
        navTitleView = [[UILabel alloc] initWithFrame:CGRectZero];
        navTitleView.backgroundColor = [UIColor clearColor];
        navTitleView.font = [UIFont boldSystemFontOfSize:22.0];
        navTitleView.textColor = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];
        self.navigationItem.titleView = navTitleView;
    }
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"category"] isEqualToString:@"familyInfo"]) {
        
        navTitleView.text = @"Family Info";
        [navTitleView sizeToFit];
        detailsArray = [[NSMutableArray alloc] initWithObjects:@"Number of Adults",@"How many work away from home",@"Number of children",@"How many attend school", nil];
    }
    else{
        
        navTitleView.text = @"Appliances";
        [navTitleView sizeToFit];
        detailsArray = [[NSMutableArray alloc] initWithObjects:@"Air Conditioner",@"Refrigerator",@"Water Heater",@"Washing Machine",@"Dryer",@"Dishwasher",@"Stove",@"Oven",@"Pool Pump", nil];
    }
    
    [self getUserInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [detailsArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    
    // custom cell textLabel
    UILabel *cellTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [cellTextLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [cellTextLabel setNumberOfLines:0];
    [cellTextLabel setFont:[UIFont systemFontOfSize:15]];
    CGSize constraint = CGSizeMake(tableView.frame.size.width - 150, 20000.0f);
    cellTextLabel.text = [detailsArray objectAtIndex:indexPath.row];
    CGSize size = [cellTextLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    [cellTextLabel setFrame:CGRectMake(20,7,size.width,size.height)];
    [cell addSubview:cellTextLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // stepper
//    YStepperView *yStepper = [[YStepperView alloc] initWithFrame:CGRectMake(cell.frame.size.width - 110, 25, 100.0, 25.0)];
//    [yStepper setStepperColor:[UIColor darkGrayColor] withDisableColor:nil];
//    [yStepper setTextColor:[UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0]];
//    [yStepper setStepperRange:0 andMaxValue:10];
//    if (infoArray.count > 0) {
//        [yStepper setValue:[[infoArray objectAtIndex:indexPath.row]intValue]];
//    }
//    [yStepper setTextLabelFont:[UIFont systemFontOfSize:15.0f]];
//    UITapGestureRecognizer *singleFingerTap =
//    [[UITapGestureRecognizer alloc] initWithTarget:self
//                                            action:@selector(handleSingleTap:)];
//    [self.view addGestureRecognizer:singleFingerTap];
//    [cell addSubview:yStepper];
//
    
    PAStepper *step = [[PAStepper alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 130, 10, 90.0, 25.0)];
    [step setBackgroundColor:[UIColor lightGrayColor]];
    [step addTarget:self action:@selector(stepperValueDidChanged:) forControlEvents:UIControlEventValueChanged];
    [step setStepValue:1.0];
    [step setMaximumValue:10.0];
    [step setMinimumValue:0.0];
    step.tag = indexPath.row;
    if (infoArray.count > 0) {
        [step setValue:[[infoArray objectAtIndex:indexPath.row]floatValue]];
    }
    [cell.contentView addSubview:step];
    
    return cell;
}

- (void)stepperValueDidChanged:(id)sender
{
    UIStepper *tempStep = (UIStepper*)sender;
    if (infoArray.count > 0) {
        [infoArray removeObjectAtIndex:tempStep.tag];
    }
    [infoArray insertObject:[NSString stringWithFormat:@"%f",tempStep.value] atIndex:tempStep.tag];
    NSLog(@"STEPPER: %f",tempStep.value);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - REST
-(void)getUserInfo
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/settings/general"]];
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
             NSLog(@"Settings callResult: %@",jsonObjects);
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 
                 // Handle Error and return
                 return;
                 
             }
             NSDictionary *userData = [jsonObjects objectForKey:@"data"];
             
             // family data
             numAdults = [userData objectForKey:@"numAdults"];
             numAdultsAway = [userData objectForKey:@"numAdultsAway"];
             numChildren = [userData objectForKey:@"numChildren"];
             numChildrenAway = [userData objectForKey:@"numChildrenAway"];
             
             // appliances
             numAc = [userData objectForKey:@"numAc"];
             numFridge = [userData objectForKey:@"numFridge"];
             numWaterHeater = [userData objectForKey:@"numWaterHeater"];
             numWasher = [userData objectForKey:@"numWasher"];
             numDryer = [userData objectForKey:@"numDryer"];
             numDishwasher = [userData objectForKey:@"numDishwasher"];
             numStove = [userData objectForKey:@"numStove"];
             numOven = [userData objectForKey:@"numOven"];
             numPoolPump = [userData objectForKey:@"numPoolPump"];
         }
         if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"category"] isEqualToString:@"familyInfo"])
         {
             // family data
             infoArray = [[NSMutableArray alloc]initWithObjects:numAdults,numAdultsAway,numChildren,numChildrenAway, nil];
         }
         else{
             // appliances data
             infoArray = [[NSMutableArray alloc]initWithObjects:numAc,numFridge,numWaterHeater,numWasher,numDryer,numDishwasher,numStove,numOven,numPoolPump, nil];
         }
         NSLog(@"BinfoArray: %@",infoArray);
         if (infoArray.count < 1)
         {
             NSLog(@"less than");
             infoArray = [[NSMutableArray alloc]initWithObjects:@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1", nil];
         }
         [self.tableView reloadData];
         NSLog(@"HinfoArray: %@",infoArray);
     }];
}

-(void)updateUserInfo:(NSMutableArray*)newInfo
{
    if (newInfo.count < 1) {
        return;
    }
    NSLog(@"newInfo: %@",newInfo);
    // Convert jSON string to data
    NSString *jSONString ;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"category"] isEqualToString:@"familyInfo"])
    {
        // family data
        jSONString = [NSString stringWithFormat:@"{\"numAdults\": \"%@\", \"numAdultsAway\": \"%@\", \"numChildren\": \"%@\", \"numChildrenAway\": \"%@\"}",newInfo[0], newInfo[1], newInfo[2], newInfo[3]];
    }
    else{
        // appliances data
        jSONString = [NSString stringWithFormat:@"{\"numAc\": \"%@\", \"numFridge\": \"%@\",\"numWaterHeater\": \"%@\",\"numWasher\": \"%@\",\"numDryer\": \"%@\",\"numDishwasher\": \"%@\",\"numStove\": \"%@\",\"numOven\": \"%@\",\"numPoolPump\":\"%@\"}",newInfo[0], newInfo[1], newInfo[2], newInfo[3],newInfo[4], newInfo[5], newInfo[6], newInfo[7], newInfo[8]];
    }
    
    NSData *putData = [jSONString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Instantiate a url request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/settings/general"]];
    // Set the request url format
    [request setURL:url];
    
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:putData];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request addValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    [request setValue:token forHTTPHeaderField:@"X-Access-Token"];
    
    // Send data to the webservice
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

#pragma mark - Back navigation
- (void)didMoveToParentViewController:(UIViewController *)parent{
    if (parent == NULL) {
        NSLog(@"Back Pressed");
        [self updateUserInfo:infoArray];
    }
}

@end
