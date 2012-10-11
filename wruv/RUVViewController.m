//
//  RUVViewController.m
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import "RUVViewController.h"
#import "IIViewDeckController.h"
#import "StreamModel.h"

@interface RUVViewController ()
@property (nonatomic, retain) StreamModel *streamer;
@end

@implementation RUVViewController


@synthesize stationArt = _stationArt;
@synthesize streamer = _streamer;
@synthesize m3uPath = _m3uPath;
@synthesize playButton = playButton;
@synthesize playControl = _playControl;

//@synthesize menuButton = _menuButton;
//@synthesize navigationBar = _navigationBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.streamer = [[StreamModel alloc] init];
    //    self.m3uPath = @"http://139.140.232.18:8000/WBOR";
    self.m3uPath = @"http://icecast.uvm.edu:8005/wruv_fm_256";
    [self.playButton setBackgroundColor:[UIColor whiteColor]];
    [[self.playButton titleLabel] setText:@"Play"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"left" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
//    [self.menuButton setTitle:@"Back"];
//    [self.menuButton setTarget:self.viewDeckController];
//    [self.menuButton setAction:@selector(toggleLeftView)];
    [self.stationArt setImage:[UIImage imageNamed:@"wruv.png"]];
//    AVAudioPlayer
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) playToggle:(UIButton *)sender
{
    if ([[[sender titleLabel] text] isEqualToString:@"Play"]){
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.wruvLive = [[NSURL alloc] initWithString:self.m3uPath];
        self.streamer = [[StreamModel alloc] initWithURL:self.wruvLive];
        [self.streamer start];
        [self.playButton setSelected:NO];
    }
    else if ([[[sender titleLabel] text] isEqualToString:@"Stop"]){
        [self.playButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.streamer stop];
        self.streamer = nil;
    }
}
@end
