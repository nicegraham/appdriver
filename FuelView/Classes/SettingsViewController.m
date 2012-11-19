//
//  SettingsViewController.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "SettingsViewController.h"
#import "CheckmarkCell.h"
#import "ResultsViewController.h"
#import "FuelViewAppDelegate.h"

@implementation SettingsViewController

//
// fuelTypes
//
// returns an array of fuel type values and labels
//
+ (NSArray *)fuelTypes
{
	NSArray *fuelTypes =
		[NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"ULP", @"SettingsViewController", nil), @"label",
				[NSNumber numberWithInteger:FVFuelTypeUnleaded], @"value",
			nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"Premium ULP", @"SettingsViewController", nil), @"label",
				[NSNumber numberWithInteger:FVFuelTypePremium], @"value",
			nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"Diesel", @"SettingsViewController", nil), @"label",
				[NSNumber numberWithInteger:FVFuelTypeDiesel], @"value",
			nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"LPG", @"SettingsViewController", nil), @"label",
				[NSNumber numberWithInteger:FVFuelTypeLPG], @"value",
			nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"98 RON", @"SettingsViewController", nil), @"label",
				[NSNumber numberWithInteger:FVFuelType98RON], @"value",
			nil],
			[NSDictionary dictionaryWithObjectsAndKeys:
				NSLocalizedStringFromTable(@"B20", @"SettingsViewController", nil), @"label",
				[NSNumber numberWithInteger:FVFuelTypeB20], @"value",
			nil],
		nil];
	return fuelTypes;
}

//
// currentFuelTypeLabel
//
// returns the label from the fuelTypes array corresponding to the current fuelType
//	preference
//
+ (NSString *)currentFuelTypeLabel
{
	for (NSDictionary *fuelType in [self fuelTypes])
	{
		if ([[fuelType objectForKey:@"value"] isEqual:[[NSUserDefaults standardUserDefaults] objectForKey:@"fuelType"]])
		{
			return [fuelType objectForKey:@"label"];
		}
	}
	return nil;
}

//
// nibName
//
// returns the name of the NIB file from which this view is loaded
//
- (NSString *)nibName
{
	return @"SettingsView";
}

//
// viewDidLoad
//
// Constructs a single, static row.
//
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	fuelTypeOnLoad = [[[NSUserDefaults standardUserDefaults] objectForKey:@"fuelType"] integerValue];
	
	[self addSectionAtIndex:0 withAnimation:UITableViewRowAnimationNone];
	
	for (NSDictionary *fuelType in [SettingsViewController fuelTypes])
	{
		[self
			appendRowToSection:0
			cellClass:[CheckmarkCell class]
			cellData:
				[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[fuelType objectForKey:@"label"], @"label",
					[fuelType objectForKey:@"value"], @"value",
					[NSNumber numberWithInteger:fuelTypeOnLoad == [[fuelType objectForKey:@"value"] integerValue]], @"checked",
				nil]
			withAnimation:UITableViewRowAnimationNone];
	}
}

//
// dismiss:
//
// Invoked when the "Done" button is pressed. Save settings and animate out.
//
// Parameters:
//    sender - ignored
//
- (void)dismiss:(id)sender
{
	NSString *rowValue = [[CheckmarkCell selectedRowDataForSection:0 inPageViewController:self] objectForKey:@"value"];
	if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"fuelType"] isEqual:rowValue])
	{
		[[NSUserDefaults standardUserDefaults] setObject:rowValue forKey:@"fuelType"];
	}
	
	if ([rowValue integerValue] != fuelTypeOnLoad)
	{
		FuelViewAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		ResultsViewController *resultsViewController = (ResultsViewController *)[[[appDelegate navigationController] viewControllers] objectAtIndex:0];
		[resultsViewController refresh:nil];
	}

	UIWindow *window = self.view.window;

	[self dismissModalViewControllerAnimated:NO];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
	
	[UIView commitAnimations];
}

//
// tableView:titleForHeaderInSection:
//
// Header text for the three sections
//
// Parameters:
//    aTableView - the table
//    section - the section for which header text should be returned
//
// returns the header text for the appropriate section
//
- (NSString *)tableView:(UITableView *)aTableView
	titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return NSLocalizedStringFromTable(@"Fuel Type", @"SettingsViewController", nil);
	}

	return nil;
}

@end
