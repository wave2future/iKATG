//	
//	Push.m
//	
//	Created by Doug Russell.
//	
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  

#import "Push.h"
#import "PushKeys.h"

static	Push	*	sharedPush	=	nil;

@interface Push ()
@property (nonatomic, retain)	NSString		*	applicationKey;
@property (nonatomic, retain)	NSString		*	applicationSecret;
@property (nonatomic, retain)	NSURLConnection	*	tokenConnection;
@property (nonatomic, retain)	NSURLConnection	*	tagConnection;
@property (nonatomic, retain)	NSURLConnection	*	untagConnection;
@end

@interface Push (Private)
- (NSURLRequest *)sendRequest;
- (NSURLRequest *)tagRequest:(NSString *)tag;
- (NSURLRequest *)untagRequest:(NSString *)tag;
- (NSString *)deviceUUID;
- (NSString *)bundleIdentifier;
- (NSString *)bundleVersion;
- (void)releasePush;
+ (NSString*)base64forData:(NSData*)theData;
@end

@implementation Push
@synthesize	delegate			=	_delegate;
@synthesize	applicationKey		=	_applicationKey;
@synthesize	applicationSecret	=	_applicationSecret;
@synthesize	deviceAlias			=	_deviceAlias;
@synthesize	deviceToken			=	_deviceToken;
@synthesize	tokenConnection		=	_tokenConnection;
@synthesize	tagConnection		=	_tagConnection;
@synthesize	untagConnection		=	_untagConnection;

/******************************************************************************/
#pragma mark -
#pragma mark Setup
#pragma mark -
/******************************************************************************/
+ (Push *)sharedPush
{
	@synchronized(self)
	{
		if (sharedPush == nil)
			sharedPush	=	[[self alloc] init];
	}
	return sharedPush;
}
- (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types
{
#ifdef DEVELOPMENTBUILD
	if ([[[UIDevice currentDevice] model] compare: @"iPhone Simulator"] == NSOrderedSame)
		NSLog(@"ERROR: Remote notifications are not supported in the simulator.");
	else
#endif
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
}
- (void)unregisterForRemoteNotifications
{
#ifdef DEVELOPMENTBUILD
	if ([[[UIDevice currentDevice] model] compare: @"iPhone Simulator"] == NSOrderedSame)
		NSLog(@"ERROR: Remote notifications are not supported in the simulator.");
	else
#endif
		[[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
/******************************************************************************/
#pragma mark -
#pragma mark Send Registration
#pragma mark -
/******************************************************************************/
- (void)send
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible	=	YES;
	
	NSURLRequest	*	request						=	[self sendRequest];
	
	if ([NSURLConnection canHandleRequest:request])
	{
		NSURLConnection			*	connection		=	nil;
		connection									=	[NSURLConnection connectionWithRequest:request delegate:self];
		if (connection != nil)
		{
			self.tokenConnection					=	connection;
			[self.tokenConnection start];
		}
		else
		{ // Unable to make connection
			NSError				*	error			=	[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
			if ([(NSObject *)self.delegate respondsToSelector:@selector(pushNotificationRegisterFailed:)])
				[self.delegate pushNotificationRegisterFailed:error];
		}
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Tagging
#pragma mark -
/******************************************************************************/
- (void)tag:(NSString *)tag
{
	NSURLRequest	*	request						=	[self tagRequest:tag];
	
	if ([NSURLConnection canHandleRequest:request])
	{
		NSURLConnection			*	connection		=	nil;
		connection									=	[NSURLConnection connectionWithRequest:request delegate:self];
		if (connection != nil)
		{
			self.tagConnection						=	connection;
			[self.tagConnection start];
		}
		else
		{ // Unable to make connection
			NSError				*	error			=	[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
			if ([(NSObject *)self.delegate respondsToSelector:@selector(tagRegisterFailed:)])
				[self.delegate tagRegisterFailed:error];
		}
	}
}
- (void)untag:(NSString *)tag
{
	NSURLRequest	*	request						=	[self untagRequest:tag];
	
	if ([NSURLConnection canHandleRequest:request])
	{
		NSURLConnection			*	connection		=	nil;
		connection									=	[NSURLConnection connectionWithRequest:request delegate:self];
		if (connection != nil)
		{
			self.untagConnection					=	connection;
			[self.untagConnection start];
		}
		else
		{ // Unable to make connection
			NSError				*	error			=	[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
			if ([(NSObject *)self.delegate respondsToSelector:@selector(tagUnregisterFailed:)])
				[self.delegate tagUnregisterFailed:error];
		}
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Formatting
#pragma mark -
/******************************************************************************/
+ (NSString *)stringWithHexBytes:(NSData *)bytes 
{
	//
	//c/o stephen joseph butler
	//http://www.cocoabuilder.com/archive/cocoa/194181-convert-hex-values-in-an-nsdata-object-to-nsstring.html#194188
	//
	NSMutableString		*	stringBuffer	=	[NSMutableString stringWithCapacity:([bytes length] * 2)];
	const unsigned char	*	dataBuffer		=	[bytes bytes];
	int i;
	for (i = 0; i < [bytes length]; ++i) 
	{
		[stringBuffer appendFormat:@"%02X", (unsigned long)dataBuffer[i]];
	}
	return [[stringBuffer copy] autorelease];
}

@end

@implementation Push (Private)

- (id)init
{
	if ((self = [super init]))
	{
		
		self.applicationKey		=	kApplicationKey;
		self.applicationSecret	=	kApplicationSecret;
		[[NSNotificationCenter defaultCenter] 
		 addObserver:self 
		 selector:@selector(releasePush) 
		 name:UIApplicationWillTerminateNotification 
		 object:nil];
	}
	return self;
}
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] 
	 removeObserver:self 
	 name:UIApplicationWillTerminateNotification 
	 object:nil];
	_delegate	=	nil;
	[_applicationSecret release];
	[_applicationKey release];
	[_deviceAlias release];
	[_deviceToken release];
	[_tokenConnection release];
	[_tagConnection release];
	[_untagConnection release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Singleton Methods
#pragma mark -
/******************************************************************************/
+ (id)allocWithZone:(NSZone *)zone
{
	if (sharedPush == nil)
	{
		sharedPush	=	[super allocWithZone:zone];
		return sharedPush;
	}
	return nil;
}
- (id)copyWithZone:(NSZone *)zone
{
	return self;
}
- (id)retain
{
	return self;
}
- (NSUInteger)retainCount
{
	return NSUIntegerMax;
}
- (void)release
{
}
- (id)autorelease
{
	return self;
}
- (void)releasePush
{
	[super release];
	sharedPush	=	nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Send Request
#pragma mark -
/******************************************************************************/
- (NSURLRequest *)sendRequest
{
	if (self.deviceToken == nil || self.deviceToken.length != 64)
	{
		[self.delegate pushNotificationRegisterFailed:[NSError errorWithDomain:@"deviceTokenReadFailedError" code:deviceTokenReadFailedError userInfo:nil]];
		return nil;
	}
	
	NSString			*	server		=	@"https://go.urbanairship.com";
	NSString			*	urlString	=	[NSString stringWithFormat:@"%@%@%@/", server, @"/api/device_tokens/", self.deviceToken];
	NSURL				*	url			=	[NSURL URLWithString:urlString];
	NSMutableURLRequest	*	request		=	[NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"PUT"];
	
	if (self.deviceAlias == nil && self.deviceAlias.length == 0)
		self.deviceAlias				=	[NSString stringWithFormat:@"%@-%@-%@", [self bundleIdentifier], [self bundleVersion], [self deviceUUID]];
	[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:[[NSString stringWithFormat: @"{\"alias\": \"%@\"}", self.deviceAlias] dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (self.applicationKey == nil || self.applicationKey.length == 0)
	{
		[self.delegate pushNotificationRegisterFailed:[NSError errorWithDomain:@"applicationKeyReadFailedError" code:applicationKeyReadFailedError userInfo:nil]];
		return nil;
	}
	
	if (self.applicationSecret == nil || self.applicationSecret.length == 0)
	{
		[self.delegate pushNotificationRegisterFailed:[NSError errorWithDomain:@"applicationSecretReadFailedError" code:applicationSecretReadFailedError userInfo:nil]];
		return nil;
	}
	[request addValue:[NSString stringWithFormat:@"Basic %@", 
					   [Push base64forData:
						[[NSString stringWithFormat:@"%@:%@", self.applicationKey, self.applicationSecret] 
						 dataUsingEncoding: NSUTF8StringEncoding]]] 
   forHTTPHeaderField:@"Authorization"];
	
	return (NSURLRequest *)request;
}
- (NSURLRequest *)tagRequest:(NSString *)tag
{
	if (self.deviceToken == nil || self.deviceToken.length != 64)
	{
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagRegisterFailed:)])
			[self.delegate tagRegisterFailed:[NSError errorWithDomain:@"deviceTokenReadFailedError" code:deviceTokenReadFailedError userInfo:nil]];
		return nil;
	}
	
	NSString			*	server		=	@"https://go.urbanairship.com";
	NSString			*	urlString	=	[NSString stringWithFormat:@"%@%@%@%@%@", server, @"/api/device_tokens/", self.deviceToken, @"/tags/", tag];
	NSURL				*	url			=	[NSURL URLWithString:urlString];
	NSMutableURLRequest	*	request		=	[NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"PUT"];
		
	if (self.applicationKey == nil || self.applicationKey.length == 0)
	{
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagRegisterFailed:)])
			[self.delegate tagRegisterFailed:[NSError errorWithDomain:@"applicationKeyReadFailedError" code:applicationKeyReadFailedError userInfo:nil]];
		return nil;
	}
	
	if (self.applicationSecret == nil || self.applicationSecret.length == 0)
	{
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagRegisterFailed:)])
			[self.delegate tagRegisterFailed:[NSError errorWithDomain:@"applicationSecretReadFailedError" code:applicationSecretReadFailedError userInfo:nil]];
		return nil;
	}
	
	[request addValue:
	 [NSString stringWithFormat:@"Basic %@", 
	  [Push base64forData:
	   [[NSString stringWithFormat:@"%@:%@", self.applicationKey, self.applicationSecret] 
		dataUsingEncoding: NSUTF8StringEncoding]]] 
   forHTTPHeaderField:@"Authorization"];
	
	return (NSURLRequest *)request;
}
- (NSURLRequest *)untagRequest:(NSString *)tag
{
	if (self.deviceToken == nil || self.deviceToken.length != 64)
	{
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagUnregisterFailed:)])
			[self.delegate tagUnregisterFailed:[NSError errorWithDomain:@"deviceTokenReadFailedError" code:deviceTokenReadFailedError userInfo:nil]];
		return nil;
	}
	
	NSString			*	server		=	@"https://go.urbanairship.com";
	NSString			*	urlString	=	[NSString stringWithFormat:@"%@%@%@%@%@", server, @"/api/device_tokens/", self.deviceToken, @"/tags/", tag];
	NSURL				*	url			=	[NSURL URLWithString:urlString];
	NSMutableURLRequest	*	request		=	[NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"DELETE"];
	
	if (self.applicationKey == nil || self.applicationKey.length == 0)
	{
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagUnregisterFailed:)])
			[self.delegate tagUnregisterFailed:[NSError errorWithDomain:@"applicationKeyReadFailedError" code:applicationKeyReadFailedError userInfo:nil]];
		return nil;
	}
	
	if (self.applicationSecret == nil || self.applicationSecret.length == 0)
	{
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagUnregisterFailed:)])
			[self.delegate tagUnregisterFailed:[NSError errorWithDomain:@"applicationSecretReadFailedError" code:applicationSecretReadFailedError userInfo:nil]];
		return nil;
	}
	
	[request addValue:
	 [NSString stringWithFormat:@"Basic %@", 
	  [Push base64forData:
	   [[NSString stringWithFormat:@"%@:%@", self.applicationKey, self.applicationSecret] 
		dataUsingEncoding: NSUTF8StringEncoding]]] 
   forHTTPHeaderField:@"Authorization"];
	
	return (NSURLRequest *)request;
}
- (NSString *)deviceUUID
{
	NSString	*	UUID	=	nil;
	UUID					=	[[UIDevice currentDevice] uniqueIdentifier];
	return UUID;
}
- (NSString *)bundleIdentifier
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}
- (NSString *)bundleVersion
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}
/******************************************************************************/
#pragma mark -
#pragma mark NSURLConnection Delegate Methods
#pragma mark -
/******************************************************************************/
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ([connection isEqual:self.tokenConnection])
	{
		self.tokenConnection	=	nil;
		if ([(NSObject *)self.delegate respondsToSelector:@selector(pushNotificationRegisterFailed:)])
			[self.delegate pushNotificationRegisterFailed:error];
	}
	else if ([connection isEqual:self.tagConnection])
	{
		self.tagConnection	=	nil;
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagRegisterFailed:)])
			[self.delegate tagRegisterFailed:error];
	}
	else if ([connection isEqual:self.untagConnection])
	{
		self.untagConnection	=	nil;
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagUnregisterFailed:)])
			[self.delegate tagUnregisterFailed:error];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSInteger	statusCode	=	[(NSHTTPURLResponse *)response statusCode];
	if ([connection isEqual:self.tokenConnection])
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible	=	NO;
		if (statusCode != 200 && statusCode != 201)
		{// 201 token registered, 200 token already registered
			if ([(NSObject *)self.delegate respondsToSelector:@selector(pushNotificationRegisterFailed:)])
				[self.delegate pushNotificationRegisterFailed:nil];
			return;
		}
		if ([(NSObject *)self.delegate respondsToSelector:@selector(pushNotificationRegisterSucceeded:)])
			[self.delegate pushNotificationRegisterSucceeded:self];
#ifdef DEVELOPMENTBUILD
		[self tag:@"DevelopmentDevice"];
#endif
	}
	else if ([connection isEqual:self.tagConnection])
	{// 201 tag added, 200 tag already associated with token
		if (statusCode != 200 && statusCode != 201)
		{
			if ([(NSObject *)self.delegate respondsToSelector:@selector(tagRegisterFailed:)])
				[self.delegate tagRegisterFailed:nil];
			return;
		}
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagRegisterSucceeded:)])
			[self.delegate tagRegisterSucceeded:self];
	}
	else if ([connection isEqual:self.untagConnection])
	{// 204 = tag removed, 404 = tag already not associated with token
		if (statusCode != 204 && statusCode != 404)
		{
			if ([(NSObject *)self.delegate respondsToSelector:@selector(tagUnregisterFailed:)])
				[self.delegate tagUnregisterFailed:nil];
			return;
		}
		if ([(NSObject *)self.delegate respondsToSelector:@selector(tagUnregisterSucceeded:)])
			[self.delegate tagUnregisterSucceeded:self];
	}
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([connection isEqual:self.tokenConnection])
	{
		self.tokenConnection	=	nil;
	}
	else if ([connection isEqual:self.tagConnection])
	{
		self.tagConnection		=	nil;
	}
	else if ([connection isEqual:self.untagConnection])
	{
		self.untagConnection	=	nil;
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Formatting
#pragma mark -
/******************************************************************************/
// From: http://www.cocoadev.com/index.pl?BaseSixtyFour
+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

@end
