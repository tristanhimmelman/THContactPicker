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

#define kBubbleColor                      [UIColor colorWithRed:24.0/255.0 green:134.0/255.0 blue:242.0/255.0 alpha:1.0]
#define kBubbleColorSelected              [UIColor colorWithRed:151.0/255.0f green:199.0/255.0f blue:250.0/255.0f alpha:1.0]

- (id)initWithName:(NSString *)name {
    if ([self initWithName:name color:nil selectedColor:nil]) {

    }
    return self;
}

- (id)initWithName:(NSString *)name color:(THBubbleColor *)color selectedColor:(THBubbleColor *)selectedColor {
    self = [super init];
    if (self){
        self.name = name;
        self.isSelected = NO;

        if (color == nil){
            color = [[THBubbleColor alloc] initWithGradientTop:kBubbleColor gradientBottom:kBubbleColor border:kBubbleColor];
        }

        if (selectedColor == nil){
            selectedColor = [[THBubbleColor alloc] initWithGradientTop:kBubbleColorSelected gradientBottom:kBubbleColorSelected border:kBubbleColorSelected];
        }
        
        self.color = color;
        self.selectedColor = selectedColor;

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
    viewLayer.borderColor = self.selectedColor.border.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.selectedColor.gradientTop CGColor], (id)[self.selectedColor.gradientBottom CGColor], nil];

    self.label.textColor = [UIColor whiteColor];
    
    self.isSelected = YES;
    
    [self.textView becomeFirstResponder];
}

- (void)unSelect {
    CALayer *viewLayer = [self layer];
    viewLayer.borderColor = self.color.border.CGColor;
    
    self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[self.color.gradientTop CGColor], (id)[self.color.gradientBottom CGColor], nil];
    
    self.label.textColor = [UIColor whiteColor];

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
    
    if (self.isSelected){
        self.textView.text = @"";
        [self unSelect];
        if ([self.delegate respondsToSelector:@selector(contactBubbleWasUnSelected:)]){
            [self.delegate contactBubbleWasUnSelected:self];
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
