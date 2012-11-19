//
//  main.m
//  Automation
//
//  Created by Grace, Darragh on 15/10/2012.
//
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#ifdef NATIVEDRIVER
# "NDNativeDriver.h"
#endif


int main(int argc, char *argv[])
{
#ifdef NATIVEDRIVER
    [NDNativeDriver start]
#endif
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
