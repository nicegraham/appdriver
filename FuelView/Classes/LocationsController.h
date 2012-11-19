//
//  LocationsController.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Location;
@class LocationsController;

@protocol LocationReceiver

- (void)receiveLocation:(Location *)aLocation fromLocationsController:(LocationsController *)aController;

@end

@interface LocationsController : NSObject
{
	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;		
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

+ (LocationsController *)sharedLocationsController;
- (NSManagedObjectContext *)managedObjectContext;
- (void)locationForAddress:(NSString *)address receiver:(id<LocationReceiver>)receiver;

@end
