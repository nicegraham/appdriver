//
//  ResultCellBackground.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "ResultCellBackground.h"
#import "ResultCell.h"
#import "TwoPointGradient.h"
#import <QuartzCore/QuartzCore.h>

@implementation ResultCellBackground

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
	if (!backgroundColorBottom)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		rect = CGRectInset(self.bounds, 2, 1);
		rect.size.height -= 1;
		
		ResultCell *cell = (ResultCell *)self.superview;
		
		CGContextSaveGState(context);
		CGContextClipToRect(context, rect);
		CGContextDrawLinearGradient(
			context,
			TwoPointGradient(
				[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:cell.selected ? 0.2 : 1.0],
				[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:cell.selected ? 0.2 : 1.0]),
			CGPointMake(rect.origin.x, rect.origin.y),
			CGPointMake(rect.origin.x, rect.origin.y + rect.size.height),
			0);
		CGContextRestoreGState(context);
		
		rect = CGRectInset(rect, 0.5, 0.5);
		CGContextSetRGBStrokeColor(context, 0.4, 0.4, 0.4, 1.0);
		CGContextStrokeRect(context, rect);
	}
}

@end
