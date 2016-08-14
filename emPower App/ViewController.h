//
//  ViewController.h
//  emPower App
//
//  Created by Rawan on 1/17/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>
{
    int numDay;
    NSDate*now;
    NSDate*finalDate;
}
@property (weak, nonatomic) IBOutlet UIButton *googlePlusButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

- (IBAction)LoginProviderPressed:(id)sender;
- (IBAction)demoLogin:(id)sender;
- (IBAction)SignOutPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *loadingView;


// user creditials
@property (weak, nonatomic) IBOutlet UITextField *usernameTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;

@end

//user5@enerchi.com
//enerchi