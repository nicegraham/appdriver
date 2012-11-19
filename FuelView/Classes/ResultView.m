//
//  ResultView.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "ResultView.h"
#import "TwoPointGradient.h"
#import "ResultCell.h"
#import "GlossGradients.h"
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import "ResultsViewController.h"
#import "FuelViewAppDelegate.h"

@implementation ResultView

@synthesize result;

//
// setResult:
//
// Force a redisplay when the result dictionary is changed
//
// Parameters:
//    newResult - the new result dictionary
//
- (void)setResult:(NSDictionary *)newResult
{
	[result autorelease];
	result = [newResult copy];
	[self setNeedsDisplay];
}

//
// layoutSubviews
//
// Force a redisplay when the view is relayed out
//
- (void)layoutSubviews
{
	[super layoutSubviews];
	[self setNeedsDisplay];
}

//
// kilometersBetweenFirstLocation:andSecondLocation:
//
// Calculate the distance between two locations assuming they're both at
// 30 longitude, 30 latitude (roughly the center of WA).
//
// Parameters:
//    firstLocation - one location
//    secondLocation - the other location
//
// returns the distance in kilometers
//
+ (float)kilometersBetweenFirstLocation:(CLLocationCoordinate2D)firstLocation
	andSecondLocation:(CLLocationCoordinate2D)secondLocation
{
	const float DISTANCE_PER_DEGREE_LATITUDE = 110.8524248; // valid at 30 degrees latitude
	const float DISTANCE_PER_DEGREE_LONGITUDE = 96.48624756; // again, valid at 30 degrees latitude
	
	float xDistance = DISTANCE_PER_DEGREE_LATITUDE * (firstLocation.latitude - secondLocation.latitude);
	float yDistance = DISTANCE_PER_DEGREE_LONGITUDE * (firstLocation.longitude - secondLocation.longitude);
	
	return sqrtf(xDistance * xDistance + yDistance * yDistance);
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat textHorizontalOrigin = 97;
	CGFloat textWidth = self.bounds.size.width -  textHorizontalOrigin - 8;
	
	NSString *stationName = [result objectForKey:@"trading-name"];
	CGContextSetRGBFillColor(context, 0, 0, 0, 1);
	[stationName
		drawAtPoint:CGPointMake(textHorizontalOrigin, 13)
		forWidth:textWidth
		withFont:[UIFont systemFontOfSize:18]
		lineBreakMode:UILineBreakModeTailTruncation];

	NSString *streetAddress = [result objectForKey:@"address"];
	CGContextSetRGBFillColor(context, 0.3, 0.3, 0.3, 1);
	[streetAddress
		drawAtPoint:CGPointMake(textHorizontalOrigin, 42)
		forWidth:textWidth
		withFont:[UIFont systemFontOfSize:13]
		lineBreakMode:UILineBreakModeTailTruncation];

	NSString *suburbName = [result objectForKey:@"location"];
	[suburbName
		drawAtPoint:CGPointMake(textHorizontalOrigin, 60)
		forWidth:textWidth
		withFont:[UIFont systemFontOfSize:13]
		lineBreakMode:UILineBreakModeTailTruncation];
	
	CGContextSetRGBStrokeColor(context, 0, 0.25, 1, 1);
	CGContextMoveToPoint(context, textHorizontalOrigin, 40.5);
	CGContextAddLineToPoint(context, textHorizontalOrigin + textWidth, 40.5);
	CGContextStrokePath(context);
	
	Location *resultLocation = [result objectForKey:@"stationLocation"];
	NSString *centsPerLitre = NSLocalizedStringFromTable(@"cents per litre", @"ResultView", nil);
	float distance = 0;
	UIColor *gradientColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
	
	ResultsViewController *resultsViewController =
		(ResultsViewController *)[((FuelViewAppDelegate *)[UIApplication sharedApplication].delegate).navigationController.viewControllers objectAtIndex:0];
	if (resultLocation &&
		!resultsViewController.usingManualLocation &&
		CLLocationCoordinate2DIsValid(resultsViewController.gpsLocation))
	{
		distance = [ResultView
			kilometersBetweenFirstLocation:
				CLLocationCoordinate2DMake(
					[resultLocation.latitude floatValue],
					[resultLocation.longitude floatValue])
			andSecondLocation:resultsViewController.gpsLocation];
		centsPerLitre = [NSString stringWithFormat:
			NSLocalizedStringFromTable(@"%.1f km away", @"ResultView", nil), distance];
		
		float angle = M_PI_2 * exp(-0.6 * (distance - 1.0));
		if (angle > M_PI_2)
		{
			angle = M_PI_2;
		}
		if (angle < 0)
		{
			angle = 0;
		}
		
		gradientColor = [UIColor colorWithRed:MIN(1.2 * cos(angle), 0.85) green:MIN(1.2 * sin(angle), 0.85) blue:0.0 alpha:1.0];
	}
	
	DrawGlossGradientInContext(context, gradientColor, CGRectMake(10, 60, 80, 20));
	CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 1);
	[centsPerLitre drawAtPoint:CGPointMake(14, 62) withFont:[UIFont systemFontOfSize:12]];
	
	DrawGlossGradientInContext(
		context,
		[UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0],
		CGRectMake(10, 10, 80, 50));

	NSString *price = [result objectForKey:@"price"];
	if ([price length] == 4)
	{
		price = [@"0" stringByAppendingString:price];
	}
	
	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.25);
	for (int i = 0; i < 4; i++)
	{
		NSString *digit = @"0";
		NSInteger digitIndex = (i == 3 ? 4 : i);
		if ([price length] > digitIndex)
		{
			digit = [price substringWithRange:NSMakeRange(digitIndex, 1)];
		}
		[digit drawAtPoint:CGPointMake(12 + i * 20, 18) withFont:[UIFont systemFontOfSize:28]];
		
		if (i != 3)
		{
			CGContextMoveToPoint(context, 9.5 + (i + 1) * 20, 10);
			CGContextAddLineToPoint(context, 9.5 + (i + 1) * 20, 60);
			CGContextStrokePath(context);
		}
	}
	CGContextFillEllipseInRect(context, CGRectMake(68, 34, 3, 3));
}

//
// dealloc
//
// Release instance memory.
//
- (void)dealloc
{
	[result release];
	result = nil;

    [super dealloc];
}

@end
