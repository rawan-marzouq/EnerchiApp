//
//  main.m
//  emPower App
//
//  Created by Rawan on 1/17/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <ABCalendarPicker/ABCalendarPicker.h>

int main(int argc, char * argv[]) {
    
    @autoreleasepool {
        [ABCalendarPicker class];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
