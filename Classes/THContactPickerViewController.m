//
//  ContactPickerViewController.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewController.h"
#import "THContactPickerView.h"

static const CGFloat kPickerViewHeight = 100.0;

@interface THContactPickerViewController () <THContactPickerDelegate>
@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@end

@implementation THContactPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight];
    }
  
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPickerViewHeight)];
    self.contactPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.contactPickerView.delegate = self;
    [self.contactPickerView setPlaceholderString:_placeholderString];
    [self.view addSubview:self.contactPickerView];
    
    // Fill the rest of the view with the table view 
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
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

- (NSArray *)selectedContacts{
    return [self.privateSelectedContacts copy];
}

#pragma mark - Publick properties

- (NSArray *)filteredContacts {
    if (!_filteredContacts) {
        _filteredContacts = _contacts;
    }
    return _filteredContacts;
}

- (void) setPlaceholderString:(NSString *)placeholderString {
    _placeholderString = placeholderString;
    [self.contactPickerView setPlaceholderString:_placeholderString];
}

- (void)adjustTableViewInsetTop:(CGFloat) topInset bottom:(CGFloat) bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger) selectedCount {
    return self.privateSelectedContacts.count;
}

#pragma mark - Publick methods

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return nil;
}

- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void) didChangeSelectedItems {
    
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}

#pragma mark - Private methods

- (void)adjustTableViewInsetTop:(CGFloat) topInset {
    [self adjustTableViewInsetTop:topInset
                           bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat) bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top
                           bottom:bottomInset];
}

- (void)adjustTableViewInsets {
    [self adjustTableViewInsetTop:self.contactPickerView.frame.size.height];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ContactCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    id contact = [self.filteredContacts objectAtIndex:indexPath.row];
    NSString *contactTilte = [self titleForRowAtIndexPath:indexPath];
    
    if ([self.privateSelectedContacts containsObject:contact]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.privateSelectedContacts removeObject:contact];
        [self.contactPickerView removeContact:contact];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:contactTilte];
    }
    
    self.filteredContacts = self.contacts;
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [self newFilteringPredicateWithText:textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    [self adjustTableViewInsets];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];

    NSInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self didChangeSelectedItems];
}

- (void)clearSelectedContacts:(id)sender {
    [self.contactPickerView removeAllContacts];
    [self.privateSelectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self didChangeSelectedItems];
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























