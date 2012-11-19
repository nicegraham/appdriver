//
//  MapViewController.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "MapViewController.h"
#import "ResultCell.h"
#import "Location.h"
#import "ResultsViewController.h"
#import "FuelViewAppDelegate.h"
#import "Postcode.h"

//
// Adapter category on NSDictionary to make it obey the MKAnnotation protocol
//
@implementation NSDictionary (Annotations)

- (NSString *)title
{
	return [NSString stringWithFormat:@"%@: %@",
		[self objectForKey:@"trading-name"],
		[self objectForKey:@"price"]];
}

- (NSString *)subtitle
{
	return [self objectForKey:@"description"];
}

- (CLLocationCoordinate2D)coordinate
{
	return CLLocationCoordinate2DMake(
		[[(Location *)[self objectForKey:@"stationLocation"] latitude] floatValue],
		[[(Location *)[self objectForKey:@"stationLocation"] longitude] floatValue]);
}

@end

@implementation MapViewController

//
// init
//
// Init method for the object.
//
- (id)initWithSelectedResult:(NSDictionary *)aResult
	allResults:(NSArray *)allResults
{
	self = [super init];
	if (self != nil)
	{
		selectedResult = [aResult retain];
		results = [allResults retain];
	}
	return self;
}

//
// nibName
//
// returns the name of the NIB file from which this view is loaded
//
- (NSString *)nibName
{
	return @"MapView";
}

//
// title
//
// returns the navigation item title
//
- (NSString *)title
{
	ResultsViewController *resultsViewController =
		(ResultsViewController *)[((FuelViewAppDelegate *)[UIApplication sharedApplication].delegate).navigationController.viewControllers objectAtIndex:0];

	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"%@ area", @"MapViewController", nil), resultsViewController.location.suburb];
}

//
// showInMaps:
//
// Opens the Maps app either showing a path from the current location to the
// station or (if a manual postcode was used) simply centered on the selected
// station.
//
// Parameters:
//    sender - the button (ignored)
//
- (IBAction)showInMaps:(id)sender
{
	ResultsViewController *resultsViewController =
		(ResultsViewController *)[((FuelViewAppDelegate *)[UIApplication sharedApplication].delegate).navigationController.viewControllers objectAtIndex:0];
	
	NSString *sourceLocation;
	NSString *queryType;
	if (resultsViewController.usingManualLocation)
	{
		queryType = @"q";
		sourceLocation = @"";
	}
	else
	{
		queryType = @"daddr";
		sourceLocation =
			[NSString stringWithFormat:@"&saddr=%f,+%f",
				resultsViewController.gpsLocation.latitude,
				resultsViewController.gpsLocation.longitude];
	}
	
	NSString *urlString =
		[NSString stringWithFormat:
			@"http://maps.google.com/maps?%@=%@%@",
			queryType,
			[(NSString *)CFURLCreateStringByAddingPercentEscapes(
				nil,
				(CFStringRef)[ResultsViewController qualifiedAddressStringForResultDictionary:selectedResult],
				nil,
				(CFStringRef)@"&=",
				kCFStringEncodingUTF8)
			autorelease],
			sourceLocation];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

//
// highlightResult
//
// Centers on and selects the selectedResult
//
- (void)highlightResult:(BOOL)animated
{
	//
	// It's not guaranteed that the location exists at this point (we may be
	// waiting on a Google Maps request). If location doesn't exist, the user
	// can still use the "Show In Maps" button but the MKMapView is going to be
	// pretty pointless.
	//
	Location *location = [selectedResult objectForKey:@"stationLocation"];
	if (location)
	{
		const double MapViewAperture = 0.05;
		[mapView setRegion:
			MKCoordinateRegionMake(CLLocationCoordinate2DMake([location.latitude floatValue], [location.longitude floatValue]),
				MKCoordinateSpanMake(MapViewAperture, MapViewAperture))];

		[mapView selectAnnotation:(id<MKAnnotation>)selectedResult animated:animated];
	}
}

//
// updateTableForSelectedResult
//
// Shows the selectedResult in the single row table view at the top
//
- (void)updateTableForSelectedResult
{
	[self emptySectionAtIndex:0 withAnimation:UITableViewRowAnimationFade];
	[self
		appendRowToSection:0
		cellClass:[ResultCell class]
		cellData:selectedResult
		withAnimation:UITableViewRowAnimationFade];
}

//
// mapView:didSelectAnnotationView:
//
// Changes the selectedResult to the annotation of the selected view and updates
// the table
//
// Parameters:
//    aMapView - the map view
//    aView - the selected annotation view
//
- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)aView
{
	[selectedResult autorelease];
	selectedResult = [(NSDictionary *)[aView annotation] retain];

	[self updateTableForSelectedResult];
}

//
// tableView:didSelectRowAtIndexPath:
//
// Handle row selection
//
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{
	[self highlightResult:YES];
	[super tableView:aTableView didSelectRowAtIndexPath:anIndexPath];
}

//
// viewDidLoad
//
// On load, refreshes the view (to load the rows)
//
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self addSectionAtIndex:0 withAnimation:UITableViewRowAnimationNone];
	[self updateTableForSelectedResult];
	
	for (NSDictionary *aResult in results)
	{
		Location *resultLocation = [aResult objectForKey:@"stationLocation"];
		if (resultLocation)
		{
			[mapView addAnnotation:(id<MKAnnotation>)aResult];
		}
	}
	
	// Notice here: the parameter to highlightResult: is supposed to be a BOOL but
	// we're passing a nil object. We're relying on the fact that the two have
	// the same binary representation.
	[self performSelector:@selector(highlightResult:) withObject:nil afterDelay:0];
}

//
// viewDidUnload
//
// Clear mapView outlet so that it is not uninitialized when we hit the dealloc
// method.
//
- (void)viewDidUnload
{
	mapView = nil;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	mapView.delegate = nil;
	
	[selectedResult release];
	[results release];
	
	[super dealloc];
}


@end
