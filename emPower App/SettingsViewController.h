//
//  SettingsViewController.h
//  
//
//  Created by Rawan on 1/20/15.
//
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
// Menu button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
// Leaves
@property (weak, nonatomic) IBOutlet UIBarButtonItem *notificationLeaf;
- (IBAction)tmGreenLeafPressed:(id)sender;
@end
