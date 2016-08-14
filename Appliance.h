//
//  Appliance.h
//  emPower App
//
//  Created by Rawan on 3/18/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Appliance : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *spent;
@property (nonatomic, assign) int totalTime;
@property (nonatomic, retain) NSMutableArray *timePeriods;

@end
