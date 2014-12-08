//
//  THContactView.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "THContactViewStyle.h"

@class THContactView;
@class THContactTextField;

@protocol THContactViewDelegate <NSObject>

- (void)contactViewWasSelected:(THContactView *)contactView;
- (void)contactViewWasUnSelected:(THContactView *)contactView;
- (void)contactViewShouldBeRemoved:(THContactView *)contactView;

@end

@interface THContactView : UIView <UITextViewDelegate, UITextInputTraits>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) THContactTextField *textField; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL showComma;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) id <THContactViewDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) THContactViewStyle *style;
@property (nonatomic, strong) THContactViewStyle *selectedStyle;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name style:(THContactViewStyle *)style selectedStyle:(THContactViewStyle *)selectedStyle;
- (id)initWithName:(NSString *)name style:(THContactViewStyle *)style selectedStyle:(THContactViewStyle *)selectedStyle showComma:(BOOL)showComma;

- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;

@end
