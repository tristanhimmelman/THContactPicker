//
//  THContactTextField.m
//  ContactPicker
//
//  Created by mysteriouss on 14-5-13.
//  Copyright (c) 2014 mysteriouss. All rights reserved.
//

#import "THContactTextField.h"

@implementation THContactTextField

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deleteBackward {
    BOOL isTextFieldEmpty = (self.text.length == 0);
    if (isTextFieldEmpty){
        if ([self.delegate respondsToSelector:@selector(textFieldDidHitBackspaceWithEmptyText:)]){
            [self.delegate textFieldDidHitBackspaceWithEmptyText:self];
        }
    }
    [super deleteBackward];
}

- (void)textFieldTextDidChange:(NSNotification *)notification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidChange:)]){
        [self.delegate textFieldDidChange:self];
    }
}

@end
