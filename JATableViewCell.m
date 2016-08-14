//
//  JATableViewCell.m
//  JASwipeCell
//
//  Created by Jose Alvarez on 10/8/14.
//  Copyright (c) 2014 Jose Alvarez. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


#import "JATableViewCell.h"
#import "PureLayout.h"

@interface JATableViewCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *icon;
@property (nonatomic) BOOL constraintsSetup;
@end
@implementation JATableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.topContentView addSubview:self.icon];
        [self.topContentView addSubview:self.titleLabel];
//        self.topContentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}
-(UIImageView*)icon
{
    if(!_icon)
    {
        _icon = [UIImageView newAutoLayoutView];
        _icon.backgroundColor = [UIColor clearColor];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _icon;
}
- (void)updateConstraints
{
    [super updateConstraints];
    
    if (!self.constraintsSetup) {

        [self.icon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:25];
        [self.icon autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
        [self.icon autoSetDimension:ALDimensionWidth toSize:30];
        [self.icon autoSetDimension:ALDimensionHeight toSize:30];
        
        
        [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [self.titleLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.icon withOffset:10];
        [self.titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.topContentView withMultiplier:0.7];
//        [self.titleLabel autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.topContentView withMultiplier:1.0];

        self.constraintsSetup = YES;
        NSLog(@"titleWidth: %f", self.titleLabel.frame.size.width);
        
    }
}

- (void)configureCellWithTitle:(NSString *)title
{
    self.titleLabel.text = title;
    NSLog(@"titleWidth: %f", self.titleLabel.frame.size.width);
}

- (void)configureCellWithIcon:(NSString *)imageName
{
    self.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}
@end
