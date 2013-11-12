//
//  ContactPickerViewController.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewController.h"

@interface THContactPickerViewController ()

@end

@implementation THContactPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Contacts";
        self.contacts = [NSArray arrayWithObjects:@"Tristan Himmelman", @"John Himmelman", @"Nicole Robertson", @"Nicholas Barss", @"Andrew Sarasin", @"Mike Slon", @"Eric Salpeter", nil];
        self.selectedContacts = [NSMutableArray array];
        self.filteredContacts = self.contacts;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight];
    }
    
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove All"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(removeAllContacts:)];
    self.navigationItem.rightBarButtonItem = barButton;
  
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.contactPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderString:@"Who are you with?"];
    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view 
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                   self.tableView.contentInset.left,
                                                   self.tableView.contentInset.bottom,
                                                   self.tableView.contentInset.right);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self adjustTableViewInsets];
    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) adjustTableViewInsetTop:(CGFloat) topInset bottom:(CGFloat) bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (void) adjustTableViewInsetTop:(CGFloat) topInset {
    [self adjustTableViewInsetTop:topInset
                           bottom:self.tableView.contentInset.bottom];
}

- (void) adjustTableViewInsetBottom:(CGFloat) bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top
                           bottom:bottomInset];
}

- (void)adjustTableViewInsets {
    [self adjustTableViewInsetTop:self.contactPickerView.frame.size.height];
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *user = [self.filteredContacts objectAtIndex:indexPath.row];
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        [self.contactPickerView removeContact:user];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedContacts addObject:user];
        [self.contactPickerView addContact:user withName:user];
    }
    
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];    
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewInsets];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];

    int index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)removeAllContacts:(id)sender
{
    [self.contactPickerView removeAllContacts];
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *) notification{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.view.bounds.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *) notification{
    NSDictionary* info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.view.bounds.size.height - kbRect.origin.y];
}

@end























