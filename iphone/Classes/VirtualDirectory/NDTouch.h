//
//  NDTouch.h
//  NativeDriver
//
//  Created by Grace, Darragh on 16/11/2012.
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
@public
    NDElement *element_;  // the parent session (weak)
}

// Creates new instance.
+ (NDTouch *)touchForElement:(NDElementStore *)elementStore;

@end
