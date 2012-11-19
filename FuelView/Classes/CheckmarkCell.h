//
//  CheckmarkCell.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "PageCell.h"

@interface CheckmarkCell : PageCell
{

}

+ (NSDictionary *)selectedRowDataForSection:(NSInteger)aSection inPageViewController:(PageViewController *)aPageViewController;

@end
