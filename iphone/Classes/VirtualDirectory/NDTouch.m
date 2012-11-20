//
//  NDTouch.m
//  NativeDriver
//
//  Created by Grace, Darragh on 16/11/2012.
//
//

#import "NDTouch.h"

#import "errorcodes.h"
#import "NDSession.h"
#import "NSException+WebDriver.h"
#import "WebDriverResource.h"
#import "NDElementStore.h"
#import "NDElement.h"
#import "NDNativeButtonElement.h"
#import "NDPublicAutomationToucher.h"


@interface NDTouch ()

- (id)initWithElementStore:(NDElementStore *)elementStore;

- (void)touchClick:(NSDictionary *)params;

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
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(move:)]
                 withName:@"move"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(scroll:)]
                 withName:@"scroll"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(touchClick:)]
                 withName:@"doubleclick"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(longPress:)]
                 withName:@"longclick"];
        
        [self setResource:[WebDriverResource
                           resourceWithTarget:self
                           GETAction:nil
                           POSTAction:@selector(flick:)]
                 withName:@"flick"];
    }
    return self;
}

+ (NDTouch *)touchForElement:(NDElementStore *)elementStore {
    return [[[NDTouch alloc] initWithElementStore:elementStore] autorelease];
}

// Simulate a click on the element.
- (void)singleTap:(NSDictionary *)params{
    //NSLog(@"In singleTap");
    NSString *elementId = [params objectForKey:@"element"];
    NSMutableDictionary *elements = elementStore_.elements;
    NDNativeButtonElement *button = [elements objectForKey:elementId];
    element_= [elements objectForKey:elementId];
    [NDPublicAutomationToucher PATouch:element_];
    
    NSLog(@"In singleTap");   // [element_ touch];
}

- (void)down:(NSDictionary *)params{
    NSNumber *x =  [params objectForKey:@"x"];
    NSNumber *y =  [params objectForKey:@"y"];
    NSLog(@"x: %@", x);
}

- (void)up:(NSDictionary *)params{
    NSNumber *x =  [params objectForKey:@"x"];
    NSNumber *y =  [params objectForKey:@"y"];
    NSLog(@"x: %@", x);
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
    element_= [elements objectForKey:elementId];
}

- (void)longPress:(NSDictionary *)params{
    NSString *elementId = [params objectForKey:@"element"];
    NSMutableDictionary *elements = elementStore_.elements;
    element_= [elements objectForKey:elementId];
}

- (void)flick:(NSDictionary *)params{
    //element may not be passed in...
    NSString *elementId = [params objectForKey:@"element"];
    NSNumber *speed =  [params objectForKey:@"speed"];
    NSNumber *xoffset =  [params objectForKey:@"xoffset"];
    NSNumber *yoffset =  [params objectForKey:@"yoffset"];
    NSLog(@"Element id: %@", elementId);
}


@end
