//
//  HomeSettingsViewController.m
//  emPower App
//
//  Created by Rawan Marzouq on 7/28/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "HomeSettingsViewController.h"

@interface HomeSettingsViewController ()
{
    NSMutableArray      *homeCategoriesArray;
}
@end

@implementation HomeSettingsViewController

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
    
    navTitleView.text = @"My Home";
    [navTitleView sizeToFit];
    
    homeCategoriesArray = [[NSMutableArray alloc]initWithObjects:@"Family Info",@"Home Details",@"Appliances", nil];
    
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
    return [homeCategoriesArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.textLabel.text = [homeCategoriesArray objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        //Navigate to the family info Settings View
        [[NSUserDefaults standardUserDefaults]setObject:@"familyInfo" forKey:@"category"];
        UIViewController *generalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"familyInfo"];
        [self.navigationController pushViewController:generalVC animated:YES];
    }
    else if (indexPath.row == 1)
    {
        //Navigate to the home details Settings View
        UIViewController *generalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeDetails"];
        [self.navigationController pushViewController:generalVC animated:YES];
    }
    else if (indexPath.row == 2)
    {
        //Navigate to the family info Settings View
        [[NSUserDefaults standardUserDefaults]setObject:@"appliances" forKey:@"category"];
        UIViewController *generalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"familyInfo"];
        [self.navigationController pushViewController:generalVC animated:YES];
    }
}
@end
