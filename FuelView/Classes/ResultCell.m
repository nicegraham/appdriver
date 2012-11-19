//
//  ResultCell.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "ResultCell.h"
#import "ResultCellBackground.h"
#import "ResultView.h"
#import "PageCellBackground.h"

@implementation ResultCell

//
// nibName
//
// returns the name of the nib file from which the cell is loaded.
//
+ (NSString *)nibName
{
	return @"ResultCell";
}

//
// pageCellBackgroundClass
//
// returns the subclass of PageCellBackground used for drawing the background
//
+ (Class)pageCellBackgroundClass
{
	return [ResultCellBackground class];
}

//
// configureForData:tableView:indexPath:
//
// Invoked when the cell is given data. All fields should be updated to reflect
// the data.
//
// Parameters:
//    dataObject - the dataObject (can be nil for data-less objects)
//    aTableView - the tableView (passed in since the cell may not be in the
//		hierarchy)
//    anIndexPath - the indexPath of the cell
//
- (void)configureForData:(id)dataObject
	tableView:(UITableView *)aTableView
	indexPath:(NSIndexPath *)anIndexPath
{
	//
	// Don't forget to invoke the super method to get the custom cell drawing
	//
	[super configureForData:dataObject tableView:aTableView indexPath:anIndexPath];
	
	[(PageCellBackground *)self.backgroundView setBackgroundColorTop:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]];
	[(PageCellBackground *)self.backgroundView setBackgroundColorBottom:nil];
	[(PageCellBackground *)self.backgroundView setStrokeColor:nil];

	[(PageCellBackground *)self.selectedBackgroundView setStrokeColor:nil];

	
	[(ResultView *)self.contentView setResult:dataObject];
}

@end
