//
//  RUVRSSListViewController.h
//  MWFeedParser
//


#import <UIKit/UIKit.h>
#import <MWFeedParser/MWFeedParser.h>

@interface RUVRSSListViewController : UITableViewController < MWFeedParserDelegate >
{

    // Parsing

    MWFeedParser *feedParser;
    NSMutableArray *parsedItems;

    // Displaying
    NSArray *itemsToDisplay;
    NSDateFormatter *formatter;

}


// Properties
@property (nonatomic, retain) NSArray *itemsToDisplay;
@property (nonatomic, retain) NSString *feedString;

@end
