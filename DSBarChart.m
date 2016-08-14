//
//  DSBarChart.m
//  DSBarChart
//
//  Created by DhilipSiva Bijju on 31/10/12.
//  Copyright (c) 2012 Tataatsu IdeaLabs. All rights reserved.
//

#import "DSBarChart.h"

@implementation DSBarChart
@synthesize color, numberOfBars, maxLen, refs, vals;

-(DSBarChart *)initWithFrame:(CGRect)frame
                       color:(UIColor *)theColor
                  references:(NSArray *)references
                   andValues:(NSArray *)values
{
    self = [super initWithFrame:frame];
    if (self) {
        self.color = theColor;
        self.vals = values;
        self.refs = references;
    }
    self.viewForBaselineLayout.backgroundColor = [UIColor clearColor];
    return self;
}

-(void)calculate{
    self.numberOfBars = (int) [self.vals count];
    for (NSNumber *val in vals) {
        float iLen = [val floatValue];
        if (iLen > self.maxLen) {
            self.maxLen = iLen;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    /// Drawing code
    [self calculate];
    float rectWidth = ((float)(rect.size.width-(self.numberOfBars)) / (float)self.numberOfBars) - 5;
    CGContextRef context = UIGraphicsGetCurrentContext();
    float LBL_HEIGHT = 20.0f, iLen, x, heightRatio, height, y;
    UIColor *iColor ;
    
    /// Draw Bars
    for (int barCount = 0; barCount < self.numberOfBars; barCount++)
    {
        
        /// Calculate dimensions
        iLen = [[vals objectAtIndex:barCount] floatValue];
        x = barCount * (rectWidth + 5) + 1;
        heightRatio = iLen / self.maxLen;
        height = heightRatio * rect.size.height;
        if (height < 0.1f) height = 1.0f;
        y = rect.size.height - height - LBL_HEIGHT;
        
        /// Set color and draw the bar
        iColor = [UIColor colorWithRed:(1 - heightRatio) green:(heightRatio) blue:(0) alpha:1.0];
        UIColor *blueColor = [UIColor colorWithRed:26.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
        CGContextSetFillColorWithColor(context, blueColor.CGColor);
        CGRect barRect = CGRectMake(barCount + x, y, rectWidth, height);
        CGContextFillRect(context, barRect);
        
        /// Reference Label.
        UILabel *lblRef = [[UILabel alloc] initWithFrame:CGRectMake(barCount + x, rect.size.height - LBL_HEIGHT, rectWidth, LBL_HEIGHT)];
        lblRef.text = [refs objectAtIndex:barCount];
        lblRef.adjustsFontSizeToFitWidth = TRUE;
        lblRef.adjustsLetterSpacingToFitWidth = TRUE;
        lblRef.textColor = [UIColor grayColor];
        [lblRef setTextAlignment:NSTextAlignmentCenter];
        lblRef.backgroundColor = [UIColor clearColor];
        lblRef.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [self addSubview:lblRef];
        
        /// Value Label.
        UILabel *lblVal;
        if ([[vals objectAtIndex:barCount] floatValue] == maxLen) {
            lblVal = [[UILabel alloc] initWithFrame:CGRectMake(barCount + x, rect.origin.y, rectWidth, LBL_HEIGHT)];
        }
        else
        {
            lblVal = [[UILabel alloc] initWithFrame:CGRectMake(barCount + x, y, rectWidth, LBL_HEIGHT)];
        }
        
        lblVal.text = [vals objectAtIndex:barCount];
        lblVal.adjustsFontSizeToFitWidth = TRUE;
        lblVal.adjustsLetterSpacingToFitWidth = TRUE;
        lblVal.textColor = [UIColor whiteColor];
        [lblVal setTextAlignment:NSTextAlignmentCenter];
        lblVal.backgroundColor = [UIColor clearColor];
        lblVal.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        [self addSubview:lblVal];
        
        
    }
    
//    /// pivot
//    CGRect frame = CGRectZero;
//    frame.origin.x = rect.origin.x;
//    frame.origin.y = rect.origin.y ;
//    frame.size.height = LBL_HEIGHT;
//    frame.size.width = rect.size.width;
//    UILabel *pivotLabel = [[UILabel alloc] initWithFrame:frame];
//    pivotLabel.text = [NSString stringWithFormat:@"%d", (int)self.maxLen];
//    pivotLabel.backgroundColor = [UIColor clearColor];
//    pivotLabel.textColor = [UIColor colorWithRed:26.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
//    [self addSubview:pivotLabel];
//    
//    /// A line
//    frame = rect;
//    frame.size.height = 1.0;
//    UIColor *lineColor = [UIColor colorWithRed:26.0f/255.0f green:147.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
//    CGContextSetFillColorWithColor(context, lineColor.CGColor);
//    CGContextFillRect(context, frame);
}


@end
