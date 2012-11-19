//
//  main.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDNativeDriver.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
#ifdef NATIVEDRIVER
    [NDNativeDriver start];
#endif
    
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
