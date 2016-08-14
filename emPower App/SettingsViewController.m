//
//  SettingsViewController.m
//  
//
//  Created by Rawan on 1/20/15.
//
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"
#import "MAFormViewController.h"
#import "MAFormField.h"


@interface SettingsViewController ()
{
    NSMutableArray *settingsSections;
    
    NSString        *cityText;
    NSString        *emailText;
    NSString        *firstNameText;
    NSString        *lastNameText;
    NSString        *phoneText;
    NSString        *stateText;
    NSString        *streetText;
    NSString        *zipText;
    MAFormViewController        *formVC;
    
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
    navTitleView.text = @"Settings";
    [navTitleView sizeToFit];
    
    settingsSections = [[NSMutableArray alloc]initWithObjects:@"General",@"My Home",@"My Utility",@"My Devices", nil];
    
    [self getUserInfo];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self getUserInfo];
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
//             NSLog(@"Settings callResult: %@",jsonObjects);
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 
                 // Handle Error and return
                 return;
                 
             }
             NSDictionary *userData = [jsonObjects objectForKey:@"data"];
             
             cityText = [userData objectForKey:@"city"];
             emailText = [userData objectForKey:@"email"];
             firstNameText = [userData objectForKey:@"firstName"];
             lastNameText = [userData objectForKey:@"lastName"];
             phoneText = [userData objectForKey:@"phone"];
             stateText = [userData objectForKey:@"state"];
             streetText = [userData objectForKey:@"street"];
             zipText = [userData objectForKey:@"zip"];
         }
     }];
}
-(void)updateUserInfo:(NSDictionary*)newInfo
{
    NSLog(@"newInfo: %@",newInfo);
    // Convert jSON string to data
    NSString *jSONString = [NSString stringWithFormat:@"{\"street\": \"%@\",\"city\": \"%@\",\"zip\": \"%@\",\"state\": \"%@\",\"phone\": \"%@\",\"firstName\": \"%@\",\"lastName\": \"%@\",\"email\": \"%@\"}",newInfo[@"street"], newInfo[@"city"], newInfo[@"zip"], newInfo[@"state"], newInfo[@"phone"], newInfo[@"fname"], newInfo[@"lname"], newInfo[@"email"]];
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
    return [settingsSections count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // title label
//    cell.textLabel.text = [settingsSections objectAtIndex:indexPath.row];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 200, 20)];
    title.textColor = [UIColor blackColor];
    title.text =[settingsSections objectAtIndex:indexPath.row];
    [cell addSubview:title];
    
    // icon
//    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Icon",[settingsSections objectAtIndex:indexPath.row]]];
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Icon",[settingsSections objectAtIndex:indexPath.row]]];
    [cell addSubview:icon];
    
    // line
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, self.view.frame.size.width, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:line];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   

    if (indexPath.row == 0)
    {
        [self showGeneralForm];
    }
    else if (indexPath.row == 1)
    {
        //Navigate to the Home Settings View
            UIViewController *generalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeSettings"];
            [self.navigationController pushViewController:generalVC animated:YES];
    }
}
#pragma mark - General Settings
- (void)showGeneralForm
{

    // create the cells
    MAFormField *fName = [MAFormField fieldWithKey:@"fname" type:MATextFieldTypeNonEditable initialValue:firstNameText placeholder:@"Fisrt Name" required:NO];
    MAFormField *lName = [MAFormField fieldWithKey:@"lname" type:MATextFieldTypeNonEditable initialValue:lastNameText placeholder:@"Last Name" required:NO];
    MAFormField *phone = [MAFormField fieldWithKey:@"phone" type:MATextFieldTypeNonEditable initialValue:phoneText placeholder:@"Phone Number" required:NO];
    MAFormField *email = [MAFormField fieldWithKey:@"email" type:MATextFieldTypeNonEditable initialValue:emailText placeholder:@"Email (optional)" required:NO];
    MAFormField *street = [MAFormField fieldWithKey:@"street" type:MATextFieldTypeNonEditable initialValue:streetText placeholder:@"Street" required:NO];
    MAFormField *city = [MAFormField fieldWithKey:@"city" type:MATextFieldTypeNonEditable initialValue:cityText placeholder:@"City" required:NO];
    MAFormField *state = [MAFormField fieldWithKey:@"state" type:MATextFieldTypeNonEditable initialValue:stateText placeholder:@"State" required:NO];
    MAFormField *zip = [MAFormField fieldWithKey:@"zip" type:MATextFieldTypeNonEditable initialValue:zipText placeholder:@"ZIP" required:NO];
    
    //    MAFormField *date = [MAFormField fieldWithKey:@"date" type:MATextFieldTypeDate initialValue:nil placeholder:@"Date (MM/DD/YYYY)" required:NO];
//        MAFormField *disabledField = [MAFormField fieldWithKey:@"disabled" type:MATextFieldTypeNonEditable initialValue:@"This is not editable." placeholder:@"Disabled Field" required:NO];
    
    // separate the cells into sections
    NSArray *firstSection = @[fName, lName, phone, email];
    NSArray *secondSection = @[street, city, state, zip];
    //    NSArray *thirdSection = @[date, disabledField];
    NSArray *cellConfig = @[firstSection, secondSection];
    
    // create the form, wrap it in a navigation controller, and present it modally
    formVC = [[MAFormViewController alloc] initWithCellConfigurations:cellConfig actionText:@"Edit" animatePlaceholders:YES withCancel:NO handler:^(NSDictionary *resultDictionary) {
        // now that we're done, dismiss the form
//        [self.navigationController popToRootViewControllerAnimated:YES];
        [self showGeneralEditableForm];
        
        // if we don't have a result dictionary, the user cancelled, rather than submitted the form
        if (!resultDictionary) {
            return;
        }
        
        // do whatever you want with the results - you can access specific values from the dictionary using
        // the key you provided when you created the form
//        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Thanks for registering %@!", resultDictionary[@"name"]] delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil] show];
        
        
//        [self updateUserInfo:resultDictionary];
    }];
    formVC.title = @"General Settings";
    [formVC setTitleForHeaderInSectionBlock:^NSString *(NSInteger section) {
        if (section == 1) {
            return @"Address";
        }
        
        else {
            return nil;
        }
    }];
    
    [formVC setTitleForFooterInSectionBlock:^NSString *(NSInteger section) {
        if (section == 2) {
            return @"Example Footer";
        }
        
        else {
            return nil;
        }
    }];
    
//    UINavigationController *formNC = [[UINavigationController alloc] initWithRootViewController:formVC];
    [self.navigationController pushViewController:formVC animated:YES];
}

- (void)showGeneralEditableForm
{
    
    // create the cells
    MAFormField *fName = [MAFormField fieldWithKey:@"fname" type:MATextFieldTypeName initialValue:firstNameText placeholder:@"Fisrt Name" required:YES];
    MAFormField *lName = [MAFormField fieldWithKey:@"lname" type:MATextFieldTypeName initialValue:lastNameText placeholder:@"Last Name" required:YES];
    MAFormField *phone = [MAFormField fieldWithKey:@"phone" type:MATextFieldTypePhone initialValue:phoneText placeholder:@"Phone Number" required:YES];
    MAFormField *email = [MAFormField fieldWithKey:@"email" type:MATextFieldTypeEmail initialValue:emailText placeholder:@"Email (optional)" required:NO];
    MAFormField *street = [MAFormField fieldWithKey:@"street" type:MATextFieldTypeAddress initialValue:streetText placeholder:@"Street" required:YES];
    MAFormField *city = [MAFormField fieldWithKey:@"city" type:MATextFieldTypeAddress initialValue:cityText placeholder:@"City" required:YES];
    MAFormField *state = [MAFormField fieldWithKey:@"state" type:MATextFieldTypeAddress initialValue:stateText placeholder:@"State" required:YES];
    MAFormField *zip = [MAFormField fieldWithKey:@"zip" type:MATextFieldTypeZIP initialValue:zipText placeholder:@"ZIP" required:YES];
    
    //    MAFormField *date = [MAFormField fieldWithKey:@"date" type:MATextFieldTypeDate initialValue:nil placeholder:@"Date (MM/DD/YYYY)" required:NO];
    //        MAFormField *disabledField = [MAFormField fieldWithKey:@"disabled" type:MATextFieldTypeNonEditable initialValue:@"This is not editable." placeholder:@"Disabled Field" required:NO];
    
    // separate the cells into sections
    NSArray *firstSection = @[fName, lName, phone, email];
    NSArray *secondSection = @[street, city, state, zip];
    //    NSArray *thirdSection = @[date, disabledField];
    NSArray *cellConfig = @[firstSection, secondSection];
    
    // create the form, wrap it in a navigation controller, and present it modally
    MAFormViewController *editableFormVC = [[MAFormViewController alloc] initWithCellConfigurations:cellConfig actionText:@"Edit" animatePlaceholders:YES withCancel:YES handler:^(NSDictionary *resultDictionary) {
        // now that we're done, dismiss the form
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        
        // if we don't have a result dictionary, the user cancelled, rather than submitted the form
        if (!resultDictionary) {
            return;
        }
        
        // do whatever you want with the results - you can access specific values from the dictionary using
        // the key you provided when you created the form
        //        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Thanks for registering %@!", resultDictionary[@"name"]] delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil] show];
        
        
        [self updateUserInfo:resultDictionary];
    }];
    editableFormVC.title = @"General Settings";
    [editableFormVC setTitleForHeaderInSectionBlock:^NSString *(NSInteger section) {
        if (section == 1) {
            return @"Address";
        }
        
        else {
            return nil;
        }
    }];
    
    [editableFormVC setTitleForFooterInSectionBlock:^NSString *(NSInteger section) {
        if (section == 2) {
            return @"Example Footer";
        }
        
        else {
            return nil;
        }
    }];
    
    //    UINavigationController *formNC = [[UINavigationController alloc] initWithRootViewController:formVC];
    [self.navigationController pushViewController:editableFormVC animated:NO];
}

- (IBAction)tmGreenLeafPressed:(id)sender {
    //Navigate to the Task manager View Controller
    UIViewController *tmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"tmViewController"];
    [self.navigationController pushViewController:tmVC animated:YES];
}
@end
