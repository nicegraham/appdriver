//
//  NDSession.m
//  iPhoneNativeDriver
//
//  Copyright 2011 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  updates by Darragh Grace & Graham Abell @ PaddyPower 2012

#import "NDSession.h"

#import "NDElementStore.h"
#import "NDSessionRoot.h"
#import "NDTimeouts.h"
#import "WebDriverResource.h"
#import "errorcodes.h"
#import "NSException+WebDriver.h"
#import <PublicAutomation/UIAutomationBridge.h>

@interface NDSession ()

- (id)initWithSessionRoot:(NDSessionRoot *)root
                sessionId:(int)sessionId;

- (NSDictionary *)capabilities;
- (NSString *)title;

@end

@implementation NDSession

@synthesize sessionId = sessionId_;
@synthesize elementStore = elementStore_;
@synthesize implicitWait = implicitWait_;

- (NDSession *)initWithSessionRoot:(NDSessionRoot *)root
                         sessionId:(int)sessionId {
  if ((self = [super init])) {
    sessionRoot_ = root;
    sessionId_ = sessionId;

    // Creates NDElementStore. elementStoreWithSession will register itself
    // as the /element and /elements virtual directory.
    elementStore_ = [[NDElementStore elementStoreWithSession:self] retain];

    [self setIndex:[WebDriverResource
                    resourceWithTarget:self
                             GETAction:@selector(capabilities)
                            POSTAction:nil
                             PUTAction:nil
                          DELETEAction:@selector(deleteSession)]];

    [self setResource:[WebDriverResource
                       resourceWithTarget:self
                                GETAction:@selector(title)
                               POSTAction:nil]
             withName:@"title"];      
      
    [self setResource:[WebDriverResource
                         resourceWithTarget:self
                         GETAction:nil
                         POSTAction:@selector(setLocation:)]
               withName:@"location"];
      
    [self setResource:[WebDriverResource
                         resourceWithTarget:self
                         GETAction:@selector(getOrientation)
                         POSTAction:@selector(setOrientation:)]
               withName:@"orientation"];

    [self setResource:[NDTimeouts timeoutsWithSession:self]
               withName:@"timeouts"];
      
    [self setResource:[NDTouch touchForElement:elementStore_]
               withName:@"touch"];

  }
  return self;
}

- (void)dealloc {
  [elementStore_ release];
  [super dealloc];
}

+ (NDSession *)sessionWithSessionRoot:(NDSessionRoot *)root
                            sessionId:(int)sessionId {
  return [[[NDSession alloc] initWithSessionRoot:root
                                       sessionId:sessionId] autorelease];
}

- (void)deleteSession {
  // Tell the session root to remove this resource.
  [sessionRoot_ deleteSessionWithId:sessionId_];
}

// Returns this driver's capabilities. Since capabilities JSON Object represents
// browser spec, it doesn't exactly match to native applications. This method
// returns special browser name and platform name for NativeDriver.
- (NSDictionary *)capabilities {
  NSMutableDictionary *caps = [NSMutableDictionary dictionary];
  [caps setObject:@"ios native" forKey:@"browserName"];
  [caps setObject:[[UIDevice currentDevice] systemVersion] forKey:@"version"];
  [caps setObject:@"IOS" forKey:@"platform"];
  return caps;
}

// Returns current key window.
- (UIWindow *)keyWindow {
  return [[UIApplication sharedApplication] keyWindow];
}

// Returns title on the navigation bar. If the target application is not
// navigation based, returns the controller's title.
- (NSString *)title {
  UIViewController *controller = [[self keyWindow] rootViewController];
  if ([controller isKindOfClass:[UINavigationController class]]) {
    return [[[(UINavigationController *)controller topViewController]
             navigationItem] title];
  }
  return [controller title];
}

- (void)setLocation:(NSDictionary *)params{
    NSDictionary *innerDict = [params objectForKey:@"location"];
    if( ![innerDict objectForKey:@"latitude"] && ![innerDict objectForKey:@"longitude"]){
        @throw [NSException
                webDriverExceptionWithMessage:@"Please provide both longitude and latitude"
                andStatusCode:ELOCATIONERROR];
    }
    CGPoint locationAsPoint = CGPointMake([[innerDict objectForKey:@"latitude"] floatValue],[[innerDict objectForKey:@"longitude"] floatValue]);
    
    NSLog(@"simulating location of %f,%f",locationAsPoint.x, locationAsPoint.y);
    
    [UIAutomationBridge setLocation:locationAsPoint];
}


// Use Public Automation to set the orientation of the device or aimulator
- (void)setOrientation:(NSDictionary *)params{    
    NSString *orientation = [[params valueForKey:@"orientation"] description];
    NSLog (@"Setting device Orientation to -> %@", orientation);
    [UIAutomationBridge setOrientation:[self convertOrientation:orientation]];    
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 2, false);
}


- (UIDeviceOrientation)convertOrientation:(NSString *)orientation{    
    UIDeviceOrientation requestedOrientation = UIDeviceOrientationUnknown;
    if( [orientation isEqualToString:@"PORTRAIT"] ){
        requestedOrientation = UIDeviceOrientationPortrait;
    }else if ([orientation  isEqualToString:@"LANDSCAPE"]){
        requestedOrientation = UIDeviceOrientationLandscapeRight;
    }    
    return requestedOrientation;
}

// Get the device or simulators orientation
- (NSString *)getOrientation{
    
    switch ( [UIDevice currentDevice].orientation ) {
		case UIDeviceOrientationLandscapeRight:
		case UIDeviceOrientationLandscapeLeft:
			return @"LANDSCAPE";
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
			return @"PORTRAIT";
        case UIDeviceOrientationFaceUp:
            NSLog(@"Device orientation is face up");
            //fall thru
        case UIDeviceOrientationFaceDown:
            NSLog(@"Device orientation is face down");
            //fall thru
        case UIDeviceOrientationUnknown:
            NSLog(@"Device orientation is unknown");
            //fall thru
		default:
            return nil;
	}
}

// Override to set session id for each |WebDriverResource|.
// |elementWithQuery:| is recursively called, so this will effect all resources
// under /session/:sessionid directory.
- (id<HTTPResource>)elementWithQuery:(NSString *)query {
  id<HTTPResource> resource = [super elementWithQuery:query];
  if ([resource isKindOfClass:[WebDriverResource class]]) {
    NSString *sessionIdString = [NSString stringWithFormat:@"%d", sessionId_];
    [(WebDriverResource *)resource setSession:sessionIdString];
  }
  return resource;
}

@end
