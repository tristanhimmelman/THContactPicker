//
//  THContactTextField.h
//  ContactPicker
//
//  Created by mysteriouss on 14-5-13.
//  Copyright (c) 2014 mysteriouss. All rights reserved.
//

@class THContactTextField;

@protocol THContactTextFieldDelegate<UITextFieldDelegate>

@optional
- (void)textFieldDidChange:(THContactTextField *)textField;
- (void)textFieldDidHitBackspaceWithEmptyText:(THContactTextField *)textField;

@end

@interface THContactTextField : UITextField

@property (nonatomic, assign) id <THContactTextFieldDelegate>delegate;

@end
