//
//  THContactBubble.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactBubble.h"

@implementation THContactBubble

#define kHorizontalPadding 10
#define kVerticalPadding 2
#define kCornerRadius 12

#define kColorGradientTop [UIColor colorWithRed:219.0/255.0 green:229.0/255.0 blue:249.0/255.0 alpha:1.0]
#define kColorGradientBottom [UIColor colorWithRed:188.0/255.0 green:205.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kColorBorder [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:218.0/255.0 alpha:1.0]

#define kColorSelectedGradientTop [UIColor colorWithRed:79.0/255.0 green:132.0/255.0 blue:255.0/255.0 alpha:1.0]
#define kColorSelectedGradientBottom [UIColor colorWithRed:73.0/255.0 green:58.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kColorSelectedBorder [UIColor colorWithRed:56.0/255.0 green:0/255.0 blue:233.0/255.0 alpha:1.0]

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self){
        self.name = name;
        self.isSelected = NO;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    // Create Label
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = self.name;
    [self addSubview:self.label];
    
    // Adjust the label frames
    [self.label sizeToFit];
    CGRect frame = self.label.frame;
    frame.origin.x = kHorizontalPadding;
    frame.origin.y = kVerticalPadding;
    self.label.frame = frame;

    // Adjust view frame
    self.bounds = CGRectMake(0, 0, frame.size.width + 2 * kHorizontalPadding, frame.size.height + 2 * kVerticalPadding);

    // Round the corners
    CALayer *viewLayer = [self layer];
    viewLayer.cornerRadius = kCornerRadius;
    viewLayer.borderWidth = 1;
    viewLayer.masksToBounds = YES;
    
    // Create gradient layer
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
    
    // Create a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [self unSelect];
}

- (void)select {
    if ([self.delegate respondsToSelector:@selector(contactBubbleWasSelected:)]){
        [self.delegate contactBubbleWasSelected:self];
    }

    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = kColorSelectedBorder.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[kColorSelectedGradientTop CGColor], (id)[kColorSelectedGradientBottom CGColor], nil];

    self.label.textColor = [UIColor whiteColor];
    
    self.isSelected = YES;
    
    [self becomeFirstResponder];
}

- (void)unSelect {
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = kColorBorder.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[kColorGradientTop CGColor], (id)[kColorGradientBottom CGColor], nil];
    
    self.label.textColor = [UIColor blackColor];

    [self setNeedsDisplay];
    self.isSelected = NO;
}

- (void)handleTapGesture {
    if (self.isSelected){
        [self unSelect];
    } else {
        [self select];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
