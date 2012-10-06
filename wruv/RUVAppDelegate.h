//
//  RUVAppDelegate.h
//  wruv
//
//  Created by Christopher Morse on 10/6/12.
//  Copyright (c) 2012 Christopher Morse. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RUVViewController;

@interface RUVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *centerController;
@property (strong, nonatomic) UIViewController *leftController;

@end
