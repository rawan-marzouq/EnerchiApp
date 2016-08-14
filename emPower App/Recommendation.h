//
//  Recommendation.h
//  emPower App
//
//  Created by Rawan Marzouq on 6/28/15.
//  Copyright (c) 2015 HundW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recommendation : NSObject

@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *subcategory;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) NSString *schedule;
@property (nonatomic, assign) int recomId;
@property (nonatomic, assign) int taskId;
@property (nonatomic, assign) int done;

@end
