//
//  THContactPickerViewControllerDemo.m
//  ContactPicker
//
//  Created by Vladislav Kovtash on 12.11.13.
//  Copyright (c) 2013 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewControllerDemo.h"

@interface THContactPickerViewControllerDemo () <THContactPickerDelegate>

@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

@end

@implementation THContactPickerViewControllerDemo

static const CGFloat kPickerViewHeight = 100.0;

NSString *THContactPickerContactCellReuseID = @"THContactPickerContactCell";

@synthesize contactPickerView = _contactPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Contacts";
        self.contacts = [NSArray arrayWithObjects:@"Tristan Himmelman",
                         @"John Snow", @"Alex Martin", @"Nicolai Small",@"Thomas Lee", @"Nicholas Hudson", @"Bob Barss",
                         @"Andrew Stall", @"Marc Sarasin", @"Mike Beatson",@"Erica Slon", @"Eric Anderson", @"Josh Salpeter", nil];
    }
    return self;
}


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
    [self.contactPickerView setPlaceholderLabelText:@"Who would you like to message?"];
    [self.contactPickerView setPromptLabelText:@"To:"];
    //[self.contactPickerView setLimitToOne:YES];
    [self.view addSubview:self.contactPickerView];
    
    CALayer *layer = [self.contactPickerView layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
}

- (void)viewDidLayoutSubviews {
    [self adjustTableFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}

#pragma mark - Private methods

- (void)adjustTableFrame {
    CGFloat yOffset = self.contactPickerView.frame.origin.y + self.contactPickerView.frame.size.height;
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset);
    self.tableView.frame = tableFrame;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self titleForRowAtIndexPath:indexPath];
}

- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text {
    return [NSPredicate predicateWithFormat:@"self contains[cd] %@", text];
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.filteredContacts objectAtIndex:indexPath.row];
}

- (void) didChangeSelectedItems {
    
}

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THContactPickerContactCellReuseID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THContactPickerContactCellReuseID];
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
//		
//		UIColor *color = [UIColor blueColor];
//		if (self.privateSelectedContacts.count % 2 == 0){
//			color = [UIColor orangeColor];
//		} else if (self.privateSelectedContacts.count % 3 == 0){
//			color = [UIColor purpleColor];
//		}
//		THContactViewStyle *style = [[THContactViewStyle alloc] initWithTextColor:[UIColor whiteColor] backgroundColor:color cornerRadiusFactor:2.0];
//		THContactViewStyle *selectedStyle = [[THContactViewStyle alloc] initWithTextColor:[UIColor whiteColor] backgroundColor:[UIColor greenColor] cornerRadiusFactor:2.0];
//		[self.contactPickerView addContact:contact withName:contactTilte withStyle:style andSelectedStyle:selectedStyle];
    }
	
    self.filteredContacts = self.contacts;
    [self didChangeSelectedItems];
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPicker:(THContactPickerView *)contactPicker textFieldDidChange:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [self newFilteringPredicateWithText:textField.text];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    CGRect frame = self.tableView.frame;
    frame.origin.y = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    self.tableView.frame = frame;
}

- (void)contactPicker:(THContactPickerView *)contactPicker didRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];
    
    NSInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self didChangeSelectedItems];
}

- (BOOL)contactPicker:(THContactPickerView *)contactPicker textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0){
        NSString *contact = [[NSString alloc] initWithString:textField.text];
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:textField.text];
    }
    return YES;
}

#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

@end
