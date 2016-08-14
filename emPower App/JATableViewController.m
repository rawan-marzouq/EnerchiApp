//
//  JATableViewController.m
//  JASwipeCell
//
//  Created by Jose Alvarez on 10/8/14.
//  Copyright (c) 2014 Jose Alvarez. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "JATableViewController.h"
#import "JATableViewCell.h"
#import "JAActionButton.h"
#import "Recommendation.h"

#define kJATableViewCellReuseIdentifier     @"JATableViewCellIdentifier"

#define kFlagButtonColor        [UIColor colorWithRed:255.0/255.0 green:150.0/255.0 blue:0/255.0 alpha:1]
#define kMoreButtonColor        [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1]
#define kArchiveButtonColor     [UIColor colorWithRed:60.0/255.0 green:112.0/255.0 blue:168/255.0 alpha:1]
#define kUnreadButtonColor      [UIColor colorWithRed:0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1]

@interface JATableViewController ()<JASwipeCellDelegate, UIActionSheetDelegate>
{
    NSMutableArray *recommendationsArray;
    NSString *iconName;
    int taskIndex;
    NSArray *icons;
}
@property (nonatomic, strong) NSMutableArray *tableData;
@end

@implementation JATableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryTitle"]];
    
    [self getAllTasks];
    
    [self.tableView registerClass:[JATableViewCell class] forCellReuseIdentifier:kJATableViewCellReuseIdentifier];
    
//    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(getAllTasks)];
//    self.navigationItem.rightBarButtonItem = resetButton;
    
    // Icons Array
    icons = [[NSMutableArray alloc]initWithObjects:@"seasonalIcon", @"laundryIcon", @"electricityIcon", @"kitchenIcon", @"coolingIcon", nil];
    icons = [icons sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
}

# pragma mark - cell buttons
//- (NSArray *)leftButtons
//{
//    __typeof(self) __weak weakSelf = self;
//    JAActionButton *button1 = [JAActionButton actionButtonWithTitle:@"Delete" color:[UIColor redColor] handler:^(UIButton *actionButton, JASwipeCell*cell) {
//        [cell completePinToTopViewAnimation];
//        [weakSelf leftMostButtonSwipeCompleted:cell];
//        NSLog(@"Left Button: Delete Pressed");
//    }];
//
//    return @[button1];
//}

- (NSArray *)rightButtonsAtIndex: (int)index
{
    Recommendation *recomObj = (Recommendation*)[recommendationsArray objectAtIndex:index];
//    __typeof(self) __weak weakSelf = self;
    JAActionButton *button1 = [JAActionButton actionButtonWithTitle:@"Morning" color:kArchiveButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell)
    {
        
        [self addTaskWithId:recomObj.recomId ForAccount:@"1234567" At:@"Morning"];
        NSLog(@"Right Button: Morning Pressed: %i, %@", recomObj.recomId, recomObj.category);
    }];
    
    JAActionButton *button2 = [JAActionButton actionButtonWithTitle:@"Afternoon" color:kFlagButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell)
    {
        [self addTaskWithId:recomObj.recomId ForAccount:@"1234567" At:@"Afternoon"];
        NSLog(@"Right Button: Afternoon Pressed");
    }];
    JAActionButton *button3 = [JAActionButton actionButtonWithTitle:@"Night" color:kMoreButtonColor handler:^(UIButton *actionButton, JASwipeCell*cell)
    {
        [self addTaskWithId:recomObj.recomId ForAccount:@"1234567" At:@"Night"];
        NSLog(@"Right Button: Night Pressed");
    }];
    
    return @[button1, button2, button3];
}

#pragma mark - REST
-(void)getAllTasks
{
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/ios-data/tm/allTasks"]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/tm/allTasks"]];
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
             NSLog(@"callResult: %@",jsonObjects);
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 
                 // Handle Error and return
                 return;
                 
             }
             
             // recommedations
             recommendationsArray = [[NSMutableArray alloc]init];
             
             NSArray *recommendationsData = [jsonObjects objectForKey:@"data"];
             for (int i = 0; i < [recommendationsData count]; i++) {
                 NSDictionary *data = (NSDictionary*) [recommendationsData objectAtIndex:i];
                 
                 Recommendation *recomObject = [Recommendation new];
                 recomObject.category = [data objectForKey:@"category"];
                 recomObject.subcategory = [data objectForKey:@"sub-category"];
                 recomObject.info = [data objectForKey:@"text"];
                 recomObject.recomId = [[data objectForKey:@"id"] intValue];
                 NSLog(@"NAME: %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryName"]);
                 if ([recomObject.category isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryName"]]) {
                     [recommendationsArray addObject:recomObject];
                     iconName = [NSString stringWithFormat:@"%@Icon",[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryName"]];NSLog(@"looooog");
                 }
                 
             }
             
         }
         self.tableData = [[NSMutableArray alloc] init];
         [self.tableData addObjectsFromArray:recommendationsArray];
         NSLog(@"[recommendationsArray count]: %lu",(unsigned long)[recommendationsArray count]);
         [self.tableView reloadData];
     }];
    
}
-(void)addTaskWithId:(int)index ForAccount:(NSString*)account At:(NSString*)time
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://10.20.1.19:3000/api/v1/tm/addTask?taskTypeId=%i&when=%@", index, time]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
    [request setValue:token forHTTPHeaderField:@"X-Access-Token"];
    
    [request setHTTPMethod:@"POST"];
    
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
             NSLog(@"callResult: %@",jsonObjects);
             if (error) {
                 NSLog(@"error is %@", [error localizedDescription]);
                 
                 // Handle Error and return
                 return;
                 
             }
         }
     }];

    Recommendation *recomObj = (Recommendation*)[recommendationsArray objectAtIndex:taskIndex];
    [recommendationsArray removeObjectAtIndex:taskIndex];
    [recommendationsArray insertObject:recomObj atIndex:[recommendationsArray count]];
    self.tableData = [[NSMutableArray alloc] init];
    [self.tableData addObjectsFromArray:recommendationsArray];
    [self.tableView reloadData];
    NSLog(@"move to bottom");
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    JATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJATableViewCellReuseIdentifier];
    
//    [cell addActionButtons:[self leftButtons] withButtonWidth:kJAButtonWidth withButtonPosition:JAButtonLocationLeft];
    [cell addActionButtons:[self rightButtonsAtIndex:(int)indexPath.row] withButtonWidth:kJAButtonWidth withButtonPosition:JAButtonLocationRight];
    
    cell.delegate = self;
    Recommendation  *recomObj = (Recommendation*)[recommendationsArray objectAtIndex:indexPath.row];
    
    [cell configureCellWithIcon:[NSString stringWithFormat:@"%@",[icons objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"categoryIndex"]intValue]]]];
    [cell configureCellWithTitle:recomObj.info];
    NSLog(@"recommendationsArray: %lu", (unsigned long)[recommendationsArray count]);
    [cell setBackgroundColor:[UIColor whiteColor]];
    UIImageView *addBtnImage = [[UIImageView alloc]init];
    addBtnImage.image = [UIImage imageNamed:@"cellBG"];
    [cell setBackgroundView:addBtnImage];
    [cell setNeedsLayout];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(void)addTaskButtonPressedAtIndex:(int)index
{
    __typeof(self) __weak weakSelf = self;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Add to" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Morning" otherButtonTitles:@"Afternoon", @"Night",nil];
    sheet.delegate = self;
    [sheet showInView:weakSelf.view];
    NSLog(@"actionsheet");
}
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"response");
     Recommendation *recomObj = (Recommendation*)[recommendationsArray objectAtIndex:taskIndex];
    switch (buttonIndex) {
        case 0:
        {
            [self addTaskWithId:recomObj.recomId ForAccount:@"1234567" At:@"Morning"];
            NSLog(@"Morning Pressed: %i, %@", recomObj.recomId, recomObj.category);
        }
            break;
        case 1:
        {
            [self addTaskWithId:recomObj.recomId ForAccount:@"1234567" At:@"Afternoon"];
            NSLog(@"Afternoon Pressed: %i, %@", recomObj.recomId, recomObj.category);
        }
            break;
        case 2:
        {
            [self addTaskWithId:recomObj.recomId ForAccount:@"1234567" At:@"Night"];
            NSLog(@"Night Pressed: %i, %@", recomObj.recomId, recomObj.category);
        }
            break;
        default:
            break;
    }
    
    
}
#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Recommendation  *recomObj = (Recommendation*)[recommendationsArray objectAtIndex:indexPath.row];
    UILabel *taskLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [taskLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [taskLabel setNumberOfLines:0];
    [taskLabel setFont:[UIFont systemFontOfSize:14]];
    CGSize constraint = CGSizeMake(self.tableView.frame.size.width - 50, 20000.0f);
    
    taskLabel.text = recomObj.info;
    CGSize size = [taskLabel.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    [taskLabel setFrame:CGRectMake(10,0,size.width,size.height)];
    if (taskLabel.frame.size.height + 20 < 100) {
        return 100;
    }
    return taskLabel.frame.size.height + 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"test");

    JASwipeCell *cell = (JASwipeCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.2 animations:^{
        [cell setFrame:CGRectMake(cell.frame.origin.x - 60, cell.frame.origin.y, cell.bounds.size.width, cell.bounds.size.height)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
            [cell setFrame:CGRectMake(cell.frame.origin.x + 60, cell.frame.origin.y, cell.bounds.size.width, cell.bounds.size.height)];
        } completion:^(BOOL finished) {
        
        }];
    }];
    
}
-(void)panImageView{
    NSLog(@"PAN");
}
#pragma mark - JASwipeCellDelegate methods

- (void)swipingRightForCell:(JASwipeCell *)cell
{
//    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
//    for (NSIndexPath *indexPath in indexPaths) {
//        JASwipeCell *visibleCell = (JASwipeCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//        if (visibleCell != cell) {
//            [visibleCell resetContainerView];
//        }
//        
//    }
}

- (void)swipingLeftForCell:(JASwipeCell *)cell
{
    NSLog(@"swipe left");
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        JASwipeCell *visibleCell = (JASwipeCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if (visibleCell != cell) {
            [visibleCell resetContainerView];
        }
        
    }
}

- (void)leftMostButtonSwipeCompleted:(JASwipeCell *)cell
{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    [self.tableData removeObjectAtIndex:indexPath.row];
//    
//    [self.tableView beginUpdates];
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
}

- (void)rightMostButtonSwipeCompleted:(JASwipeCell *)cell
{
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    [self.tableData removeObjectAtIndex:indexPath.row];
//    
//    [self.tableView beginUpdates];
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in indexPaths) {
        JASwipeCell *cell = (JASwipeCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell resetContainerView];
    }
}

@end
