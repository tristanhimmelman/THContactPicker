THContactPicker
===============

THContactPicker is an iOS view used for selecting contacts. It is built to mimic the contact selecting functionality in the iOS Mail app. The view can easily be added using interface builder or programmatically. It also supports customization to suit different needs. The view can be added to your project using Cocoapods or by manually adding the files.

![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/THContactPicker/master/screenshot.png)
![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/THContactPicker/master/example.gif)

Customization:

```objective-c
- (void)setBubbleStyle:(THBubbleStyle *)color selectedStyle:(THBubbleStyle *)selectedColor;
```
Set the style of the contacts item for default and selected states. THBubbleStyle defines the look of each contact item. The following attributes can be modified: text label color, top gradient color, bottom gradient color, border color, border width and corner radius factor. Sample bubble style (iOS 6 look):
![Screenshot](https://raw.githubusercontent.com/tristanhimmelman/THContactPicker/master/bubbleStyle.png)

```objective-c
- (void)setPlaceholderLabelText:(NSString *)text;
```
Set the text that is displayed in the view when there are no selected contacts

```objective-c
- (void)setPromptLabelText:(NSString *)text;	
```
Set the text for the Preceding prompt label. If not set, the label will not be displayed

```objective-c
- (void)setFont:(UIFont *)font;
```
Change the font of all elements in the view 
