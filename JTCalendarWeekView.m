//
//  JTCalendarWeekView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarWeekView.h"

#import "JTCalendarDayView.h"

@interface JTCalendarWeekView (){
    NSArray *daysViews;
};

@end

@implementation JTCalendarWeekView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    NSMutableArray *views = [NSMutableArray new];
    
    for(int i = 0; i < 7; ++i){
        UIView *view = [JTCalendarDayView new];
        [views addObject:view];
        [self addSubview:view];
    }
    
    daysViews = views;
}

- (void)layoutSubviews
{
    CGFloat x = 0;
    CGFloat width = self.frame.size.width / 7.;
    CGFloat height = self.frame.size.height;
    
    if(self.calendarManager.calendarAppearance.readFromRightToLeft){
        for(UIView *view in [[self.subviews reverseObjectEnumerator] allObjects]){
            view.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(view.frame);
        }
    }
    else{
        for(UIView *view in self.subviews){
            view.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(view.frame);
        }
    }
    
    [super layoutSubviews];
}

- (void)setBeginningOfWeek:(NSDate *)date
{
    NSDate *currentDate = date;
    NSDate *today = [[NSDate alloc]init];
//    NSLog(@"today: %@, date: %@", today, currentDate);
    
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
    [dateFormatter setDateFormat:self.calendarManager.calendarAppearance.dayFormat];
    NSString *todayStr = [dateFormatter stringFromDate:today];
    NSString *currentDayStr = [dateFormatter stringFromDate:currentDate];
    
    int step = ([todayStr intValue] - [currentDayStr intValue]);
//    NSLog(@"todayStr: %@, currentDayStr: %@, step: %i",todayStr, currentDayStr,step);
    
    NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;
    int i = 1;
    int viewIndex = 0;
    for(JTCalendarDayView *view in daysViews){
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:self.calendarManager.calendarAppearance.dayFormat];
        NSString *currentDayStr2 = [dateFormatter stringFromDate:currentDate];
        
        if(!self.calendarManager.calendarAppearance.isWeekMode){
            NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:currentDate];
            NSInteger monthIndex = comps.month;
            
            [view setIsOtherMonth:monthIndex != self.currentMonthIndex];
            if (self.subtitlesArray.count > 0)
            {
                if (i <= self.subtitlesArray.count ) {
                    
                    if ([[self.dateArray objectAtIndex:self.dateArray.count - 1 - (i - 1)] intValue] == [currentDayStr2 intValue]) {
                        view.dataLabel.text = [NSString stringWithFormat:@"$%2.2f",[[self.subtitlesArray objectAtIndex:self.subtitlesArray.count - 1 - (i - 1)]floatValue]];
                        step++;
                        i++;
                    }
                    
                }
                else{
                    view.dataLabel.text = @"";
                }
                
            }
        }
        else{
            if (self.subtitlesArray.count > 0)
            {
                if (i <= self.subtitlesArray.count ) {
                    
                    if ([[self.dateArray objectAtIndex:self.dateArray.count - 1 - (i - 1)] intValue] == [currentDayStr2 intValue]) {
                        view.dataLabel.text = [NSString stringWithFormat:@"$%2.2f",[[self.subtitlesArray objectAtIndex:self.subtitlesArray.count - 1 - (i - 1)]floatValue]];
                        step++;
                        i++;
                    }
                    
                }
                else{
                    view.dataLabel.text = @"";
                }
                
            }
            [view setIsOtherMonth:NO];
        }
        
        [view setDate:currentDate];
        
        NSDateComponents *dayComponent = [NSDateComponents new];
        dayComponent.day = 1;
        
        currentDate = [calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
    
        
        viewIndex++;
    }
}

#pragma mark - JTCalendarManager

- (void)setCalendarManager:(JTCalendar *)calendarManager
{
    self->_calendarManager = calendarManager;
    for(JTCalendarDayView *view in daysViews){
        [view setCalendarManager:calendarManager];
    }
}

- (void)reloadData
{
    for(JTCalendarDayView *view in daysViews){
        [view reloadData];
    }
}

- (void)reloadAppearance
{
    for(JTCalendarDayView *view in daysViews){
        [view reloadAppearance];
    }
}

@end
