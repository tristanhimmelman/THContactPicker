//
//  THContactPickerViewControllerDemo.m
//  ContactPicker
//
//  Created by Vladislav Kovtash on 12.11.13.
//  Copyright (c) 2013 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewControllerDemo.h"

@interface THContactPickerViewControllerDemo ()

@end

@implementation THContactPickerViewControllerDemo

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Contacts";
        self.contacts = [NSArray arrayWithObjects:@"Tristan Himmelman",
                         @"John Himmelman", @"Nicole Robertson", @"Nicholas Barss",
                         @"Andrew Sarasin", @"Mike Slon", @"Eric Salpeter", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove All"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(clearSelectedContacts:)];
    self.navigationItem.rightBarButtonItem = barButton;
    self.placeholderString  = @"Who are you with?";
}

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return [NSPredicate predicateWithFormat:@"self contains[cd] %@", text];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self.filteredContacts objectAtIndex:indexPath.row];
}

@end
