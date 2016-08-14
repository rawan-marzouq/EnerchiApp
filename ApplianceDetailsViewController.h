//
//  ApplianceDetailsViewController.h
//  emPower App
//
//  Created by Rawan on 3/23/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApplianceDetailsViewController : UIViewController
@property (nonatomic, assign) int applianceIndex;
@property (nonatomic) NSString *applianceName;

//-(void)setValue:(NSString*)name;

@property (weak, nonatomic) IBOutlet UILabel *spentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onOffIcon;
@property (weak, nonatomic) IBOutlet UILabel *applienceOnOffStatus;

@property (weak, nonatomic) IBOutlet UILabel *onOffPeriodLabel;
@property (weak, nonatomic) IBOutlet UILabel *consumptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *applianceIcon;
@property (weak, nonatomic) IBOutlet UIView *watch;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *smartKeyLabel;
// line chart
@property (strong, nonatomic) IBOutlet UIView *lineChartView;
@end
