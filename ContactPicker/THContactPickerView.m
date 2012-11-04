//
//  ContactPickerTextView.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerView.h"
#import "THContactBubble.h"

@implementation THContactPickerView

#define kHorizontalPadding 2 // the amount of padding between contact bubbles
#define kVerticalPadding 4
#define kTextViewMinWidth 130

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self setup];
    }
    return self;
}

#pragma mark - Public functions

- (void)addContact:(NSString *)contactName {
    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:contactName];
    contactBubble.delegate = self;
    [self.selectedContacts addObject:contactBubble];
    
    [self layoutView];
    
    // clear TextView
    self.textView.text = @"";
}

- (void)removeContact:(THContactBubble *)contactBubble {
    if ([self.delegate respondsToSelector:@selector(contactPickerDidRemoveContact:)]){
        [self.delegate contactPickerDidRemoveContact:contactBubble.name];
    }
    [self.selectedContacts removeObject:contactBubble];
    
    [contactBubble removeFromSuperview];
    [self layoutView];
}

- (void)setPlaceholderString:(NSString *)placeholderString {
    self.placeholderLabel.text = placeholderString;

    [self layoutView];
}

#pragma mark - Private functions

- (void)setup {
    self.selectedContacts = [NSMutableArray array];
    
    // Create a contact bubble to determine the height of a line
    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:@"Sample"];
    self.lineHeight = contactBubble.frame.size.height + 2 * kVerticalPadding;
    
    // Create TextView
    // It would make more sense to use a UITextField however, there is no easy way to detect the "delete" key press using a UITextField
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.font = contactBubble.label.font;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.contentInset = UIEdgeInsetsMake(-11, -6, 0, 0);
    [self.textView becomeFirstResponder];
    
    // Create bottom border
    self.bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    self.bottomBorder.backgroundColor = [UIColor grayColor];
    [self addSubview:self.bottomBorder];
    // Add shadow to bottom border
    CALayer *layer = [self.bottomBorder layer];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOffset:CGSizeMake(1.0, 1.0)];
    [layer setShadowOpacity:0.5];
    [layer setShadowRadius:1.f];
    
    // Add placeholder label
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.frame.size.width, self.lineHeight)];
    self.placeholderLabel.font = contactBubble.label.font;
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.placeholderLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (void)layoutView {
    CGRect frameOfLastBubble = CGRectNull;
    int lineCount = 0;
    
    // Loop through selectedContacts and position/add them to the view
    for (THContactBubble *contactBubble in self.selectedContacts){
        CGRect bubbleFrame = contactBubble.frame;

        if (CGRectIsNull(frameOfLastBubble)){ // first line
            bubbleFrame.origin.x = kHorizontalPadding;
            bubbleFrame.origin.y = kVerticalPadding;
        } else {
            // Check if contact bubble will fit on the current line
            CGFloat width = bubbleFrame.size.width + 2 * kHorizontalPadding;
            if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - width >= 0){ // add to the same line
                // Place contact bubble just after last bubble on the same line
                bubbleFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding * 2;
                bubbleFrame.origin.y = frameOfLastBubble.origin.y;
            } else { // No space on line, jump to next line
                lineCount++;
                bubbleFrame.origin.x = kHorizontalPadding;
                bubbleFrame.origin.y = lineCount * self.lineHeight + kVerticalPadding;
            }
        }
        frameOfLastBubble = bubbleFrame;
        contactBubble.frame = bubbleFrame;
        // Add contact bubble if it hasn't been added
        if (contactBubble.superview == nil){
            [self addSubview:contactBubble];
        }
    }
    
    // Now add a textView after the comment bubbles
    CGFloat minWidth = kTextViewMinWidth + 2 * kHorizontalPadding;
    CGRect textViewFrame = CGRectMake(0, 0, self.textView.frame.size.width, self.lineHeight - 2 * kVerticalPadding);
    // Check if we can add the text field on the same line as the last contact bubble
    if (self.frame.size.width - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - minWidth >= 0){ // add to the same line
        textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - textViewFrame.origin.x;
    } else { // place text view on the next line
        lineCount++;
        if (self.selectedContacts.count == 0){
            lineCount = 0;
        }
        
        textViewFrame.origin.x = kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - 2 * kHorizontalPadding;
    }
    self.textView.frame = textViewFrame;
    self.textView.center = CGPointMake(self.textView.center.x, lineCount * self.lineHeight + self.lineHeight / 2 + kVerticalPadding);
    // Add text view if it hasn't been added 
    if (self.textView.superview == nil){
        [self addSubview:self.textView];
    }
    
    // Adjust size of view to fit all the lines
    CGRect frame = self.frame;
    CGFloat newHeight = (lineCount + 1) * self.lineHeight;
    if (frame.size.height != newHeight){
        frame.size.height = newHeight;
        self.frame = frame;
        if ([self.delegate respondsToSelector:@selector(contactPickerDidResize:)]){
            [self.delegate contactPickerDidResize:self];
        }
    }
    
    // Adjust bottom border to the bottom of the view
    CGRect borderFrame = self.bottomBorder.frame;
    borderFrame.origin.y = self.frame.size.height - 1;
    self.bottomBorder.frame = borderFrame;
    
    // Show placeholder if no there are no contacts
    if (self.selectedContacts.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark - UITextViewDelegate 

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    self.textView.hidden = NO;
    
    if ( [text isEqualToString:@"\n"] ) { // Return key was pressed
        [self addContact:self.textView.text];
        self.textView.text = @"";
        return NO;
    }
    
    // Capture "delete" key press when cell is empty
    if ([textView.text isEqualToString:@""] && [text isEqualToString:@""]){
        if (self.selectedContactBubble != nil){
            // Delete the selected contact
            [self removeContact:self.selectedContactBubble];
            self.selectedContactBubble = nil;
            self.textView.hidden = NO;
        } else {
            // If no contacts are selected, select the last contact
            self.selectedContactBubble = [self.selectedContacts lastObject];
            [self.selectedContactBubble select];
        }
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {    
    if ([self.delegate respondsToSelector:@selector(contactPickerTextViewDidChange:)]){
        [self.delegate contactPickerTextViewDidChange:textView.text];
    }
    
    if ([textView.text isEqualToString:@""] && self.selectedContacts.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark - THContactBubbleDelegate Functions

- (void)contactBubbleWasSelected:(THContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        [self.selectedContactBubble unSelect];
    }
    self.selectedContactBubble = contactBubble;
    
    self.textView.text = @"";
    self.textView.hidden = YES;
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    // Show textField
    self.textView.hidden = NO;

    // Unselect contact bubble
    [self.selectedContactBubble unSelect];
    self.selectedContactBubble = nil;
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
