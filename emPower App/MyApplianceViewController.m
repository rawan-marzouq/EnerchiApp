//
//  RecommendationsCategoriesViewController.m
//  emPower App
//
//  Created by Rawan on 6/1/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "MyApplianceViewController.h"
#import "SWRevealViewController.h"
#import "Recommendation.h"

@interface MyApplianceViewController ()
{
    NSArray *categories, *categoriesBase;
    NSArray *icons;
    NSMutableArray *appliancesName;
    NSMutableArray *cost;
    NSMutableArray *percent;
    
}
@end

@implementation MyApplianceViewController

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
        navTitleView.font = [UIFont boldSystemFontOfSize:16.0];
        navTitleView.textColor = [UIColor colorWithRed:118.0/255.0 green:206.0/255.0 blue:94.0/255.0 alpha:1.0];
        self.navigationItem.titleView = navTitleView;
    }
    navTitleView.text = @"My Appliances";
    [navTitleView sizeToFit];
    appliancesName=[[NSMutableArray alloc]init];

    cost=[[NSMutableArray alloc]init];
   
    percent=[[NSMutableArray alloc]init];

    
    // Parsing JSON
    [self callREST];
    
    //  Array
        
}


#pragma mark - REST
-(void)callREST
{
    NSError*error;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"myAppliances" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    // Parse the string into JSON
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    // Get all object
    NSArray *items = [json valueForKeyPath:@"appliances"];
    
    for (NSDictionary *item in items) {
        [appliancesName addObject:[item objectForKey:@"name"]];
        [cost addObject:[item objectForKey:@"cost"]];
        [percent addObject:[item objectForKey:@"percent"]];
        
     
    }
    NSLog(@"theObject%@",[percent objectAtIndex:2]);
}




#pragma mark - Table methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [appliancesName count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"we enter here");
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //Name of Appliance
    UILabel *cellTitle = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 200, 20)];
    cellTitle.text = [appliancesName objectAtIndex:indexPath.row];
    cellTitle.textColor = [UIColor blackColor];
    cellTitle.font = [UIFont systemFontOfSize:15];
    [cell addSubview:cellTitle];
    NSLog(@"th errror%@",[appliancesName objectAtIndex:indexPath.row]);
    //% of monthly consumption
    UILabel *cellMonthlyConsumption = [[UILabel alloc]initWithFrame:CGRectMake((cellTitle.text.length+1.3)*7, 3, 200, 20)];
    cellMonthlyConsumption.text =[NSString stringWithFormat:@"%@%@%@",@"(",[percent objectAtIndex:indexPath.row],@")" ];
    cellMonthlyConsumption.textColor = [UIColor grayColor];
    cellMonthlyConsumption.font = [UIFont systemFontOfSize:10];
    [cellTitle addSubview:cellMonthlyConsumption];
  
    //Cost for month
    UILabel *cellMonthCost = [[UILabel alloc]initWithFrame:CGRectMake(50, 40, 200, 20)];
    cellMonthCost.text = @"This Month :";
    cellMonthCost.textColor = [UIColor blackColor];
    cellMonthCost.font = [UIFont systemFontOfSize:12];
    [cell addSubview:cellMonthCost];
    
    UILabel *cellCost = [[UILabel alloc]initWithFrame:CGRectMake(120, 40, 200, 20)];
    cellCost.text =[cost objectAtIndex:indexPath.row];
    cellCost.textColor = [UIColor grayColor];
    cellCost.font = [UIFont systemFontOfSize:12];
    [cell addSubview:cellCost];
    
    // Appliance Icon
    UIImageView *cellIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5,7,40,40)];
    cellIcon.image  = [UIImage imageNamed:@"Xicon"];
    [cell addSubview:cellIcon];
    
    //On/off Button
    UIButton *cellbutton = [[UIButton alloc]initWithFrame:CGRectMake(10,50,10,10)];
    [cellbutton setImage:[UIImage imageNamed:@"greenButton"] forState:UIControlStateNormal];
    [cell addSubview:cellbutton];
    
    //On/Off
    UILabel *labelOffOn=[[UILabel alloc]initWithFrame:CGRectMake(25, 50, 20, 10)];
    labelOffOn.text=@"On";
    labelOffOn.textColor=[UIColor grayColor];
    labelOffOn.font=[UIFont systemFontOfSize:10];
    [cell addSubview:labelOffOn];
    
    // row Label
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height+25 , self.view.frame.size.width, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:line];
    

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

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
