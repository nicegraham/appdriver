//
//  HTTPFetcher.h
//  FuelView
//
//  Created by Matt Gallagher on 2011/05/30.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//

@interface HTTPFetcher : NSObject
#if TARGET_OS_IPHONE		
	<UITextFieldDelegate>
#endif
{
	id receiver;
	SEL action;

	NSURLConnection *connection;
	NSMutableData *data;
	NSURLAuthenticationChallenge *challenge;

	NSURLRequest *urlRequest;
	NSInteger failureCode;
	BOOL showAlerts;
	BOOL showAuthentication;
	NSDictionary *responseHeaderFields;
	void *context;
	
#if TARGET_OS_IPHONE		
	UITextField *usernameField;
	UITextField *passwordField;
	UIAlertView *passwordAlert;
#endif
}

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSURLRequest *urlRequest;
@property (nonatomic, readonly) NSDictionary *responseHeaderFields;
@property (nonatomic, readonly) NSInteger failureCode;
@property (nonatomic, assign) BOOL showAlerts;
@property (nonatomic, assign) BOOL showAuthentication;
@property (nonatomic, assign) void *context;

- (id)initWithURLRequest:(NSURLRequest *)aURLRequest
	receiver:(id)aReceiver
	action:(SEL)receiverAction;
- (id)initWithURLString:(NSString *)aURLString
	receiver:(id)aReceiver
	action:(SEL)receiverAction;
- (id)initWithURLString:(NSString *)aURLString
	timeout:(NSTimeInterval)aTimeoutInterval
	cachePolicy:(NSURLCacheStoragePolicy)aCachePolicy
	receiver:(id)aReceiver
	action:(SEL)receiverAction;
- (void)start;
- (void)cancel;
- (void)close;
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection;

@end
