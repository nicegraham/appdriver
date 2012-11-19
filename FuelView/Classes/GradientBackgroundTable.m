//
//  GradientBackgroundTable.m
//  TableDesignRevisited
//
//  Created by Matt Gallagher on 2010/10/03.
//  Copyright 2010 Matt Gallagher. All rights reserved.
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

#import "GradientBackgroundTable.h"
#import "TwoPointGradient.h"
#import <QuartzCore/QuartzCore.h>

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

@implementation GradientBackgroundTable

@synthesize backgroundColorTop;
@synthesize backgroundColorBottom;

//
// initWithFrame:style:
//
// Init method for the object.
//
- (id)initWithFrame:(CGRect)aFrame style:(UITableViewStyle)aStyle
{
	self = [super initWithFrame:aFrame style:aStyle];
	if (self != nil)
	{
		self.backgroundColor = [UIColor clearColor];
		self.opaque = YES;
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
	}
	return self;
}


//
// layoutSubviews
//
// Find the default layer and remove it.
//
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	for (CALayer *layer in self.layer.sublayers)
	{
		if (CGRectEqualToRect([self.layer bounds], [layer frame]))
		{
			layer.hidden = YES;
		}
	}
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	if (self.opaque)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		rect = self.bounds;
		
		if (!backgroundColorTop)
		{
			self.backgroundColorTop = [UIColor colorWithRed:0.90 green:0.92 blue:0.95 alpha:1.0];
			self.backgroundColorBottom = [UIColor colorWithRed:0.50 green:0.52 blue:0.55 alpha:1.0];
		}
		
		if (!backgroundColorBottom)
		{
			CGContextSetFillColorWithColor(context, backgroundColorTop.CGColor);
			CGContextFillRect(context, rect);
		}
		else
		{
			CGContextDrawLinearGradient(
				context,
				TwoPointGradient(backgroundColorTop, backgroundColorBottom),
				CGPointMake(rect.origin.x, rect.origin.y),
				CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
				0);
		}
	}
}

@end
