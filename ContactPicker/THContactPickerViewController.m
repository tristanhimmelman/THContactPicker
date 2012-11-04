//
//  ContactPickerViewController.m
//  ContactPicker
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THContactPickerViewController.h"
#import "THContactPickerTextView.h"
#import "THContactBubble.h"

@interface THContactPickerViewController ()

@end

@implementation THContactPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    THContactPickerTextView *contactPickerView = [[THContactPickerTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    [contactPickerView setPlaceholderString:@"Who are you with?"];
    [contactPickerView addContact:@"Tristan Himmelman"];
    
    [self.view addSubview:contactPickerView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
