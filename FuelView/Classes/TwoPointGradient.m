//
//  TwoPointGradient.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "TwoPointGradient.h"

CGGradientRef TwoPointGradient(UIColor *startColor, UIColor *endColor)
{
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGFloat backgroundColorComponents[3][4];
	memcpy(
		backgroundColorComponents[0],
		CGColorGetComponents(startColor.CGColor),
		sizeof(CGFloat) * 4);
	memcpy(
		backgroundColorComponents[1],
		CGColorGetComponents(endColor.CGColor),
		sizeof(CGFloat) * 4);
	
	const CGFloat endpointLocations[2] = {0.0, 1.0};
	CGGradientRef gradient =
		CGGradientCreateWithColorComponents(
			colorspace,
			(const CGFloat *)backgroundColorComponents,
			endpointLocations,
			2);
	CFRelease(colorspace);
	
	return gradient;
}

