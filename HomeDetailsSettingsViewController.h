//
//  HomeDetailsSettingsViewController.h
//  emPower App
//
//  Created by Rawan Marzouq on 8/4/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeDetailsSettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
