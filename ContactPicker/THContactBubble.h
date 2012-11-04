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

@end

@interface THContactBubble : UIView

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) id <THContactBubbleDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

- (id)initWithName:(NSString *)name;
- (void)select;
- (void)unSelect;

@end
