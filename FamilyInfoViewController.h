//
//  FamilyInfoViewController.h
//  emPower App
//
//  Created by Rawan Marzouq on 7/28/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamilyInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
