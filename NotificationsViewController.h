//
//  NotificationsViewController.h
//  emPower App
//
//  Created by Rawan on 1/20/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *monthsTable;

@end
