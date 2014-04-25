//
//  THBubbleColor.m
//  ContactPicker
//
//  Created by Dmitry Vorobjov on 12/6/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THBubbleStyle.h"

@implementation THBubbleStyle

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

@end
