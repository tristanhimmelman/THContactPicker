//
//  THContactViewStyle.m
//  ContactPicker
//
//  Created by Dmitry Vorobjov on 12/6/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactViewStyle.h"

@implementation THContactViewStyle

- (id)initWithTextColor:(UIColor *)textColor
		backgroundColor:(UIColor *)backgroundColor
	 cornerRadiusFactor:(CGFloat)cornerRadiusFactor {

	return [self initWithTextColor:textColor gradientTop:backgroundColor gradientBottom:backgroundColor borderColor:backgroundColor borderWidth:0 cornerRadiusFactor:cornerRadiusFactor];
}

- (id)initWithTextColor:(UIColor *)textColor
            gradientTop:(UIColor *)gradientTop
         gradientBottom:(UIColor *)gradientBottom
            borderColor:(UIColor *)borderColor
            borderWidth:(CGFloat)borderWidth
     cornerRadiusFactor:(CGFloat)cornerRadiusFactor {
    
    if (self = [super init]) {
        self.textColor = textColor;
        self.gradientTop = gradientTop;
        self.gradientBottom = gradientBottom;
        self.borderColor = borderColor;
        self.borderWidth = borderWidth;
        self.cornerRadiusFactor = cornerRadiusFactor;
    }
	
    return self;
}

- (BOOL)hasNonWhiteBackground {
	if (self.gradientTop == nil || self.gradientTop == [UIColor whiteColor] || self.gradientTop == [UIColor clearColor]){
		return NO;
	}
	return YES;
}

@end
