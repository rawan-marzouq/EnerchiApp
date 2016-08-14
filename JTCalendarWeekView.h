//
//  JTCalendarWeekView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

@interface JTCalendarWeekView : UIView

@property (weak, nonatomic) JTCalendar *calendarManager;

@property (assign, nonatomic) NSUInteger currentMonthIndex;
@property (nonatomic,retain) NSArray* subtitlesArray;
@property (nonatomic,retain) NSArray* dateArray;

- (void)setBeginningOfWeek:(NSDate *)date;
- (void)reloadData;
- (void)reloadAppearance;

@end
