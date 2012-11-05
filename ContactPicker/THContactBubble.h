//
//  THContactBubble.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class THContactBubble;

@protocol THContactBubbleDelegate <NSObject>

- (void)contactBubbleWasSelected:(THContactBubble *)contactBubble;
- (void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble;

@end

@interface THContactBubble : UIView <UITextViewDelegate>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) id <THContactBubbleDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) UIColor *colorGradientTop;
@property (nonatomic, strong) UIColor *colorGradientBottom;
@property (nonatomic, strong) UIColor *colorBorder;

@property (nonatomic, strong) UIColor *colorSelectedGradientTop;
@property (nonatomic, strong) UIColor *colorSelectedGradientBottom;
@property (nonatomic, strong) UIColor *colorSelectedBorder;

- (id)initWithName:(NSString *)name;
- (void)select;
- (void)unSelect;

@end
