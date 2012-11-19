//
//  MapViewController.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "PageViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController : PageViewController <MKMapViewDelegate>
{
	NSDictionary *selectedResult;
	NSArray *results;
	
	IBOutlet MKMapView *mapView;
}

- (id)initWithSelectedResult:(NSDictionary *)aResult
	allResults:(NSArray *)allResults;

- (IBAction)showInMaps:(id)sender;

@end
