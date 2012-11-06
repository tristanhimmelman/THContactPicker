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
        
        // set colors to defaults
        self.colorGradientTop = kColorGradientTop;
        self.colorGradientBottom = kColorGradientBottom;
        self.colorBorder = kColorBorder;
        
        self.colorSelectedGradientTop = kColorSelectedGradientTop;
        self.colorSelectedGradientBottom = kColorSelectedGradientBottom;
        self.colorSelectedBorder = kColorSelectedBorder;
        
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
    
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.hidden = YES;
    [self addSubview:self.textView];
    
    // Create a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    [self adjustSize];
    
    [self unSelect];
}

- (void)adjustSize {
    // Adjust the label frames
    [self.label sizeToFit];
    CGRect frame = self.label.frame;
    frame.origin.x = kHorizontalPadding;
    frame.origin.y = kVerticalPadding;
    self.label.frame = frame;
    
    // Adjust view frame
    self.bounds = CGRectMake(0, 0, frame.size.width + 2 * kHorizontalPadding, frame.size.height + 2 * kVerticalPadding);
    
    // Create gradient layer
    if (self.gradientLayer == nil){
        self.gradientLayer = [CAGradientLayer layer];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.frame = self.bounds;

    // Round the corners
    CALayer *viewLayer = [self layer];
    viewLayer.cornerRadius = self.bounds.size.height / 2;
    viewLayer.borderWidth = 1;
    viewLayer.masksToBounds = YES;
}

- (void)setFont:(UIFont *)font {
    self.label.font = font;

    [self adjustSize];
}

- (void)select {
    if ([self.delegate respondsToSelector:@selector(contactBubbleWasSelected:)]){
        [self.delegate contactBubbleWasSelected:self];
    }

    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = self.colorSelectedBorder.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.colorSelectedGradientTop CGColor], (id)[self.colorSelectedGradientBottom CGColor], nil];

    self.label.textColor = [UIColor whiteColor];
    
    self.isSelected = YES;
    
    [self.textView becomeFirstResponder];
}

- (void)unSelect {
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = self.colorBorder.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.colorGradientTop CGColor], (id)[self.colorGradientBottom CGColor], nil];
    
    self.label.textColor = [UIColor blackColor];

    [self setNeedsDisplay];
    self.isSelected = NO;
    
    [self.textView resignFirstResponder];
}

- (void)handleTapGesture {
    if (self.isSelected){
        [self unSelect];
    } else {
        [self select];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    self.textView.hidden = NO;
    
    if ( [text isEqualToString:@"\n"] ) { // Return key was pressed
        return NO;
    }
    
    // Capture "delete" key press when cell is empty
    if ([textView.text isEqualToString:@""] && [text isEqualToString:@""]){
        if ([self.delegate respondsToSelector:@selector(contactBubbleShouldBeRemoved:)]){
            [self.delegate contactBubbleShouldBeRemoved:self];
        }
    }
    
    return YES;
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
