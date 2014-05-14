THContactPicker
===============

THContactPicker is an iOS view used for selecting contacts. It is built to mimic the contact selecting functionality in the iOS Mail app. The view can easily be added using interface or programmatically. It also supports customization to suit different needs.

![Screenshot](https://raw.github.com/mysteriouss/THContactPicker/master/example.gif)
![Screenshot](https://raw.github.com/mysteriouss/THContactPicker/master/screenshot.png)

Customization Functions:

- (void)setBubbleStyle:(THBubbleStyle *)color selectedStyle:(THBubbleStyle *)selectedColor;
Set the style of the contacts item for default and selected states. THBubbleStyle defines the look of each contact item. The following attributes can be modified: text label color, top gradient color, bottom gradient color, border color, border width and corner radius factor.

Sample bubble style (iOS 6 look):
![Screenshot](https://raw.github.com/mysteriouss/THContactPicker/master/bubbleStyle.png)

- (void)setPlaceholderLabelText:(NSString *)text;
Set the text that is displayed in the view when there are no selected contacts

- (void)setPromptLabelText:(NSString *)text;	
Set the text for the Preceding prompt label. If not set, the label will not be displayed

- (void)setFont:(UIFont *)font;
Change the font of all elements in the view