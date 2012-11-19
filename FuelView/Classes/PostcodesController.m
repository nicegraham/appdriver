//
//  PostcodesController.m
//  AustralianPostcodes
//
//  Created by Matt Gallagher on 2009/12/07.
//  Copyright 2009 Matt Gallagher. All rights reserved.
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

#import "PostcodesController.h"
#import "Postcode.h"
#import "SynthesizeSingleton.h"
#import "NSManagedObjectContext+FetchAdditions.h"

@implementation PostcodesController

SYNTHESIZE_SINGLETON_FOR_CLASS(PostcodesController);

#pragma mark Core Data stack

//
// managedObjectModel
//
// Accessor. If the model doesn't already exist, it is created by merging all of
// the models found in the application bundle.
//
// returns the managed object model for the application.
//
- (NSManagedObjectModel *)managedObjectModel
{
	if (managedObjectModel != nil)
	{
		return managedObjectModel;
	}
	managedObjectModel =
		[[NSManagedObjectModel alloc]
			initWithContentsOfURL:
				[[NSBundle mainBundle]
					URLForResource:@"Postcodes"
					withExtension:@"mom"]];
	return managedObjectModel;
}

//
// persistentStoreCoordinator
//
// Accessor. If the coordinator doesn't already exist, it is created and the
// application's store added to it.
//
// returns the persistent store coordinator for the application.
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	if (persistentStoreCoordinator != nil)
	{
		return persistentStoreCoordinator;
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:
		[[NSBundle mainBundle]
			pathForResource:@"WAPostcodes"
			ofType:@"sql"]];

	NSError *error = nil;
	persistentStoreCoordinator =
		[[NSPersistentStoreCoordinator alloc]
			initWithManagedObjectModel:[self managedObjectModel]];
	if (![persistentStoreCoordinator
		addPersistentStoreWithType:NSSQLiteStoreType
		configuration:nil
		URL:storeUrl
		options:
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool:YES], NSReadOnlyPersistentStoreOption,
			nil]
		error:&error])
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
	return persistentStoreCoordinator;
}

//
// managedObjectContext
//
// Accessor. If the context doesn't already exist, it is created and bound to
// the persistent store coordinator for the application
//
// returns the managed object context for the application
//
- (NSManagedObjectContext *)managedObjectContext
{
	if (managedObjectContext != nil)
	{
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil)
	{
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	return managedObjectContext;
}

#pragma mark Actual lookup methods

//
// postcodeClosestToLocation:
//
// Gets the closest suburb out of the database
//
// Parameters:
//    coordinate - the location for which we are searching
//
// returns the Postcode object
//
- (Postcode *)postcodeClosestToLocation:(CLLocationCoordinate2D)coordinate
{
	//
	// Fetch results boxed to a latitude/longitude 0.3,0.3 square around the current location
	// as a common case optimization
	//
	NSArray *results = [[self managedObjectContext]
		fetchObjectArrayForEntityName:@"Postcode"
		withPredicate:@"latitude > %f and latitude < %f and longitude > %f and longitude < %f",
		coordinate.latitude - 0.15,
		coordinate.latitude + 0.15,
		coordinate.longitude - 0.15,
		coordinate.longitude + 0.15];
	
	//
	// If the boxed results don't work, fall back to fetching everything (there's
	// only 1763
	//
	if ([results count] == 0)
	{
		results = [[self managedObjectContext]
			fetchObjectArrayForEntityName:@"Postcode"
			withPredicate:nil];
	}
	
	//
	// Find the closest
	//
	Postcode *closest = nil;
	double closestDistance = 1e6;
	for (Postcode *postcode in results)
	{
		double distance = ([postcode.latitude doubleValue] - coordinate.latitude) * ([postcode.latitude doubleValue] - coordinate.latitude) +
			([postcode.longitude doubleValue] - coordinate.longitude) * ([postcode.longitude doubleValue] - coordinate.longitude);
		if (distance < closestDistance)
		{
			closestDistance = distance;
			closest = postcode;
		}
	}
	
	return closest;
}

//
// postcodeWithPostcodeValue:
//
// Gets the name of the suburb with the given postcode
//
// Parameters:
//    postcode - the postcode for which we are searching
//
// returns the name
//
- (Postcode*)postcodeWithPostcodeValue:(NSInteger)postcode
{
	NSArray *results = [[self managedObjectContext]
		fetchObjectArrayForEntityName:@"Postcode"
		withPredicate:@"postcode == %ld", postcode];
	
	if ([results count] > 0)
	{
		return [results objectAtIndex:0];
	}
	
	return nil;
}

@end
