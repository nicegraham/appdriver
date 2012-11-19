//
//  LocationsController.m
//  AustralianPostcodes
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

#import "LocationsController.h"
#import "Location.h"
#import "SynthesizeSingleton.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "NSFileManager+DirectoryLocations.h"
#import "XMLFetcher.h"

static NSString * const MapsKey = nil;

@implementation LocationsController

SYNTHESIZE_SINGLETON_FOR_CLASS(LocationsController);

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
					URLForResource:@"Locations"
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
			pathForResource:@"Locations"
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

	NSURL *writeableUrl = [NSURL fileURLWithPath:
		[[[NSFileManager defaultManager]
			applicationSupportDirectory]
				stringByAppendingPathComponent:@"Locations.sql"]];

	if (![persistentStoreCoordinator
		addPersistentStoreWithType:NSSQLiteStoreType
		configuration:nil
		URL:writeableUrl
		options:
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool:NO], NSReadOnlyPersistentStoreOption,
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

//
// locationForAddress:receiver:
//
// Lookup the coordinates of the given address. Return from the cache if
// possible, otherwise lookup on Google Maps (requires Google Maps API key).
//
// Parameters:
//    address - the address to lookup (should be fully qualified with State and Country)
//    receiver - the LocationReceiver to call on when the request is complete
//
- (void)locationForAddress:(NSString *)address receiver:(id<LocationReceiver>)receiver
{
	//
	// Lookup in cache
	//
	Location *location =
		[[self managedObjectContext]
			fetchSingleObjectForEntityName:@"Location"
			withPredicate:@"address == %@", address];
	
	if (location)
	{
		//
		// Found in cache, return immediately
		//
		[receiver receiveLocation:location fromLocationsController:self];
	}
	else
	{
		//
		// Not found in cache, lookup on Google Maps.
		//
		// For this step to work, you will need a Google Maps API kep.
		//
		if (!MapsKey)
		{
			return;
		}
		
		NSString *escapedAddress =
			[(NSString *)CFURLCreateStringByAddingPercentEscapes(
				nil,
				(CFStringRef)address,
				(CFStringRef)@"",
				(CFStringRef)@"&;?",
				kCFStringEncodingUTF8)
			autorelease];
		NSString *urlString =
			[NSString
				stringWithFormat:
					@"http://maps.google.com/maps/geo?q=%@&output=xml&key=%@",
					escapedAddress,
					MapsKey];
		
		//
		// Peform the fetch using the XML fetcher. A JSON fetch is normally
		// preferred for Maps but we already have the XML fetcher in this
		// project so we might as well use that
		//
		XMLFetcher *fetcher =
			[[XMLFetcher alloc]
				initWithURLString:urlString
				xPathQuery:@"//*[local-name()='coordinates']"
				receiver:self
				action:@selector(mapsResponseReceived:)];
		fetcher.context =
			[[NSDictionary alloc] initWithObjectsAndKeys:
				address, @"address",
				receiver, @"receiver",
			nil];
		[fetcher start];
	}
}

//
// mapsResponseReceived:
//
// Handle the response from Google maps by storing the location in the cache
// and saving the cache. Response should be sent to the receiver.
//
// Parameters:
//    xmlFetcher - the XMLFetcher that contains the result.
//
- (void)mapsResponseReceived:(XMLFetcher *)xmlFetcher
{
	if ([xmlFetcher.results count] == 0)
	{
		return;
	}
	
	NSArray *components = [[[xmlFetcher.results objectAtIndex:0] contentString] componentsSeparatedByString:@","];

	Location *location =
		[NSEntityDescription
			insertNewObjectForEntityForName:@"Location"
			inManagedObjectContext:[self managedObjectContext]];
	location.address = [(NSDictionary *)xmlFetcher.context objectForKey:@"address"];
	location.longitude = [NSNumber numberWithFloat:[[components objectAtIndex:0] floatValue]];
	location.latitude = [NSNumber numberWithFloat:[[components objectAtIndex:1] floatValue]];
	
	NSError *error = nil;
	[[self managedObjectContext] save:&error];
	NSAssert(error == nil, @"Error saving context: %@", [error localizedDescription]);
	
	[(id<LocationReceiver>)[(NSDictionary *)xmlFetcher.context objectForKey:@"receiver"]
		receiveLocation:location
		fromLocationsController:self];
	
	[(NSDictionary *)xmlFetcher.context release];
	[xmlFetcher release];
}

@end
