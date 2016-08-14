//
//  NotificationsViewController.m
//  emPower App
//
//  Created by Rawan on 1/20/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "NotificationsViewController.h"

@interface NotificationsViewController ()
{
    NSMutableArray *monthsArray;
}

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    monthsArray = [[NSMutableArray alloc]initWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",
                                                         @"May",@"Jun",@"Jul",
                                                         @"Aug",@"Sep",@"Oct",
                                                         @"Nov",@"Dec",nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableView delegate methods
//set the number of sections
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//set the number of rows
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [monthsArray count];
}
//config table view cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *cellIdentifier = @"Cell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier]init];
    }
    cell.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[monthsArray objectAtIndex:indexPath.row]];
    return cell;
}
@end
