//
//  SettingsViewController.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "PageViewController.h"

@interface SettingsViewController : PageViewController
{
	NSInteger fuelTypeOnLoad;
}

+ (NSArray *)fuelTypes;
+ (NSString *)currentFuelTypeLabel;
- (void)dismiss:(id)sender;

@end

enum
{
	FVFuelTypeUnleaded = 1,
	FVFuelTypePremium = 2,
	FVFuelTypeDiesel = 3,
	FVFuelTypeB20 = 4,
	FVFuelTypeLPG = 5,
	FVFuelType98RON = 6
};
