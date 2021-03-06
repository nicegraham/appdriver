//
//  NDElementDirectory.h
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

#import <Foundation/Foundation.h>
#import "HTTPVirtualDirectory.h"

@class NDElement;
@class NDElementStore;

// Represents the /:session/element/:id directory. This method handles HTTP
// requests, checks the element state, and manipulates the target |NDElement|.
@interface NDElementDirectory : HTTPVirtualDirectory {
@private
    NDElementStore *elementStore_;  // the parent element store (weak)
@public
    NDElement *element_;
}

// Creates new instance. Note |elementStore| is a weak pointer. The caller needs
// to ensure its lifetime outlives this object.
+ (NDElementDirectory *)directoryWithElement:(NDElement *)element
                                elementStore:(NDElementStore *)elementStore;

@end
