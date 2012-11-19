//
//  PageCellBackground.m
//  TableDesignRevisited
//
//  Created by Matt Gallagher on 27/04/09.
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

#import "PageCellBackground.h"
#import "PageViewController.h"
#import "RoundRect.h"
#import "TwoPointGradient.h"

@implementation PageCellBackground

@synthesize position;
@synthesize strokeColor;
@synthesize backgroundColorTop;
@synthesize backgroundColorBottom;

//
// positionForIndexPath:inTableView:
//
// Parameters:
//    anIndexPath - the indexPath of a cell
//    aTableView; - the table view for the cell
//
// returns the PageCellGroupPosition for the indexPath in the table view
//
+ (PageCellGroupPosition)positionForIndexPath:(NSIndexPath *)anIndexPath
	inTableView:(UITableView *)aTableView;
{
	PageCellGroupPosition result;

	if ([anIndexPath row] != 0)
	{
		result = PageCellGroupPositionMiddle;
	}
	else
	{
		result = PageCellGroupPositionTop;
	}
	
	PageViewController *pageViewController =
		(PageViewController *)[aTableView delegate];	
	if ([anIndexPath row] ==
		[pageViewController tableView:aTableView numberOfRowsInSection:anIndexPath.section] - 1)
	{
		if (result == PageCellGroupPositionTop)
		{
			result = PageCellGroupPositionTopAndBottom;
		}
		else
		{
			result = PageCellGroupPositionBottom;
		}
	}
	return result;
}

//
// init
//
// Init method for the object.
//
- (id)initGrouped:(BOOL)isGrouped
{
	self = [super init];
	if (self != nil)
	{
		groupBackground = isGrouped;
		self.strokeColor = [UIColor blackColor];
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		[self useDefaultColors];
	}
	return self;
}

//
// useDefaultColors
//
// Sets the background colors to the default colors
//
- (void)useDefaultColors
{
	self.backgroundColorTop = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
	self.backgroundColorBottom = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0];
}
//
// useSelectedColors
//
// Sets the background colors to the default selection colors
//
- (void)useSelectedColors
{
	self.backgroundColorTop = [UIColor colorWithRed:0.1 green:0.6 blue:1.0 alpha:1.0];
	self.backgroundColorBottom = [UIColor colorWithRed:0.1 green:0.25 blue:1.0 alpha:1.0];
}

//
// layoutSubviews
//
// On rotation/resize/rescale, we need to redraw.
//
- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self setNeedsDisplay];
}

//
// setPosition:
//
// Makes certain the view gets redisplayed when the position changes
//
// Parameters:
//    aPosition - the new position
//
- (void)setPosition:(PageCellGroupPosition)aPosition
{
	if (position != aPosition)
	{
		position = aPosition;
		[self setNeedsDisplay];
	}
}

//
// drawRect:
//
// Draw the view.
//
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	rect = self.bounds;
	
	const CGFloat PageCellBackgroundRadius = 10.0;
	if (groupBackground)
	{
		if (position != PageCellGroupPositionTop &&
			position != PageCellGroupPositionTopAndBottom)
		{
			rect.origin.y -= PageCellBackgroundRadius;
			rect.size.height += PageCellBackgroundRadius;
		}
		
		if (position != PageCellGroupPositionBottom && position != PageCellGroupPositionTopAndBottom)
		{
			rect.size.height += PageCellBackgroundRadius;
		}
	}
	
	CGPathRef roundRectPath;
	
	if (groupBackground)
	{
		CGRect pathRect = CGRectInset(rect, 0.5, 0.5);
		roundRectPath = NewPathWithRoundRect(pathRect, PageCellBackgroundRadius);
		
		CGContextSaveGState(context);
		CGContextAddPath(context, roundRectPath);
		CGContextClip(context);
	}
	
	if (!backgroundColorTop)
	{
		[self useDefaultColors];
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
			TwoPointGradient(
				backgroundColorTop,
				backgroundColorBottom),
			CGPointMake(rect.origin.x, rect.origin.y),
			CGPointMake(rect.origin.x, rect.origin.y + rect.size.height),
			0);
	}
	
	if (!strokeColor)
	{
		return;
	}
	
	if (groupBackground)
	{
		CGContextRestoreGState(context);

		CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
		CGContextAddPath(context, roundRectPath);
		CGContextSetLineWidth(context, 1.0);
		CGContextStrokePath(context);
		
		CGPathRelease(roundRectPath);
	
		if (position != PageCellGroupPositionTop && position != PageCellGroupPositionTopAndBottom)
		{
			rect.origin.y += PageCellBackgroundRadius;
			rect.size.height -= PageCellBackgroundRadius;

			CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
			CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
			CGContextStrokePath(context);
		}
	}
	else
	{
		CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
		CGContextSetLineWidth(context, 1.0);
		CGContextMoveToPoint(context, rect.origin.x - 0.5, rect.origin.y + rect.size.height);
		CGContextAddLineToPoint(context, rect.origin.x + rect.size.width + 0.5, rect.origin.y + rect.size.height);
		CGContextStrokePath(context);
	}
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[strokeColor release];

	[super dealloc];
}

@end





