//
//  MyApplianceViewController.h
//  emPower App
//
//  Created by Rawan Marzouq on 9/2/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyApplianceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (weak, nonatomic) IBOutlet UITableView *recommTableView;
- (IBAction)tmGreenLeafPressed:(id)sender;
@end
