//
//  RUVViewController.m
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "RUVViewController.h"
#import "IIViewDeckController.h"

@interface RUVViewController ()

@end

@implementation RUVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"left" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
