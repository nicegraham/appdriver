//
//  NSManagedObjectContext+FetchAdditions.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 26/02/07.
//  Copyright 2007 Matt Gallagher. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (FetchAdditions)

- (NSSet *)fetchObjectSetForRequest:(NSFetchRequest *)request;
- (NSArray *)fetchObjectArrayForRequest:(NSFetchRequest *)request;
- (NSArray *)fetchObjectArrayForEntityName:(NSString *)newEntityName
	withPredicate:(id)stringOrPredicate, ...;
- (NSSet *)fetchObjectSetForEntityName:(NSString *)newEntityName
	withPredicate:(id)stringOrPredicate, ...;
- (id)fetchSingleObjectForEntityName:(NSString *)newEntityName
	withPredicate:(id)stringOrPredicate, ...;
- (NSSet *)fetchObjectSetForEntityName:(NSString *)newEntityName
	prefetchingPaths:(NSArray *)prefetchPaths
	withPredicate:(id)stringOrPredicate, ...;
- (NSArray *)fetchObjectArrayForEntityName:(NSString *)newEntityName
	prefetchingPaths:(NSArray *)prefetchPaths
	withPredicate:(id)stringOrPredicate, ...;
- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)newEntityName;
- (NSFetchRequest *)fetchRequestForEntityName:(NSString *)newEntityName
	withPredicate:(id)stringOrPredicate, ...;
- (NSManagedObject *)objectWithURI:(NSURL *)url;

@end
