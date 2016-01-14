THContactPicker
===============
[![CocoaPods](https://img.shields.io/cocoapods/v/THContactPicker.svg)](https://github.com/tristanhimmelman/THContactPicker)

THContactPicker is an iOS view used for selecting contacts. It is built to mimic the contact selecting functionality in the iOS Mail app. It also supports customization for different styling requirements. 

![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/THContactPicker/master/screenshot.png)
![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/THContactPicker/master/example.gif)

##Installation
THContactPicker can be added to your project manually or using Cocoapods:
```
pod 'THContactPicker', '~> 2.0'
```

##Usage
The view can be added using interface builder or programmatically. Here is an example of adding it programmatically:
```objective-c
self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
[self.contactPickerView setPlaceholderLabelText:@"Who would you like to message?"];
self.contactPickerView.delegate = self;
[self.view addSubview:self.contactPickerView];
```

Adding and removing contacts from the view is done with these two functions:
```objective-c
- (void)addContact:(id)contact withName:(NSString *)name;
- (void)removeContact:(id)contact;
```

THContactPickerView defines the following delegate protocol to make it easy for you views to respond to any changes:
```objective-c
@protocol THContactPickerDelegate <NSObject>

@optional
- (void)contactPickerDidResize:(THContactPickerView *)contactPicker;
- (void)contactPicker:(THContactPickerView *)contactPicker didSelectContact:(id)contact;
- (void)contactPicker:(THContactPickerView *)contactPicker didRemoveContact:(id)contact;
- (void)contactPicker:(THContactPickerView *)contactPicker textFieldDidBeginEditing:(UITextField *)textField;
- (void)contactPicker:(THContactPickerView *)contactPicker textFieldDidEndEditing:(UITextField *)textField;
- (BOOL)contactPicker:(THContactPickerView *)contactPicker textFieldShouldReturn:(UITextField *)textField;
- (void)contactPicker:(THContactPickerView *)contactPicker textFieldDidChange:(UITextField *)textField;

@end
```

##Customization:

Set the text that is displayed in the view when there are no selected contacts:
```objective-c
- (void)setPlaceholderLabelText:(NSString *)text;
```

Set the text for the Preceding prompt label. If not set, the label will not be displayed:
```objective-c
- (void)setPromptLabelText:(NSString *)text;	
```

Change the font of all elements in the view:
```objective-c
- (void)setFont:(UIFont *)font;
```

Set the style of the contacts item for default and selected states:
```objective-c
- (void)setContactViewStyle:(THContactViewStyle *)color selectedStyle:(THContactViewStyle *)selectedColor;
```
THContactViewStyle defines the look of each contact item. The following attributes can be modified: text label color, top gradient color, bottom gradient color, border color, border width and corner radius factor. For example:
![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/THContactPicker/master/bubbleStyle.png)

You can also set a different style for each contact view:
```objective-c
- (void)addContact:(id)contact withName:(NSString *)name withStyle:(THContactViewStyle *)bubbleStyle andSelectedStyle:(THContactViewStyle *)selectedStyle;
```
![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/THContactPicker/master/screenshot2.png)



