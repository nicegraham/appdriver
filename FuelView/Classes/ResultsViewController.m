//
//  ResultsViewController.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "ResultsViewController.h"
#import "GradientBackgroundTable.h"
#import "PostcodesController.h"
#import "XMLFetcher.h"
#import "SettingsViewController.h"
#import "LabelCell.h"
#import "ResultCell.h"
#import "Location.h"
#import "Postcode.h"
#import "MapViewController.h"

#define FVLocationFailedOutsideWA -1

@implementation ResultsViewController

@synthesize usingManualLocation;
@synthesize location;
@synthesize gpsLocation;

//
// title
//
// returns the navigation item title
//
- (NSString *)title
{
	return NSLocalizedStringFromTable(@"FuelView", @"ResultsView", @"Application title");
}

//
// nibName
//
// returns the name of the NIB file from which this view is loaded
//
- (NSString *)nibName
{
	return @"ResultsView";
}

//
// updateDisplay
//
// Invoked to refresh the display -- either loading in results or displaying
// a status message.
//
- (void)updateDisplay
{
	self.navigationController.navigationItem.title = [self title];
	
	if (!location)
	{
		[self removeLoadingIndicator];
		[self emptySectionAtIndex:0 withAnimation:UITableViewRowAnimationFade];
		[self
			appendRowToSection:0
			cellClass:[LabelCell class]
			cellData:NSLocalizedStringFromTable(@"Waiting for location (GPS or postcode)...", @"ResultsViewController", nil)
			withAnimation:UITableViewRowAnimationFade];

		self.navigationController.navigationBar.topItem.title = [self title];
	}
	else if (fetcher)
	{
		[self showLoadingIndicator];
		[self emptySectionAtIndex:0 withAnimation:UITableViewRowAnimationFade];
		[self
			appendRowToSection:0
			cellClass:[LabelCell class]
			cellData:NSLocalizedStringFromTable(@"Loading data from FuelWatch.wa.gov.au ...", @"ResultsViewController", nil)
			withAnimation:UITableViewRowAnimationFade];

		self.navigationController.navigationBar.topItem.title = [self title];
	}
	else if ([results count] > 0)
	{
		[self hideLoadingIndicator];
		[self emptySectionAtIndex:0 withAnimation:UITableViewRowAnimationFade];
		
		for (NSDictionary *result in results)
		{
			[self
				appendRowToSection:0
				cellClass:[ResultCell class]
				cellData:result
				withAnimation:UITableViewRowAnimationLeft];
		}
		
		self.navigationController.navigationBar.topItem.title =
			[NSString stringWithFormat:
				NSLocalizedStringFromTable(@"%@ near %@", @"ResultsViewController", nil),
				[SettingsViewController currentFuelTypeLabel],
				location.suburb];
	}
	else
	{
		[self hideLoadingIndicator];
		[self emptySectionAtIndex:0 withAnimation:UITableViewRowAnimationFade];
		[self
			appendRowToSection:0
			cellClass:[LabelCell class]
			cellData:NSLocalizedStringFromTable(@"No results found.", @"ResultsViewController", nil)
			withAnimation:UITableViewRowAnimationFade];

		self.navigationController.navigationBar.topItem.title =
			[NSString stringWithFormat:
				NSLocalizedStringFromTable(@"%@ near %@", @"ResultsViewController", nil),
				[SettingsViewController currentFuelTypeLabel],
				location.suburb];
	}
}

//
// refresh:
//
// Called when the reload button is pressed
//
// Parameters:
//    sender - ignored
//
- (void)refresh:(id)sender
{
	//
	// Force a reload by unsetting then resetting the suburb name
	//
	Postcode *temp = [[self.location retain] autorelease];
	self.location = nil;
	self.location = temp;
}

//
// showSettings:
//
// Called when the "i" button is pressed to access the settings
//
// Parameters:
//    sender - ignored
//
- (void)showSettings:(id)sender
{
	UIWindow *window = self.view.window;
	
	SettingsViewController *settingsViewController = [[[SettingsViewController alloc] init] autorelease];
	[self.navigationController
		presentModalViewController:settingsViewController
		animated:NO];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:window cache:YES];

	[UIView commitAnimations];
}

//
// viewDidLoad
//
// On load, refreshes the view (to load the rows)
//
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Even though this table is named "GradientBackgroundTable", it can also
	// be a table with a flat, custom color if you set the bottom color to
	// nil.
	[(GradientBackgroundTable *)self.tableView setBackgroundColorTop:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]];
	[(GradientBackgroundTable *)self.tableView setBackgroundColorBottom:nil];
	
	[self addSectionAtIndex:0 withAnimation:UITableViewRowAnimationNone];
	[self updateDisplay];
	
	//
	// Deliberately set an invalid initial location
	//
	gpsLocation = CLLocationCoordinate2DMake(1000, 1000);

	// Start the gpsLocation manager
	// We start it *after* startup so that the UI is ready to display errors, if needed.
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"postcode"])
	{
		postcodeField.text =
			[[[NSUserDefaults standardUserDefaults] objectForKey:@"postcode"] stringValue];
		[self textFieldDidEndEditing:postcodeField];
	}
}

//
// viewDidUnload
//
// Implemented to undo resource allocations in viewDidLoad
//
- (void)viewDidUnload
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
	locationManager = nil;
}

//
// tableView:cellForRowAtIndexPath:
//
// Returns the cell for a given indexPath.
//
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)anIndexPath
{
	UITableViewCell *cell = [super tableView:aTableView cellForRowAtIndexPath:anIndexPath];
	
	//
	// Override the default behavior of the ResultCell and disable the
	// disclosure indicator accessory.
	//
	if ([cell isKindOfClass:[ResultCell class]])
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	return cell;
}

//
// tableView:didSelectRowAtIndexPath:
//
// Handle row selection
//
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{
	if ([[self classForRow:anIndexPath.row inSection:anIndexPath.section]
		isEqual:[ResultCell class]])
	{
		[self.navigationController
			pushViewController:
				[[[MapViewController alloc]
					initWithSelectedResult:[self dataForRow:anIndexPath.row inSection:anIndexPath.section]
					allResults:results]
				autorelease]
			animated:YES];
	}
	
	[super tableView:aTableView didSelectRowAtIndexPath:anIndexPath];
}

//
// setLocation:
//
// When the location changes, update the feed.
//
// Parameters:
//    newLocation - the Postcode object to use as the query point
//
- (void)setLocation:(Postcode *)newLocation
{
	if ([location.suburb isEqual:newLocation.suburb])
	{
		return;
	}
	
	[location autorelease];
	location = [newLocation retain];
	
	if (!location)
	{
		[results release];
		results = nil;
		
		[self updateDisplay];
		return;
	}
	
	NSString *escapedSuburb =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
			nil,
			(CFStringRef)location.suburb,
			(CFStringRef)@"",
			(CFStringRef)@"&;?",
			kCFStringEncodingUTF8)
		autorelease];
	NSString *urlString = [NSString stringWithFormat:
		@"http://www.fuelwatch.wa.gov.au/fuelwatch/fuelWatchRSS?Product=%@&Suburb=%@&Surrounding=yes",
		[[[NSUserDefaults standardUserDefaults] objectForKey:@"fuelType"] stringValue],
		escapedSuburb];
	
	if (fetcher)
	{
		[fetcher cancel];
		[fetcher release];
		fetcher = nil;
	}
	
	fetcher =
		[[XMLFetcher alloc]
			initWithURLString:urlString
			xPathQuery:@"//item"
			receiver:self
			action:@selector(responseReceived:)];
	[fetcher start];
	[self updateDisplay];
}

//
// qualifiedAddressStringForResultDictionary:
//
// Generate the fully qualified address string from a result dictionary
//
// Parameters:
//    result - the result dictionary
//
// returns the address, location, WA, Australia.
//
+ (NSString *)qualifiedAddressStringForResultDictionary:(NSDictionary *)result
{
	return [NSString stringWithFormat:@"%@, %@, WA, Australia",
		[result objectForKey:@"address"],
		[result objectForKey:@"location"]];
}

//
// responseReceived:
//
// Receives the response from the XMLFetcher, preprocesses it into the array
// of dictionary format that we want and then updates the dispaly
//
// Parameters:
//    aFetcher - the fetcher returning results
//
- (void)responseReceived:(XMLFetcher *)aFetcher
{
	if (![aFetcher isEqual:fetcher])
	{
		return;
	}
	
	[results release];
	
	results = [[NSMutableArray alloc] initWithCapacity:[fetcher.results count]];
	for (XPathResultNode *fetcherResult in fetcher.results)
	{
		NSArray *nodeChildArray = [fetcherResult childNodes];
		NSMutableDictionary *resultDictionary =
			[[[NSMutableDictionary alloc] initWithCapacity:[nodeChildArray count]] autorelease];
		for (XPathResultNode *childNode in nodeChildArray)
		{
			[resultDictionary
				setObject:[childNode contentString]
				forKey:childNode.name];
		}
		[results addObject:resultDictionary];
	}
	
	[fetcher release];
	fetcher = nil;
	
	[self updateDisplay];

	//
	// Once the results are loaded into the display, look for their locations
	//
	for (NSDictionary *result in results)
	{
		[[LocationsController sharedLocationsController]
			locationForAddress:[ResultsViewController qualifiedAddressStringForResultDictionary:result]
			receiver:self];
	}
}

//
// receiveLocation:fromLocationsController:
//
// When a new location comes from the locations controller, set the "stationLocation"
// on the respective result. We'll need to search for the respective result
// (using the address in the Location) since the respective result is not
// remembered anywhere.
//
// Parameters:
//    aLocation - the new location value
//    aController - the controller that returned the value
//
- (void)receiveLocation:(Location *)aLocation fromLocationsController:(LocationsController *)aController
{
	if (!location)
	{
		return;
	}
	
	NSInteger rowIndex = 0;
	for (NSMutableDictionary *result in results)
	{
		if ([aLocation.address isEqual:
			[ResultsViewController qualifiedAddressStringForResultDictionary:result]])
		{
			[result setObject:aLocation forKey:@"stationLocation"];
			
			if ([self tableView:self.tableView numberOfRowsInSection:0] > rowIndex)
			{
				[self refreshCellForRow:rowIndex inSection:0];
			}
		}
		
		rowIndex++;
	}
}

//
// setGpsLocation:
//
// When the gpsLocation changes, refresh the page at the new gpsLocation
//
// Parameters:
//    newLocation - gpsLocation to apply
//
- (void)setGpsLocation:(CLLocationCoordinate2D)newGpsLocation
{
	gpsLocation = newGpsLocation;
	
	if (usingManualLocation)
	{
		return;
	}
	
	if (!CLLocationCoordinate2DIsValid(gpsLocation))
	{
		self.location = nil;
		return;
	}
	
	self.location =
		[[PostcodesController sharedPostcodesController]
			postcodeClosestToLocation:gpsLocation];
}

//
// textFieldDidEndEditing:
//
// Update when the user edits the postcode field
//
// Parameters:
//    textField - the postcode field
//
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSInteger postcodeValue = [textField.text integerValue];
	if (postcodeValue == 0)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"postcode"];
		self.usingManualLocation = NO;
		[self setGpsLocation:gpsLocation];
		return;
	}
	
	Postcode *postcodeObject = [[PostcodesController sharedPostcodesController] postcodeWithPostcodeValue:postcodeValue];
	if (!postcodeObject)
	{
		//
		// Present a postcode unknown error
		//
		UIAlertView *alert =
			[[UIAlertView alloc]
				initWithTitle:NSLocalizedStringFromTable(@"Postcode Error", @"ResultsView", nil)
				message:NSLocalizedStringFromTable(@"The postcode entered is not in the list of known Western Australian postcodes.", @"ResultsView", nil)
				delegate:self
				cancelButtonTitle:@"OK"
				otherButtonTitles: nil];
		[alert show];    
		[alert release];

		textField.text = nil;
		self.usingManualLocation = NO;

		[self setGpsLocation:gpsLocation];
		return;
	}
	
	[[NSUserDefaults standardUserDefaults]
		setObject:postcodeObject.postcode
		forKey:@"postcode"];
	self.usingManualLocation = YES;
	self.location = postcodeObject;
}

//
// locationFailedWithCode:
//
// Handle an error from the GPS
//
// Parameters:
//    errorCode - either an error from the gpsLocation manager or FVLocationFailedOutsideWA if gpsLocation
//		is not in Western Australia
//
- (void)locationFailedWithCode:(NSInteger)errorCode
{
	if (!gpsLocationFailed)
	{
		gpsLocationFailed = YES;
		
		//
		// Don't show an error or override the gpsLocation if we're using a manually
		// entered gpsLocation
		//
		if (usingManualLocation)
		{
			return;
		}
		
		//
		// Deliberately set an invalid gpsLocation
		//
		self.gpsLocation = CLLocationCoordinate2DMake(1000, 1000);
		
		NSMutableString *errorString = [NSMutableString string];
		switch (errorCode) 
		{
			//
			// We shouldn't ever get an unknown error code, but just in case...
			//
			case FVLocationFailedOutsideWA:
				[errorString appendString:NSLocalizedStringFromTable(@"The gpsLocation reported by the GPS is not in Western Australia.", @"ResultsView", @"Error detail")];
				break;

			//
			// This error code is usually returned whenever user taps "Don't Allow" in response to
			// being told your app wants to access the current gpsLocation. Once this happens, you cannot
			// attempt to get the gpsLocation again until the app has quit and relaunched.
			//
			// "Don't Allow" on two successive app launches is the same as saying "never allow". The user
			// can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
			//
			case kCLErrorDenied:
				[errorString appendString:NSLocalizedStringFromTable(@"Location from GPS denied.", @"ResultsView", nil)];
				break;

			//
			// This error code is usually returned whenever the device has no data or WiFi connectivity,
			// or when the gpsLocation cannot be determined for some other reason.
			//
			// CoreLocation will keep trying, so you can keep waiting, or prompt the user.
			//
			case kCLErrorLocationUnknown:
				[errorString appendString:NSLocalizedStringFromTable(@"Location from GPS reported error.", @"ResultsView", nil)];
				break;
			//
			// We shouldn't ever get an unknown error code, but just in case...
			//
			default:
				[errorString appendString:NSLocalizedStringFromTable(@"Location from GPS failed.", @"ResultsView", nil)];
				break;
		}
		
		[errorString appendString:NSLocalizedStringFromTable(@" You may use a manually entered postcode.", @"ResultsView", nil)];
		
		//
		// Present the error dialog
		//
		UIAlertView *alert =
			[[UIAlertView alloc]
				initWithTitle:NSLocalizedStringFromTable(@"GPS Error", @"ResultsView", nil)
				message:errorString
				delegate:self
				cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ResultsView", @"Dimiss dialog.")
				otherButtonTitles: nil];
		[alert show];    
		[alert release];
	}
}

//
// locationManager:didUpdateToLocation:fromLocation:
//
// Receives gpsLocation updates
//
// Parameters:
//    manager - our gpsLocation manager
//    newLocation - the new gpsLocation
//    oldLocation - gpsLocation previously reported
//
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
	fromLocation:(CLLocation *)oldLocation
{
	const double WA_BOUNDING_BOX_BOTTOM = -37;
	const double WA_BOUNDING_BOX_TOP = -12;
	const double WA_BOUNDING_BOX_LEFT = 110;
	const double WA_BOUNDING_BOX_RIGHT = 129;

#if TARGET_IPHONE_SIMULATOR
	// In simulator, set gpsLocation to WEST PERTH
	newLocation = [[[CLLocation alloc] initWithLatitude:-31.950555 longitude:115.843835] autorelease];
#endif

	if (newLocation.coordinate.latitude < WA_BOUNDING_BOX_BOTTOM ||
		newLocation.coordinate.latitude > WA_BOUNDING_BOX_TOP ||
		newLocation.coordinate.longitude < WA_BOUNDING_BOX_LEFT ||
		newLocation.coordinate.longitude > WA_BOUNDING_BOX_RIGHT ||
		signbit(newLocation.horizontalAccuracy))
	{
		[self locationFailedWithCode:FVLocationFailedOutsideWA];
	}
	else
	{
		gpsLocationFailed = NO;
		self.gpsLocation = newLocation.coordinate;
	}
}

//
// locationManager:didFailWithError:
//
// Handle an error from the gpsLocation manager by calling the locationFailed
// method
//
// Parameters:
//    manager - the gpsLocation manager
//    error - the error assocated with this notification
//
- (void)locationManager:(CLLocationManager *)manager
	didFailWithError:(NSError *)error
{
	[self locationFailedWithCode:[error code]];
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	locationManager.delegate = nil;
	[locationManager release];
	[location release];
	location = nil;


	[super dealloc];
}

@end

