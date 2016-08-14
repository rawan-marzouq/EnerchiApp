//
//  HomeDetailsSettingsViewController.m
//  emPower App
//
//  Created by Rawan Marzouq on 8/4/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "HomeDetailsSettingsViewController.h"
#import "PAStepper.h"


@interface HomeDetailsSettingsViewController ()
{
    NSMutableArray      *detailsArray;
    NSMutableArray      *years;
    UIPickerView        *pickerFiliter;
    UIAlertController   *alertController;
    
    // home info
    NSString        *homeType;
    NSString        *homeSqFt;
    int             numBedRooms;
    int             numBathRooms;
    NSString        *homeYrBuilt;
}

@end

@implementation HomeDetailsSettingsViewController

-(void)initValues
{
    // home data
    homeType = @"Single Family";
    homeSqFt = @"500";
    numBedRooms = 2;
    numBathRooms = 1;
    
}

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
    navTitleView.text = @"Home Details";
    [navTitleView sizeToFit];
    
    // titles array
    detailsArray = [[NSMutableArray alloc]initWithObjects:@"Type of Home",@"Number of Bedrooms",@"Number of Bathrooms",@"Year Built",@"Square Footage", nil];
    
    // years since 1900
    //Get Current Year into i2
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int i2  = [[formatter stringFromDate:[NSDate date]] intValue];
    
    //Create Years Array from 1900 to This year
    years = [[NSMutableArray alloc] init];
    for (int i=1900; i<=i2; i++) {
        [years addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    // get user's home info
    [self getUserInfo];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
             
             // home data
             homeType = [userData objectForKey:@"homeType"];
             homeSqFt = [userData objectForKey:@"homeSqFt"];
             numBedRooms = [[userData objectForKey:@"numBedRooms"] intValue];
             numBathRooms = [[userData objectForKey:@"numBathRooms"]intValue];
             homeYrBuilt = [userData objectForKey:@"homeYrBuilt"];
             
             
         }
         NSLog(@"homeType: %@,homeSqFt: %@, numBedRooms: %d, numBathRooms: %d, homeYrBuilt: %@,",homeType,homeSqFt,numBedRooms,numBathRooms,homeYrBuilt);
         [self.tableView reloadData];
     }];
}
-(void)updateUserInfo
{
    // Convert jSON string to data
    NSString *jSONString = [NSString stringWithFormat:@"{\"homeType\": \"%@\", \"homeSqFt\": \"%@\", \"numBedRooms\": \"%i\", \"numBathRooms\": \"%i\", \"homeYrBuilt\": \"%@\"}",homeType, homeSqFt, numBedRooms, numBathRooms, homeYrBuilt];
    
    
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

#pragma mark - UITableView Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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
    

    if (indexPath.row == 1 || indexPath.row == 2)
    {
        PAStepper *step = [[PAStepper alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 130, 10, 90.0, 25.0)];
        [step setBackgroundColor:[UIColor lightGrayColor]];
        step.tag = indexPath.row;
        
        if (indexPath.row == 2)
        {
            [step setValue:numBathRooms];
        }
        else
        {
            [step setValue:numBedRooms];
        }
        
        [step setStepValue:1.0];
        [step setMaximumValue:10.0];
        [step setMinimumValue:0.0];
        [step addTarget:self action:@selector(stepperValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:step];
        
    }
    else if (indexPath.row == 0 || indexPath.row == 3)
    {
        UIButton *dropListBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [dropListBtn addTarget:self action:@selector(DropDownSingle:) forControlEvents:UIControlEventTouchUpInside];
        [dropListBtn setFrame:CGRectMake(self.view.frame.size.width - 130, 10, 120, 25.0)];
        [dropListBtn setBackgroundColor:[UIColor whiteColor]];
        if (indexPath.row == 0)
        {
            NSLog(@"homeType");
            [dropListBtn setTitle:homeType forState:UIControlStateNormal];
        }
        else
        {
            NSLog(@"homeYrBuilt");
            [dropListBtn setTitle:[NSString stringWithFormat:@"%@",homeYrBuilt] forState:UIControlStateNormal];
        }
        
        dropListBtn.tag = indexPath.row;
        [cell.contentView addSubview:dropListBtn];
    }
    else
    {
        UITextField *footage = [[UITextField alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 130, 10, 120, 25.0)];
        footage.backgroundColor = [UIColor lightGrayColor];
        footage.textAlignment = NSTextAlignmentCenter;
        footage.text = [NSString stringWithFormat:@"%@",homeSqFt];
        footage.delegate = self;
        [footage addTarget:self action:@selector(textFieldValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:footage];
    }
    return cell;
}


- (void)stepperValueDidChanged:(id)sender
{
    UIStepper *tempStep = (UIStepper*)sender;
    NSLog(@"STEPPER: %f",tempStep.value);
    if (tempStep.tag == 1) {
        numBedRooms = tempStep.value;
    }
    else
    {
        numBathRooms = tempStep.value;
    }
    [self.tableView reloadData];
}
-(void)textFieldValueDidChanged:(id)sender
{
    UITextField *tempField = (UITextField*)sender;
    homeSqFt = tempField.text;
}
#pragma mark - date picker
- (NSInteger)numberOfComponentsInPickerView: (UIPickerView*)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [years count];
}
- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [years objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Index of selected color: %li", (long)row);
    homeYrBuilt = [NSString stringWithFormat:@"%li",1900 + row];
   
}
#pragma mark - Drop List

- (void)DropDownSingle:(id)sender
{
    UIButton *tempButton = (UIButton*)sender;
    switch (tempButton.tag) {
        case 0:
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Add to" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Single Family", @"Town House",nil];
            sheet.delegate = self;
            [sheet showInView:self.view];
        }
            break;
        case 3:
        {
            alertController = [UIAlertController alertControllerWithTitle:@" Year Built\n\n\n\n\n\n\n\n\n\n"
                                                                  message:@""
                                                           preferredStyle:UIAlertControllerStyleActionSheet];

            UISegmentedControl *closePicker = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Done"]];
            closePicker.momentary = YES;
            closePicker.frame = CGRectMake(25, 10.0f, 50.0f, 30.0f);
            closePicker.segmentedControlStyle = UISegmentedControlStyleBar;
            closePicker.tintColor = [UIColor blackColor];
            [closePicker addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
            [alertController.view addSubview:closePicker];
            
            
            
            pickerFiliter = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 40.0, 320.0, 120.0)];
            pickerFiliter.showsSelectionIndicator = YES;
            pickerFiliter.dataSource = self;
            pickerFiliter.delegate = self;
            [alertController.view addSubview:pickerFiliter];
            [pickerFiliter selectRow:years.count - 1 inComponent:0 animated:NO];
            [self presentViewController:alertController animated:YES completion:nil];
            

        }
            break;
        default:
            break;
    }
    
}
- (IBAction)dismissActionSheet:(id)sender
{
    [alertController dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"response");
    
    switch (buttonIndex) {
        case 0:
        {
            homeType = @"Single Family";
        }
            break;
        case 1:
        {
            homeType = @"Town House";
        }
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
}
#pragma mark - Back navigation
- (void)didMoveToParentViewController:(UIViewController *)parent{
    if (parent == NULL) {
        NSLog(@"Back Pressed");
        [self updateUserInfo];
    }
}

@end
