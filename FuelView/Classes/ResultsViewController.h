//
//  ResultsViewController.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "PageViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationsController.h"

@class XMLFetcher;
@class Postcode;

@interface ResultsViewController : PageViewController <CLLocationManagerDelegate, LocationReceiver>
{
	IBOutlet UITextField *postcodeField;
	
	CLLocationManager *locationManager;
	CLLocationCoordinate2D gpsLocation;
	BOOL gpsLocationFailed;
	BOOL usingManualLocation;

	Postcode *location;
	
	XMLFetcher *fetcher;
	NSMutableArray *results;
}

@property (nonatomic, assign) BOOL usingManualLocation;
@property (nonatomic, retain) Postcode *location;
@property (nonatomic, assign) CLLocationCoordinate2D gpsLocation;

+ (NSString *)qualifiedAddressStringForResultDictionary:(NSDictionary *)result;
- (IBAction)showSettings:(id)sender;

@end
