//
//  NDTouch.h
//  NativeDriver
//
//  Created by Darragh Grace & Graham Abell @ PaddyPower 2012
//
//

#import "HTTPVirtualDirectory.h"

@class NDElement;
@class NDElementStore;

// This |HTTPVirtualDirectory| matches the /hub/:session/touch
// directory in the WebDriver REST service. Supports touch actions.
@interface NDTouch : HTTPVirtualDirectory {
@private
    NDElementStore *elementStore_;
    NDElement *element_;  // the parent session (weak)
}

// Creates new instance.
+ (NDTouch *)touchForElement:(NDElementStore *)elementStore;

@end
