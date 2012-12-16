//
//  RUVLeftViewController.m
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "RUVLeftViewController.h"
#import <MWFeedParser/MWFeedParser.h>
#import "RUVRSSListViewController.h"
#import "IIViewDeckController.h"


@interface RUVLeftViewController ()


@property NSArray *feeds;
@property NSArray *URLList;
@end


@implementation RUVLeftViewController


@synthesize feeds = _feeds;
@synthesize URLList = _URLList;
@synthesize radioSection = _radioSection;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    _radioSection = [NSArray arrayWithObjects:@"Player", @"WRUV Show Schedule", nil];
    _feeds = [NSArray arrayWithObjects:@"Bored?", @"Vermont Cynic", @"UVM Athletics", nil];
    _URLList = [NSArray arrayWithObjects:@"http://uvmbored.com/feed/",
                                         @"http://www.vermontcynic.com/se/vermont-cynic-rss-1.1353827",
                                         @"http://uvmathletics.com/rss.aspx", nil];
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 1) {
        return [self.feeds count];
    }
    else
    {
        return 1;
    }
}


- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"UVM News and Events";
    }
    else
    {
        return @"WRUV Radio";
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.radioSection objectAtIndex:(NSUInteger)indexPath.row];
    }
    else
    {
        cell.textLabel.text = [self.feeds objectAtIndex:(NSUInteger)indexPath.row];
    }

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    self.viewDeckController.leftController = SharedAppDelegate.leftController;
    if ([[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text] isEqualToString:@"Player"]) {
        self.viewDeckController.centerController = SharedAppDelegate.centerController;
        self.viewDeckController.leftController = SharedAppDelegate.leftController;

    }
    else if ([[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text] isEqualToString:@"WRUV Show Schedule"]) {

    }
    else
    {
        RUVRSSListViewController *feedViewController = [[RUVRSSListViewController alloc]
                                                                                  initWithNibName:@"RootViewController"
                                                                                           bundle:nil];
        [feedViewController setFeedString:[self.URLList objectAtIndex:(NSUInteger)indexPath.row]];
        UINavigationController
                *navController = [[UINavigationController alloc] initWithRootViewController:feedViewController];

        self.viewDeckController.centerController = navController;

    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller)
    {
        [NSThread sleepForTimeInterval:(300 + arc4random() % 700) / 1000000.0]; // mimic delay... not really necessary
    }];

}

@end
