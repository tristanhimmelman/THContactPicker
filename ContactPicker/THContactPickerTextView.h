//
//  ContactPickerTextView.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactBubble.h"

@protocol THContactPickerDelegate <NSObject>

- (void)contactPickerTextViewDidChange:(NSString *)textViewText;
- (void)contactPickerDidRemoveContact:(NSString *)contactName;

@end

@interface THContactPickerTextView : UIView <UITextViewDelegate, THContactBubbleDelegate>

@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, strong) THContactBubble *selectedContactBubble;
@property (nonatomic, assign) id <THContactPickerDelegate> delegate;

- (void)addContact:(NSString *)contactName;
- (void)setPlaceholderString:(NSString *)placeholderString;
    
@end
