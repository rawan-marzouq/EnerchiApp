//
//  ChecklistViewController.m
//  emPower App
//
//  Created by Rawan on 1/25/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import "ChecklistViewController.h"
#import "SWRevealViewController.h"

@interface ChecklistViewController ()

@end

@implementation ChecklistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        navTitleView.font = [UIFont boldSystemFontOfSize:22.0];
        navTitleView.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = navTitleView;
    }
    navTitleView.text = @"Checklist";
    [navTitleView sizeToFit];
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

@end
