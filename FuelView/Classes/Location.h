//
//  Location.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/21.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Location : NSManagedObject
{

}

@end

@interface Location (CoreDataGeneratedAccessors)

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *address;

@end
