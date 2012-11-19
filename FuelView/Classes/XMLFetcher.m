//
//  XMLFetcher.m
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

#import "XMLFetcher.h"
#import "XPathResultNode.h"

@implementation XMLFetcher

@synthesize xPathQuery;
@synthesize results;

//
// initWithURLString:receiver:action
//
// Init method for the object.
//
- (id)initWithURLString:(NSString *)aURLString
	xPathQuery:(NSString *)query
	receiver:(id)aReceiver
	action:(SEL)receiverAction
{
	self = [super initWithURLString:aURLString receiver:aReceiver action:receiverAction];
	if (self != nil)
	{
		xPathQuery = [query copy];
	}
	return self;
}

//
// close
//
// Cancel the connection and release all connection data. Does not release
// the result if already generated (this is only released when the class is
// released).
//
// Will send the response if the receiver is non-nil. But always releases the
// receiver when done.
//
- (void)close
{
	[super close];
	
	[results release];
	results = nil;
}

//
// connectionDidFinishLoading:
//
// When the connection is complete, parse the JSON and reconstruct
//
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	results = [[XPathResultNode nodesForXPathQuery:xPathQuery onXML:data] retain];

#if TARGET_OS_IPHONE		
	if (results == nil && showAlerts)
	{
		UIAlertView *alert =
			[[UIAlertView alloc]
				initWithTitle:NSLocalizedStringFromTable(@"Connection Error", @"XMLFetcher", @"Title for error dialog")
				message:NSLocalizedStringFromTable(@"Server response was not understood.", @"XMLFetcher", @"Detail for an error dialog.")
				delegate:nil
				cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"XMLFetcher", @"Standard dialog dismiss button")
				otherButtonTitles:nil];
		[alert show];    
		[alert release];
	}
#endif
	
	//
	// Invoke the super method which will invoke the response
	//
	[super connectionDidFinishLoading:aConnection];
}

@end
