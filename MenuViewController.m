//
//  MenuViewController.m
//  emPower App
//
//  Created by Rawan on 1/25/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import <Security/Security.h>
@interface MenuViewController ()
{
    NSArray *menuItems;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    menuItems = @[@"Home",@"BillingPeriod",@"TaskManager",@"Recommendations",@"Settings",@"myAppliance",@"Logout"];
    
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [menuItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        NSString *reuseIdentifier = [menuItems objectAtIndex:indexPath.row];
        NSLog(@"reuseIdentifier: %@",reuseIdentifier);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        // Configure the cell appereance...
        //    cell.textLabel.text = [menuItems objectAtIndex:indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79.0;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 6)
    {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"token"];
        NSLog(@"Logout");
        //Let's create an empty mutable dictionary:
        NSMutableDictionary *keychainItem = [NSMutableDictionary dictionary];
        
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        NSString *website = @"server";
      
        
        //Populate it with the data and the attributes we want to use.
        
        keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
        keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.
        keychainItem[(__bridge id)kSecAttrServer] = website;
        keychainItem[(__bridge id)kSecAttrAccount] = username;
        
        //Check if this keychain item already exists.
        
        if(SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, NULL) == noErr)
        {
            OSStatus sts = SecItemDelete((__bridge CFDictionaryRef)keychainItem);
            NSLog(@"Error Code: %d", (int)sts);
            //Navigate to the Login View
            UIViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:loginVC animated:YES completion:nil];

        }else{
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"The Item Doesn't Exist.", nil)
                                                            message:NSLocalizedString(@"The item doesn't exist. It may have already been deleted.", nil)                                                          delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        

    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue isKindOfClass:[SWRevealViewControllerSegue class]])
    {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*)segue;
        swSegue.performBlock = ^(SWRevealViewControllerSegue * rvc_segue, UIViewController *svc, UIViewController *dvc){
            UINavigationController *navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers:@[dvc] animated:NO];
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        };
    }
}
@end
