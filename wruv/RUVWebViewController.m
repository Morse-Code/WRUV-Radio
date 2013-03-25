//
//  RUVWebViewController.m
//  wruv
//
//  Created by Christopher Morse on 12/11/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "RUVWebViewController.h"

const NSString *textOnly = @"http://viewtext.org/api/text?url={url}&format={format}&callback={callback}";

@interface RUVWebViewController ()


@end

@implementation RUVWebViewController


@synthesize urlString = _urlString;
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)startWebViewLoadFromString:(NSString *)string
{

    //NSString *urlAddress = @"http://www.google.com";
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:string];

    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];

    //Load the request in the UIWebView.
    [self.webView loadRequest:requestObj];

}


- (void)webViewDidFinishLoad:(UIWebView *)thisWebView
{

    //stop the activity indicator when done loading
    [self.activityIndicator stopAnimating];
}


- (void)showReadability
{
//    NSString *readJS = @"(function(){window.baseUrl='https://www.readability.com';window.readabilityToke‌​n='';var s=document.createElement('script');s.setAttribute('type','text/javascript');s.se‌​tAttribute('charset','UTF-8');s.setAttribute('src',baseUrl+'/bookmarklet/read.js');document.documentElemen‌​t.appendChild(s);})()";
    NSString *newString = [NSString stringWithFormat:@"http://viewtext.org/api/text?url=%@", self.urlString];
//    [self startWebViewLoadFromString:readJS];
//    NSString *newString = @"http://www.google.com";
    [self.activityIndicator startAnimating];
    [self performSelector:@selector(startWebViewLoadFromString:) withObject:newString afterDelay:0];

}


- (void)viewDidLoad
{

    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reader"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(showReadability)];

    //start an animator symbol for the webpage loading to follow
    UIActivityIndicatorView *progressWheel = [[UIActivityIndicatorView alloc]
                                                                       initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    //makes activity indicator disappear when it is stopped
    progressWheel.hidesWhenStopped = YES;

    //used to locate position of activity indicator
    progressWheel.center = CGPointMake(160, 160);

    self.activityIndicator = progressWheel;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];

    [super viewDidLoad];

    //call another method to do the webpage loading
    [self performSelector:@selector(startWebViewLoadFromString:) withObject:self.urlString afterDelay:0];

    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
