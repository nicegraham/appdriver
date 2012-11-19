//
//  FuelViewAppDelegate.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "FuelViewAppDelegate.h"
#import "ResultsViewController.h"
#import "SettingsViewController.h"
#import "Location.h"
#import "LocationsController.h"

@implementation FuelViewAppDelegate

@synthesize window;
@synthesize navigationController;

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInteger:FVFuelTypeUnleaded], @"fuelType",
		nil]];
}

//
// application:didFinishLaunchingWithOptions:
//
// Load the first view and display on screen. Other launch work.
//
// Parameters:
//    application - the current application
//    launchOptions - information about the launch reason
//
// returns whether the application accepts the launchOptions
//
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.23 blue:0.25 alpha:1.0];
	
	// Set the window's background color to black since this color will actually
	// be visible when the ResultsViewContorller performs the flip animation
	// to the SettingsViewController.
	self.window.backgroundColor = [UIColor blackColor];

    // Override point for customization after application launch.
	ResultsViewController *rootViewController = [[[ResultsViewController alloc] init] autorelease];
    [navigationController pushViewController:rootViewController animated:NO];
	
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    return YES;
}

//
// dealloc
//
// Release instance memory. This is unlikely to be called though.
//
- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

