//
//  THContactPickerView.m
//  THContactPickerView
//
//  Created by Tristan Himmelman on 11/2/12, revised by mysteriouss.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerView.h"
#import "THContactView.h"
#import "THContactTextField.h"

@interface THContactPickerView ()<THContactTextFieldDelegate>{
    BOOL _shouldSelectTextField;
	int _lineCount;
	CGRect _frameOfLastView;
	CGFloat _contactHorizontalPadding;
	BOOL _showComma;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *contacts;	// Dictionary to store THContactViews for each contacts
@property (nonatomic, strong) NSMutableArray *contactKeys;      // an ordered set of the keys placed in the contacts dictionary
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) THContactTextField *textField;
@property (nonatomic, strong) THContactViewStyle *contactViewStyle;
@property (nonatomic, strong) THContactViewStyle *contactViewSelectedStyle;

@end

@implementation THContactPickerView

#define kVerticalViewPadding				5   // the amount of padding on top and bottom of the view
#define kHorizontalPadding					0   // the amount of padding to the left and right of each contact view
#define kHorizontalPaddingWithBackground	2   // the amount of padding to the left and right of each contact view (when bubbles have a non white background)
#define kHorizontalSidePadding				10  // the amount of padding on the left and right of the view
#define kVerticalPadding					2   // amount of padding above and below each contact view
#define kTextFieldMinWidth					20  // minimum width of trailing text view
#define KMaxNumberOfLinesDefault			2

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self setup];
    }
    return self;
}

- (void)setup {
    self.verticalPadding = kVerticalViewPadding;
	self.maxNumberOfLines = KMaxNumberOfLinesDefault;
	
    self.contacts = [NSMutableDictionary dictionary];
    self.contactKeys = [NSMutableArray array];
    
    // Create a contact view to determine the height of a line
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
    
    // Create TextField
    self.textField = [[THContactTextField alloc] init];
    self.textField.delegate = self;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    //default settings
    THContactView *contactView = [[THContactView alloc] initWithName:@""];
    self.contactViewStyle = contactView.style;
    self.contactViewSelectedStyle = contactView.selectedStyle;
    self.font = contactView.label.font;
}

#pragma mark - Public functions

- (void)setFont:(UIFont *)font {
    _font = font;
	
    // Create a contact view to determine the height of a line
    THContactView *contactView = [[THContactView alloc] initWithName:@"Sample"];
    [contactView setFont:font];
    self.lineHeight = contactView.frame.size.height + 2 * kVerticalPadding;
    
    self.textField.font = font;
    [self.textField sizeToFit];
    
    self.promptLabel.font = font;
    self.placeholderLabel.font = font;
    [self updateLabelFrames];
	
	[self setNeedsLayout];
}

- (void)setPromptLabelText:(NSString *)text {
    self.promptLabel.text = text;
    [self updateLabelFrames];
	
    [self setNeedsLayout];
}

- (void)setPromptLabelAttributedText:(NSAttributedString *)attributedText {
    self.promptLabel.attributedText = attributedText;
    [self updateLabelFrames];
    [self setNeedsLayout];
}

- (void)setPlaceholderLabelTextColor:(UIColor *)color{
    self.placeholderLabel.textColor = color;
}

- (void)setPromptLabelTextColor:(UIColor *)color{
    self.promptLabel.textColor = color;
}

- (void)setPromptTintColor:(UIColor *)color{
    self.textField.tintColor = color;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.scrollView.backgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

- (void)addContact:(id)contact withName:(NSString *)name {
	[self addContact:contact withName:name withStyle:self.contactViewStyle andSelectedStyle:self.contactViewSelectedStyle];
}

- (void)addContact:(id)contact withName:(NSString *)name withStyle:(THContactViewStyle *)bubbleStyle andSelectedStyle:(THContactViewStyle *)selectedStyle {
    id contactKey = [NSValue valueWithNonretainedObject:contact];
    if ([self.contactKeys containsObject:contactKey]){
        NSLog(@"Cannot add the same object twice to ContactPickerView");
        return;
    }
    
    if (self.contactKeys.count == 1 && self.limitToOne){
        THContactView *contactView = [self.contacts objectForKey:[self.contactKeys firstObject]];
        [self removeContactView:contactView];
    }
    
    self.textField.text = @"";
	
	if ([bubbleStyle hasNonWhiteBackground]){
		_contactHorizontalPadding = kHorizontalPaddingWithBackground;
		_showComma = NO;
	} else {
		_contactHorizontalPadding = kHorizontalPadding;
		_showComma = !self.limitToOne;
	}
	
    THContactView *contactView = [[THContactView alloc] initWithName:name style:bubbleStyle selectedStyle:selectedStyle showComma:_showComma];
    contactView.maxWidth = self.frame.size.width - self.promptLabel.frame.origin.x - 2 * _contactHorizontalPadding - 2 * kHorizontalSidePadding;
    contactView.minWidth = kTextFieldMinWidth + 2 * _contactHorizontalPadding;
    contactView.keyboardAppearance = self.keyboardAppearance;
    contactView.returnKeyType = self.returnKeyType;
    contactView.delegate = self;
    [contactView setFont:self.font];
    
    [self.contacts setObject:contactView forKey:contactKey];
    [self.contactKeys addObject:contactKey];
    
    if (self.selectedContactView){
        // if there is a selected contact, deselect it
        [self.selectedContactView unSelect];
        self.selectedContactView = nil;
        [self selectTextField];
    }
    
    // update the position of the contacts
    [self layoutContactViews];
    
    // update size of the scrollView
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutScrollView];
    } completion:^(BOOL finished) {
        // scroll to bottom
        _shouldSelectTextField = [self isFirstResponder];
        [self scrollToBottomWithAnimation:YES];
        // after scroll animation [self selectTextField] will be called
    }];
}

- (void)selectTextField {
    self.textField.hidden = NO;
    [self.textField becomeFirstResponder];
}

- (void)removeAllContacts {
    for (id contact in [self.contacts allKeys]){
      THContactView *contactView = [self.contacts objectForKey:contact];
      [contactView removeFromSuperview];
    }
    [self.contacts removeAllObjects];
    [self.contactKeys removeAllObjects];
  
    // update layout
    [self setNeedsLayout];
  
    self.textField.hidden = NO;
    self.textField.text = @"";
}

- (void)removeContact:(id)contact {
    id contactKey = [NSValue valueWithNonretainedObject:contact];
	[self removeContactByKey:contactKey];
}

- (void)setPlaceholderLabelText:(NSString *)text {
    self.placeholderLabel.text = text;

    [self setNeedsLayout];
}

- (BOOL)resignFirstResponder {
    if ([self.textField isFirstResponder])
    {
        return [self.textField resignFirstResponder];
    }
    return [super resignFirstResponder];
}

- (BOOL)isFirstResponder {
	if ([self.textField isFirstResponder]){
		return YES;
	} else if (self.selectedContactView != nil){
		return YES;
	}
	return NO;
}

- (void)setVerticalPadding:(CGFloat)viewPadding {
    _verticalPadding = viewPadding;

    [self setNeedsLayout];
}

- (void)setContactViewStyle:(THContactViewStyle *)style selectedStyle:(THContactViewStyle *)selectedStyle {
    self.contactViewStyle = style;
    self.textField.textColor = style.textColor;
    self.contactViewSelectedStyle = selectedStyle;

    for (id contactKey in self.contactKeys){
        THContactView *contactView = (THContactView *)[self.contacts objectForKey:contactKey];

        contactView.style = style;
        contactView.selectedStyle = selectedStyle;

        // this stuff reloads view
        if (contactView.isSelected){
            [contactView select];
        } else {
            [contactView unSelect];
        }
    }
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
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

- (void)removeContactView:(THContactView *)contactView {
    id contact = [self contactForContactView:contactView];
    
    if (contact == nil){
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(contactPicker:didRemoveContact:)]){
        [self.delegate contactPicker:self didRemoveContact:[contact nonretainedObjectValue]];
    }
    
    [self removeContactByKey:contact];
    [self selectTextField];

    if (self.selectedContactView == contactView) {
        self.selectedContactView = nil;
    }
}

- (void)removeContactByKey:(id)contactKey {
    // Remove contactView from view
    THContactView *contactView = [self.contacts objectForKey:contactKey];
    [contactView removeFromSuperview];
  
    // Remove contact from memory
    [self.contacts removeObjectForKey:contactKey];
    [self.contactKeys removeObject:contactKey];

	self.textField.text = @"";

	// update layout
	[self layoutContactViews];
	
	// animate resizing of view
	[UIView animateWithDuration:0.2 animations:^{
		[self layoutScrollView];
	} completion:^(BOOL finished) {
		[self scrollToBottomWithAnimation:NO];
	}];
}

- (id)contactForContactView:(THContactView *)contactView {
    NSArray *keys = [self.contacts allKeys];
    
    for (id contact in keys){
        if ([[self.contacts objectForKey:contact] isEqual:contactView]){
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

- (void)layoutContactViews {
	_frameOfLastView = CGRectNull;
	_lineCount = 0;
	
	// Loop through contacts and position/add them to the view
	for (id contactKey in self.contactKeys){
		THContactView *contactView = (THContactView *)[self.contacts objectForKey:contactKey];
		CGRect contactViewFrame = contactView.frame;
		
		if (CGRectIsNull(_frameOfLastView)){
			// First contact view
			contactViewFrame.origin.x = [self firstLineXOffset];
			contactViewFrame.origin.y = kVerticalPadding + self.verticalPadding;
		} else {
			// Check if contact view will fit on the current line
			CGFloat width = contactViewFrame.size.width + 2 * _contactHorizontalPadding;
			if (self.frame.size.width - kHorizontalSidePadding - _frameOfLastView.origin.x - _frameOfLastView.size.width - width >= 0){
				// add to the same line
				// Place contact view just after last contact view on the same line
				contactViewFrame.origin.x = _frameOfLastView.origin.x + _frameOfLastView.size.width + _contactHorizontalPadding * 2;
				contactViewFrame.origin.y = _frameOfLastView.origin.y;
			} else {
				// No space on current line, jump to next line
				_lineCount++;
				contactViewFrame.origin.x = kHorizontalSidePadding;
				contactViewFrame.origin.y = (_lineCount * self.lineHeight) + kVerticalPadding + self.verticalPadding;
			}
		}
		_frameOfLastView = contactViewFrame;
		contactView.frame = contactViewFrame;
		
		// Add contact view if it hasn't been added
		if (contactView.superview == nil){
			[self.scrollView addSubview:contactView];
		}
	}
	
	// Now add the textField after the contact views
	CGFloat minWidth = kTextFieldMinWidth + 2 * _contactHorizontalPadding;
	CGFloat textFieldHeight = self.lineHeight - 2 * kVerticalPadding;
	CGRect textFieldFrame = CGRectMake(0, 0, self.textField.frame.size.width, textFieldHeight);
	
	// Check if we can add the text field on the same line as the last contact view
	if (self.frame.size.width - kHorizontalSidePadding - _frameOfLastView.origin.x - _frameOfLastView.size.width - minWidth >= 0){ // add to the same line
		textFieldFrame.origin.x = _frameOfLastView.origin.x + _frameOfLastView.size.width + _contactHorizontalPadding;
		textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x;
	} else {
		// place text view on the next line
		_lineCount++;
		
		textFieldFrame.origin.x = kHorizontalSidePadding;
		textFieldFrame.size.width = self.frame.size.width - 2 * _contactHorizontalPadding;
		
		if (self.contacts.count == 0){
			_lineCount = 0;
			textFieldFrame.origin.x = [self firstLineXOffset];
			textFieldFrame.size.width = self.bounds.size.width - textFieldFrame.origin.x;
		}
	}
	
	textFieldFrame.origin.y = _lineCount * self.lineHeight + kVerticalPadding + self.verticalPadding;
	self.textField.frame = textFieldFrame;
	
	// Add text view if it hasn't been added
	self.textField.center = CGPointMake(self.textField.center.x, _lineCount * self.lineHeight + textFieldHeight / 2 + kVerticalPadding + self.verticalPadding);
	
	if (self.textField.superview == nil){
		[self.scrollView addSubview:self.textField];
	}
	
	// Hide the text view if we are limiting number of selected contacts to 1 and a contact has already been added
	if (self.limitToOne && self.contacts.count >= 1){
		self.textField.hidden = YES;
		_lineCount = 0;
	}
	
	// Show placeholder if no there are no contacts
    if ([self.textField.text isEqualToString:@""] && self.contacts.count == 0 ){
		self.placeholderLabel.hidden = NO;
	} else {
		self.placeholderLabel.hidden = YES;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self layoutContactViews];
	
	[self layoutScrollView];
}

- (void)layoutScrollView {
	// Adjust scroll view content size
	CGRect frame = self.bounds;
	CGFloat maxFrameHeight = self.maxNumberOfLines * self.lineHeight + 2 * self.verticalPadding; // limit frame to two lines of content
	CGFloat newHeight = (_lineCount + 1) * self.lineHeight + 2 * self.verticalPadding;
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
}

#pragma mark - THContactTextFieldDelegate

- (void)textFieldDidHitBackspaceWithEmptyText:(THContactTextField *)textField {
    self.textField.hidden = NO;
    
    if (self.contacts.count) {
        // Capture "delete" key press when cell is empty
        self.selectedContactView = [self.contacts objectForKey:[self.contactKeys lastObject]];
        [self.selectedContactView select];
    } else {
        if ([self.delegate respondsToSelector:@selector(contactPicker:textFieldDidChange:)]){
            [self.delegate contactPicker:self textFieldDidChange:textField];
        }
    }
}

- (void)textFieldDidChange:(THContactTextField *)textField {
    if ([self.delegate respondsToSelector:@selector(contactPicker:textFieldDidChange:)]
        && !self.textField.markedTextRange) {
        [self.delegate contactPicker:self textFieldDidChange:textField];
    }

    if ([textField.text isEqualToString:@""] && self.contacts.count == 0){
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([self.delegate respondsToSelector:@selector(contactPicker:textFieldShouldReturn:)]){
		return [self.delegate contactPicker:self textFieldShouldReturn:textField];
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
   	if ([self.delegate respondsToSelector:@selector(contactPicker:textFieldDidBeginEditing:)]){
        [self.delegate contactPicker:self textFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   	if ([self.delegate respondsToSelector:@selector(contactPicker:textFieldDidEndEditing:)]){
        [self.delegate contactPicker:self textFieldDidEndEditing:textField];
    }
}

#pragma mark - THContactViewDelegate Functions

- (void)contactViewWasSelected:(THContactView *)contactView {
    if (self.selectedContactView != nil){
        [self.selectedContactView unSelect];
    }
    self.selectedContactView = contactView;
    
    id contact = [self contactForContactView:contactView];
    if ([self.delegate respondsToSelector:@selector(contactPicker:didSelectContact:)]){
        [self.delegate contactPicker:self didSelectContact:[contact nonretainedObjectValue]];
    }
    
    [self.textField resignFirstResponder];
    self.textField.text = @"";
    self.textField.hidden = YES;
}

- (void)contactViewWasUnSelected:(THContactView *)contactView {
    if (self.selectedContactView == contactView){
        self.selectedContactView = nil;
    }

    [self selectTextField];
	// transfer the text fromt he textField within the ContactView if there was any
	// ***This is important if the user starts to type when a contact view is selected
    self.textField.text = contactView.textField.text;

	// trigger textFieldDidChange if there is text in the textField
	if (self.textField.text.length > 0){
		[self textFieldDidChange:self.textField];
	}
}

- (void)contactViewShouldBeRemoved:(THContactView *)contactView {
    [self removeContactView:contactView];
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    if (self.limitToOne && self.contactKeys.count == 1){
        return;
    }
    [self scrollToBottomWithAnimation:YES];
    
    // Show textField
    [self selectTextField];
    
    // Unselect contact view
    [self.selectedContactView unSelect];
    self.selectedContactView = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_shouldSelectTextField){
        _shouldSelectTextField = NO;
        [self selectTextField];
    }
}

#pragma mark - UITextInputTraits

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    self.textField.keyboardAppearance = keyboardAppearance;
    for (THContactView *contactView in self.contacts) {
        contactView.keyboardAppearance = keyboardAppearance;
    }
}

- (UIKeyboardAppearance)keyboardAppearance {
    return self.textField.keyboardAppearance;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    self.textField.returnKeyType = returnKeyType;
    for (THContactView *contactView in self.contacts) {
        contactView.returnKeyType = returnKeyType;
    }
}

- (UIReturnKeyType)returnKeyType {
    return self.textField.returnKeyType;
}

@end
