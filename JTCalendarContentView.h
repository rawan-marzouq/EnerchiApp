//
//  JTCalendarContentView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

@class JTCalendar;

@interface JTCalendarContentView : UIScrollView

@property (weak, nonatomic) JTCalendar *calendarManager;

@property (nonatomic) NSDate *currentDate;

@property (nonatomic,retain) NSArray* subtitlesArray;
@property (nonatomic,retain) NSArray* dateArray;

- (void)reloadData;
- (void)reloadAppearance;
@end
