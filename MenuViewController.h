//
//  MenuViewController.h
//  emPower App
//
//  Created by Rawan on 1/25/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tabelView;

@end
