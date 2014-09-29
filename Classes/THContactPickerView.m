//
//  ContactPickerTextView.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12, revised by mysteriouss.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerView.h"
#import "THContactBubble.h"
#import "THContactTextField.h"

@interface THContactPickerView ()<THContactTextFieldDelegate>{
    BOOL _shouldSelectTextView;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *contacts;
@property (nonatomic, strong) NSMutableArray *contactKeys;      // an ordered set of the keys placed in the contacts dictionary
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) THContactTextField *textView;
@property (nonatomic, strong) THBubbleStyle *bubbleStyle;
@property (nonatomic, strong) THBubbleStyle *bubbleSelectedStyle;

@end

@implementation THContactPickerView

#define kVerticalViewPadding        5   // the amount of padding on top and bottom of the view
#define kHorizontalPadding      0   // the amount of padding to the left and right of each contact bubble
#define kHorizontalSidePadding  10  // the amount of padding on the left and right of the view
#define kVerticalPadding        2   // amount of padding above and below each contact bubble
#define kTextViewMinWidth       20  // minimum width of trailing text view

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self setup];
    }
    return self;
}

- (void)setup {
    self.verticalPadding = kVerticalViewPadding;
    
    self.contacts = [NSMutableDictionary dictionary];
    self.contactKeys = [NSMutableArray array];
    
    // Create a contact bubble to determine the height of a line
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.scrollView];
    
    // Add placeholder label
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.placeholderLabel];
    
    self.promptLabel = [[UILabel alloc] init];
    self.promptLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.text = nil;
    [self.promptLabel sizeToFit];
    [self.scrollView addSubview:self.promptLabel];
    
    // Create TextView
    self.textView = [[THContactTextField alloc] init];
    self.textView.delegate = self;
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    [self selectTextView];
    
    // Add shadow to bottom border
    self.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    //default settings
    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:@""];
    self.bubbleStyle = contactBubble.style;
    self.bubbleSelectedStyle = contactBubble.selectedStyle;
    self.font = contactBubble.label.font;
}

#pragma mark - Public functions

- (void)setFont:(UIFont *)font {
    _font = font;
    // Create a contact bubble to determine the height of a line
    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:@"Sample"];
    [contactBubble setFont:font];
    self.lineHeight = contactBubble.frame.size.height + 2 * kVerticalPadding;
    
    self.textView.font = font;
    [self.textView sizeToFit];
    
    self.promptLabel.font = font;
    self.placeholderLabel.font = font;
    [self updateLabelFrames];
}

- (void)setPromptLabelText:(NSString *)text {
    self.promptLabel.text = text;
    
    [self updateLabelFrames];
    [self layoutView];
}

- (void)setPlaceholderLabelTextColor:(UIColor *)color{
    self.placeholderLabel.textColor = color;
}

- (void)setPromptLabelTextColor:(UIColor *)color{
    self.promptLabel.textColor = color;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.scrollView.backgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

- (void)addContact:(id)contact withName:(NSString *)name {
    id contactKey = [NSValue valueWithNonretainedObject:contact];
    if ([self.contactKeys containsObject:contactKey]){
        NSLog(@"Cannot add the same object twice to ContactPickerView");
        return;
    }
    
    if (self.contactKeys.count == 1 && self.limitToOne){
        THContactBubble *contactBubble = [self.contacts objectForKey:[self.contactKeys firstObject]];
        [self removeContactBubble:contactBubble];
    }
    
    self.textView.text = @"";
    
    THContactBubble *contactBubble = [[THContactBubble alloc] initWithName:name style:self.bubbleStyle selectedStyle:self.bubbleSelectedStyle showComma:!self.limitToOne];
    contactBubble.maxWidth = self.frame.size.width - self.promptLabel.frame.origin.x - 2 * kHorizontalPadding - 2 * kHorizontalSidePadding;
    contactBubble.minWidth = kTextViewMinWidth + 2 * kHorizontalPadding;
    contactBubble.keyboardAppearance = self.keyboardAppearance;
    if (self.font != nil){
        [contactBubble setFont:self.font];
    }
    contactBubble.delegate = self;
    [self.contacts setObject:contactBubble forKey:contactKey];
    [self.contactKeys addObject:contactKey];
    
    if (self.selectedContactBubble){
        [self.selectedContactBubble unSelect];
        [self selectTextView];
    }
    
    // update layout
    [self layoutView];
    
    // scroll to bottom
    _shouldSelectTextView = YES;
    [self scrollToBottomWithAnimation:YES];
    // after scroll animation [self selectTextView] will be called
}

- (void)selectTextView {
    self.textView.hidden = NO;
    [self.textView becomeFirstResponder];
}

- (void)removeAllContacts {
    for (id contact in [self.contacts allKeys]){
      THContactBubble *contactBubble = [self.contacts objectForKey:contact];
      [contactBubble removeFromSuperview];
    }
    [self.contacts removeAllObjects];
    [self.contactKeys removeAllObjects];
  
    // update layout
    [self layoutView];
  
    self.textView.hidden = NO;
    self.textView.text = @"";
}

- (void)removeContact:(id)contact {
    id contactKey = [NSValue valueWithNonretainedObject:contact];
    
    // Remove contactBubble from view
    THContactBubble *contactBubble = [self.contacts objectForKey:contactKey];
    [contactBubble removeFromSuperview];
    
    // Remove contact from memory
    [self.contacts removeObjectForKey:contactKey];
    [self.contactKeys removeObject:contactKey];
    
    // update layout
    [self layoutView];

    [self selectTextView];
    self.textView.text = @"";
    
    [self scrollToBottomWithAnimation:NO];
}

- (void)setPlaceholderLabelText:(NSString *)text {
    self.placeholderLabel.text = text;

    [self layoutView];
}

- (void)resignFirstResponder {
    [self.textView resignFirstResponder];
}

- (void)setVerticalPadding:(CGFloat)viewPadding {
    _verticalPadding = viewPadding;

    [self layoutView];
}

- (void)setBubbleStyle:(THBubbleStyle *)style selectedStyle:(THBubbleStyle *)selectedStyle {
    self.bubbleStyle = style;
    self.textView.textColor = style.textColor;
    self.bubbleSelectedStyle = selectedStyle;

    for (id contactKey in self.contactKeys){
        THContactBubble *contactBubble = (THContactBubble *)[self.contacts objectForKey:contactKey];

        contactBubble.style = style;
        contactBubble.selectedStyle = selectedStyle;

        // this stuff reloads bubble
        if (contactBubble.isSelected){
            [contactBubble select];
        } else {
            [contactBubble unSelect];
        }
    }
}

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

#pragma mark - Private functions

- (void)scrollToBottomWithAnimation:(BOOL)animated {
    if (animated){
        CGSize size = self.scrollView.contentSize;
        CGRect frame = CGRectMake(0, size.height - self.scrollView.frame.size.height, size.width, self.scrollView.frame.size.height);
        
        [self.scrollView scrollRectToVisible:frame animated:animated];
    } else {
        // this block is here because scrollRectToVisible with animated NO causes crashes on iOS 5 when the user tries to delete many contacts really quickly
        CGPoint offset = self.scrollView.contentOffset;
        offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
        self.scrollView.contentOffset = offset;
    }
}

- (void)removeContactBubble:(THContactBubble *)contactBubble {
    id contact = [self contactForContactBubble:contactBubble];
    
    if (contact == nil){
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(contactPickerDidRemoveContact:)]){
        [self.delegate contactPickerDidRemoveContact:[contact nonretainedObjectValue]];
    }
    
    [self removeContactByKey:contact];
}

- (void)removeContactByKey:(id)contactKey {
    // Remove contactBubble from view
    THContactBubble *contactBubble = [self.contacts objectForKey:contactKey];
    [contactBubble removeFromSuperview];
  
    // Remove contact from memory
    [self.contacts removeObjectForKey:contactKey];
    [self.contactKeys removeObject:contactKey];
  
    // update layout
    [self layoutView];
  
    [self selectTextView];
    self.textView.text = @"";
  
    [self scrollToBottomWithAnimation:NO];
}

- (id)contactForContactBubble:(THContactBubble *)contactBubble {
    NSArray *keys = [self.contacts allKeys];
    
    for (id contact in keys){
        if ([[self.contacts objectForKey:contact] isEqual:contactBubble]){
            return contact;
        }
    }
    return nil;
}

- (void)updateLabelFrames {
    [self.promptLabel sizeToFit];
    self.promptLabel.frame = CGRectMake(kHorizontalSidePadding, self.verticalPadding, self.promptLabel.frame.size.width, self.lineHeight);
    self.placeholderLabel.frame = CGRectMake([self firstLineXOffset] + 3, self.verticalPadding, self.frame.size.width, self.lineHeight);
}

- (CGFloat)firstLineXOffset {
    if (self.promptLabel.text == nil){
        return kHorizontalSidePadding;
    } else {
        return self.promptLabel.frame.origin.x + self.promptLabel.frame.size.width + 1;
    }
}

- (void)layoutView {
    CGRect frameOfLastBubble = CGRectNull;
    int lineCount = 0;
    
    // Loop through selectedContacts and position/add them to the view
    for (id contactKey in self.contactKeys){
        THContactBubble *contactBubble = (THContactBubble *)[self.contacts objectForKey:contactKey];
        CGRect bubbleFrame = contactBubble.frame;
        
        if (CGRectIsNull(frameOfLastBubble)){ // first line
            bubbleFrame.origin.x = [self firstLineXOffset];
            bubbleFrame.origin.y = kVerticalPadding + self.verticalPadding;
        } else {
            // Check if contact bubble will fit on the current line
            CGFloat width = bubbleFrame.size.width + 2 * kHorizontalPadding;
            if (self.frame.size.width - kHorizontalSidePadding - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - width >= 0){ // add to the same line
                                                                                                                 // Place contact bubble just after last bubble on the same line
                bubbleFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding * 2;
                bubbleFrame.origin.y = frameOfLastBubble.origin.y;
            } else { // No space on line, jump to next line
                lineCount++;
                bubbleFrame.origin.x = kHorizontalSidePadding;
                bubbleFrame.origin.y = (lineCount * self.lineHeight) + kVerticalPadding + 	self.verticalPadding;
            }
        }
        frameOfLastBubble = bubbleFrame;
        contactBubble.frame = bubbleFrame;
        
        // Add contact bubble if it hasn't been added
        if (contactBubble.superview == nil){
            [self.scrollView addSubview:contactBubble];
        }
    }
    
    // Now add a textView after the comment bubbles
    CGFloat minWidth = kTextViewMinWidth + 2 * kHorizontalPadding;
    CGFloat textViewHeight = self.lineHeight - 2 * kVerticalPadding;
    CGRect textViewFrame = CGRectMake(0, 0, self.textView.frame.size.width, textViewHeight);

    // Check if we can add the text field on the same line as the last contact bubble
    if (self.frame.size.width - kHorizontalSidePadding - frameOfLastBubble.origin.x - frameOfLastBubble.size.width - minWidth >= 0){ // add to the same line
        textViewFrame.origin.x = frameOfLastBubble.origin.x + frameOfLastBubble.size.width + kHorizontalPadding;
        textViewFrame.size.width = self.frame.size.width - textViewFrame.origin.x;
    } else { // place text view on the next line
        lineCount++;
        
        textViewFrame.origin.x = kHorizontalSidePadding;
        textViewFrame.size.width = self.frame.size.width - 2 * kHorizontalPadding;
        
        if (self.contacts.count == 0){
            lineCount = 0;
            textViewFrame.origin.x = [self firstLineXOffset];
            textViewFrame.size.width = self.bounds.size.width - textViewFrame.origin.x;
        }
    }
    
    textViewFrame.origin.y = lineCount * self.lineHeight + kVerticalPadding + self.verticalPadding;
    self.textView.frame = textViewFrame;

    // Add text view if it hasn't been added
    self.textView.center = CGPointMake(self.textView.center.x, lineCount * self.lineHeight + textViewHeight / 2 + kVerticalPadding + self.verticalPadding);

    if (self.textView.superview == nil){
        [self.scrollView addSubview:self.textView];
    }
    
    // Hide the text view if we are limiting number of selected contacts to 1 and a contact has already been added
    if (self.limitToOne && self.contacts.count >= 1){
        self.textView.hidden = YES;
        lineCount = 0;
    }
    
    // Adjust scroll view content size
    CGRect frame = self.bounds;
    CGFloat maxFrameHeight = 2 * self.lineHeight + 2 * self.verticalPadding; // limit frame to two lines of content
    CGFloat newHeight = (lineCount + 1) * self.lineHeight + 2 * self.verticalPadding;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, newHeight);
    
    // Adjust frame of view if necessary
    newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
    if (self.frame.size.height != newHeight){
        // Adjust self height
        CGRect selfFrame = self.frame;
        selfFrame.size.height = newHeight;
        self.frame = selfFrame;
        
        // Adjust scroll view height
        frame.size.height = newHeight;
        self.scrollView.frame = frame;
        
        if ([self.delegate respondsToSelector:@selector(contactPickerDidResize:)]){
            [self.delegate contactPickerDidResize:self];
        }
    }
    
    // Show placeholder if no there are no contacts
    if (self.contacts.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
}

#pragma mark - THContactTextFieldDelegate

- (void)textFieldDidHitBackspaceWithEmptyText:(THContactTextField *)textView {
    self.textView.hidden = NO;
    
    if (self.contacts.count) {
        // Capture "delete" key press when cell is empty
        self.selectedContactBubble = [self.contacts objectForKey:[self.contactKeys lastObject]];
        [self.selectedContactBubble select];
    } else {
        if ([self.delegate respondsToSelector:@selector(contactPickerTextViewDidChange:)]){
            [self.delegate contactPickerTextViewDidChange:textView.text];
        }
    }
}

- (void)textFieldDidChange:(THContactTextField *)textView{
    if ([self.delegate respondsToSelector:@selector(contactPickerTextViewDidChange:)]){
        [self.delegate contactPickerTextViewDidChange:textView.text];
    }
    
    if ([textView.text isEqualToString:@""] && self.contacts.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
    
    CGPoint offset = self.scrollView.contentOffset;
    offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
    if (offset.y > self.scrollView.contentOffset.y){
        [self scrollToBottomWithAnimation:YES];
    }
}

#pragma mark - THContactBubbleDelegate Functions

- (void)contactBubbleWasSelected:(THContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        [self.selectedContactBubble unSelect];
    }
    self.selectedContactBubble = contactBubble;
    
    [self.textView resignFirstResponder];
    self.textView.text = @"";
    self.textView.hidden = YES;
}

- (void)contactBubbleWasUnSelected:(THContactBubble *)contactBubble {
    if (self.selectedContactBubble != nil){
        
    }
    [self selectTextView];
    self.textView.text = @"";
}

- (void)contactBubbleShouldBeRemoved:(THContactBubble *)contactBubble {
    [self removeContactBubble:contactBubble];
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    if (self.limitToOne && self.contactKeys.count == 1){
        return;
    }
    [self scrollToBottomWithAnimation:YES];
    
    // Show textField
    [self selectTextView];
    
    // Unselect contact bubble
    [self.selectedContactBubble unSelect];
    self.selectedContactBubble = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_shouldSelectTextView){
        _shouldSelectTextView = NO;
        [self selectTextView];
    }
}

#pragma mark - UITextInputTraits

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    self.textView.keyboardAppearance = keyboardAppearance;
    for (THContactBubble *bubble in self.contacts) {
        bubble.keyboardAppearance = keyboardAppearance;
    }
}

- (UIKeyboardAppearance)keyboardAppearance {
    return self.textView.keyboardAppearance;
}

@end
