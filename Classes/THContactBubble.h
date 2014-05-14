//
//  THContactBubble.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "THBubbleStyle.h"

@class THContactBubble;

@protocol THContactBubbleDelegate <NSObject>

- (void)contactBubbleWasSelected:(THContactBubble *)contactBubble;
- (void)contactBubbleWasUnSelected:(THContactBubble *)contactBubble;
- (void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble;

@end

@interface THContactBubble : UIView <UITextViewDelegate, UITextInputTraits>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UITextView *textView; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL showComma;
@property (nonatomic, assign) id <THContactBubbleDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) THBubbleStyle *style;
@property (nonatomic, strong) THBubbleStyle *selectedStyle;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name style:(THBubbleStyle *)style selectedStyle:(THBubbleStyle *)selectedStyle;
- (id)initWithName:(NSString *)name style:(THBubbleStyle *)style selectedStyle:(THBubbleStyle *)selectedStyle showComma:(BOOL)showComma;

- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;

@end
