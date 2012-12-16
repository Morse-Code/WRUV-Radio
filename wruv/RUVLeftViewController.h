//
//  RUVLeftViewController.h
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MWFeedParser/MWFeedParser.h>


@interface RUVLeftViewController : UITableViewController
{
    NSArray *_radioSection;
}


@property (nonatomic, strong) NSArray *radioSection;


@end
