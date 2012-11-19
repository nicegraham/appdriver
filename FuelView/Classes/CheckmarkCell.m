//
//  CheckmarkCell.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "CheckmarkCell.h"
#import "PageViewController.h"

@implementation CheckmarkCell

//
// selectedRowDataForSection:inPageViewController
//
// Parameters:
//    aSection - the index of the section containing CheckmarkCell compatible rowData
//    aPageViewController - the view controller managing the data
//
// returns the rowData dictionary of the CheckmarkCell that is actually selected
// in the receivers section.
//
+ (NSDictionary *)selectedRowDataForSection:(NSInteger)aSection inPageViewController:(PageViewController *)aPageViewController
{
	NSInteger indexInSection = 0;
	for (NSDictionary *rowData in [aPageViewController allDataInSection:aSection])
	{
		if ([[rowData objectForKey:@"checked"] boolValue])
		{
			return [aPageViewController dataForRow:indexInSection inSection:aSection];
		}

		indexInSection++;
	}
	
	return nil;
}

//
// handleSelectionInTableView:
//
// Performs the appropriate action when the cell is selected
//
- (void)handleSelectionInTableView:(UITableView *)aTableView
{
	[super handleSelectionInTableView:aTableView];

	NSIndexPath *indexPath = [aTableView indexPathForCell:self];
	PageViewController *pageViewController = (PageViewController *)[aTableView delegate];

	NSInteger indexInSection = 0;
	for (NSDictionary *rowData in [pageViewController allDataInSection:indexPath.section])
	{
		if (indexInSection == indexPath.row)
		{
			[rowData setValue:[NSNumber numberWithBool:YES] forKey:@"checked"];
		}
		else
		{
			[rowData setValue:[NSNumber numberWithBool:NO] forKey:@"checked"];
		}
		[pageViewController refreshCellForRow:indexInSection inSection:indexPath.section];
		
		indexInSection++;
	}
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
	
	self.textLabel.text = [dataObject objectForKey:@"label"];
	self.accessoryType = [[dataObject objectForKey:@"checked"] boolValue] ?
		UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
