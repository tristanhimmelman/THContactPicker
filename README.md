THContactPicker
===============

An iOS view used for selecting multiple contacts. This was built to mimic the selecting contact functionality in the Apple Mail app with improved UI.

Details:

- Control now loads contacts from address book after requesting permission.
- Added model class THContact
- Used custom cell view for easier UI customization.
- Added neat circular checkbox to the left side of the contact cell.
- Added circular contact images.
- Text filter field and table view resize using animation for smoother feel.
- Bar button on the top right is disabled by default and enabled when there is at least 1 contact selected.
- Keyboard is dismissed when tapping outside the filter text field.
- TODO: Implement contact details view

Special thanks to Pavel Dušátko (@dusi) for the mentorship while working on this.

![Screenshot](https://raw.github.com/soofani/THContactPicker/master/screenshot.png)
