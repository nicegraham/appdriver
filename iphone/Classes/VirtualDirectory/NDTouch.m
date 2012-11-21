//
//  NDTouch.m
//  NativeDriver
//
//  Created by Darragh Grace & Graham Abell @ PaddyPower 2012
//
//

#import "NDTouch.h"

#import "WebDriverResource.h"
#import "NDElementStore.h"
#import "NDElement.h"
#import "NDNativeButtonElement.h"
#import "NDPublicAutomationToucher.h"
#import "UIAutomationBridge.h"


@interface NDTouch ()

- (id)initWithElementStore:(NDElementStore *)elementStore;

- (void)singleTap:(NSDictionary *)params;

- (void)down:(NSDictionary *)params;

- (void)up:(NSDictionary *)params;

- (void)move:(NSDictionary *)params;

- (void)scroll:(NSDictionary *)params;

- (void)doubleTap:(NSDictionary *)params;

- (void)longPress:(NSDictionary *)params;

- (void)flick:(NSDictionary *)params;

@end

@implementation NDTouch

- (id)initWithElementStore:(NDElementStore *)elementStore {
    if ((self = [super init])) {
        elementStore_ = elementStore;
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(singleTap:)]
                 withName:@"click"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(down:)]
                 withName:@"down"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(up:)]
                 withName:@"up"];
        
//        [self setResource:[WebDriverResource
//                           resourceWithTarget:self
//                           GETAction:nil
//                           POSTAction:@selector(move:)]
//                 withName:@"move"];
//        
//        [self setResource:[WebDriverResource
//                           resourceWithTarget:self
//                           GETAction:nil
//                           POSTAction:@selector(scroll:)]
//                 withName:@"scroll"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(doubleTap:)]
                 withName:@"doubleclick"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(longPress:)]
                 withName:@"longclick"];
        
//        [self setResource:[WebDriverResource
//                           resourceWithTarget:self
//                           GETAction:nil
//                           POSTAction:@selector(flick:)]
//                 withName:@"flick"];
    }
    return self;
}

+ (NDTouch *)touchForElement:(NDElementStore *)elementStore {
    return [[[NDTouch alloc] initWithElementStore:elementStore] autorelease];
}

// Simulate a click on the element.
- (void)singleTap:(NSDictionary *)params{
    NSString *elementId = [params objectForKey:@"element"];
    NSMutableDictionary *elements = elementStore_.elements;
    
    UIView *elementView = [elements objectForKey:elementId];
    [UIAutomationBridge tapView:elementView];
}

- (void)down:(NSDictionary *)params{
    NSNumber *x =  [params objectForKey:@"x"];
    NSNumber *y =  [params objectForKey:@"y"];
    [UIAutomationBridge downPoint:CGPointMake([x floatValue], [y floatValue])];
}

- (void)up:(NSDictionary *)params{
    NSNumber *x =  [params objectForKey:@"x"];
    NSNumber *y =  [params objectForKey:@"y"];
    [UIAutomationBridge upPoint:CGPointMake([x floatValue], [y floatValue])];
}

- (void)move:(NSDictionary *)params{
    NSNumber *x =  [params objectForKey:@"x"];
    NSNumber *y =  [params objectForKey:@"y"];
    NSLog(@"x: %@", x);
}

- (void)scroll:(NSDictionary *)params{
    //element may not be passed in...
    NSString *elementId = [params objectForKey:@"element"];
    NSNumber *xoffset =  [params objectForKey:@"xoffset"];
    NSNumber *yoffset =  [params objectForKey:@"yoffset"];
    NSLog(@"Element id: %@", elementId);
}

- (void)doubleTap:(NSDictionary *)params{
    NSString *elementId = [params objectForKey:@"element"];
    NSMutableDictionary *elements = elementStore_.elements;
    
    UIView *elementView = [elements objectForKey:elementId];
    [UIAutomationBridge doubleTapView:elementView];
}

- (void)longPress:(NSDictionary *)params{
    NSString *elementId = [params objectForKey:@"element"];
    NSMutableDictionary *elements = elementStore_.elements;
    
    UIView *elementView = [elements objectForKey:elementId];
    NSTimeInterval duration = 0.2;
    [UIAutomationBridge longTapView:elementView forDuration:duration];

}

- (void)flick:(NSDictionary *)params{
    //element may not be passed in...
    NSString *elementId = [params objectForKey:@"element"];
    NSNumber *speed =  [params objectForKey:@"speed"];
    NSNumber *xoffset =  [params objectForKey:@"xoffset"];
    NSNumber *yoffset =  [params objectForKey:@"yoffset"];
    NSLog(@"");
}


@end
