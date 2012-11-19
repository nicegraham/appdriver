//
//  XMLFetcher.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "HTTPFetcher.h"
#import "XPathResultNode.h"

@interface XMLFetcher : HTTPFetcher
{
	NSArray *results;
	NSString *xPathQuery;
}

@property (nonatomic, copy, readonly) NSString *xPathQuery;
@property (nonatomic, retain, readonly) NSArray *results;

- (id)initWithURLString:(NSString *)aURLString
	xPathQuery:(NSString *)query
	receiver:(id)aReceiver
	action:(SEL)receiverAction;

@end
