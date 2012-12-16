//
//  RUVRSSDetailViewController.h
//  MWFeedParser
//


#import <UIKit/UIKit.h>

@class MWFeedItem;

@interface RUVRSSDetailViewController : UITableViewController
{
    MWFeedItem *item;
    NSString *dateString, *summaryString;
}


@property (nonatomic, retain) MWFeedItem *item;
@property (nonatomic, retain) NSString *dateString, *summaryString;

@end
