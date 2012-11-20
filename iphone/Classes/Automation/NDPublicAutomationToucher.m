//
//  NDPublicAutomationToucher.m
//  NativeDriver
//
//  Created by Grace, Darragh on 19/11/2012.
//
//

#import "NDPublicAutomationToucher.h"
#import "NDToucher.h"

@implementation NDPublicAutomationToucher

// Sends touch event to specified view.
+ (void)PATouch:(UIView *)view {
    printf("*************************** - in PATouch\n");
    [NDToucher touch:view];
    
    //NDPublicAutomationToucher *toucher = [[[NDPublicAutomationToucher alloc] init] autorelease];
    //[toucher performSelectorOnMainThread:@selector(performTouch:)
    //                          withObject:view
    //                       waitUntilDone:YES];
}


@end
