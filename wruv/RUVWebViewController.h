//
//  RUVWebViewController.h
//  wruv
//
//  Created by Christopher Morse on 12/11/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RUVWebViewController : UIViewController < UIWebViewDelegate >


@property NSString *urlString;

@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;


@end
