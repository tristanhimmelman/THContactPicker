//
//  ContactPickerViewController.h
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerView.h"

@interface THContactPickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, readonly) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, readonly) NSArray *selectedContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredContacts;
@property (strong, nonatomic) NSString *placeholderString;

- (void)clearSelectedContacts:(id)sender;
- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) didChangeSelectedItems;
- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
