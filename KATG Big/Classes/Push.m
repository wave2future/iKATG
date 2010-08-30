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

#define DEVELOPMENTBUILD 1

#import "Push.h"
#import "PushKeys.h"

static	Push	*	sharedPush	=	nil;

@interface Push ()
@property (nonatomic, retain)	NSString		*	applicationKey;
@property (nonatomic, retain)	NSString		*	applicationSecret;
@property (nonatomic, retain)	NSURLConnection	*	tokenConnection;
@property (nonatomic, retain)	NSMutableData	*	tokenConnectionData;
@end

@interface Push (Private)
- (NSURLRequest *)sendRequest;
- (NSString *)stringWithHexBytes:(NSData *)bytes;
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
@synthesize	result				=	_result;
@synthesize	tokenConnection		=	_tokenConnection;
@synthesize	tokenConnectionData	=	_tokenConnectionData;

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
#if DEVELOPMENTBUILD
	if ([[[UIDevice currentDevice] model] compare: @"iPhone Simulator"] == NSOrderedSame)
	{
		NSLog(@"ERROR: Remote notifications are not supported in the simulator.");
	}
	else
	{
#endif
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
#if DEVELOPMENTBUILD
	}
#endif
}
- (void)unregisterForRemoteNotifications
{
#if DEVELOPMENTBUILD
	if ([[[UIDevice currentDevice] model] compare: @"iPhone Simulator"] == NSOrderedSame)
	{
		NSLog(@"ERROR: Remote notifications are not supported in the simulator.");
	}
	else
	{
#endif
		[[UIApplication sharedApplication] unregisterForRemoteNotifications];
#if DEVELOPMENTBUILD
	}
#endif
}
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
			if (self.tokenConnectionData == nil)
				self.tokenConnectionData			=	[NSMutableData data];
			[self.tokenConnectionData setLength:0];
			[connection start];
		}
		else
		{ // Unable to make connection
			NSError				*	error			=	[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
			if ([(NSObject *)self.delegate respondsToSelector:@selector(pushNotificationRegisterFailed:)])
				[self.delegate pushNotificationRegisterFailed:error];
		}
	}
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
	[_result release];
	[_deviceToken release];
	[_tokenConnection release];
	[_tokenConnectionData release];
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
	NSString			*	tokenString	=	nil;
	if (self.deviceToken != nil)
	{
		tokenString						=	[self stringWithHexBytes:self.deviceToken];
		if (tokenString == nil || tokenString.length != 64)
		{
			[self.delegate pushNotificationRegisterFailed:[NSError errorWithDomain:@"deviceTokenReadFailedError" code:deviceTokenReadFailedError userInfo:nil]];
			return nil;
		}
	}
	else
	{
		[self.delegate pushNotificationRegisterFailed:[NSError errorWithDomain:@"deviceTokenReadFailedError" code:deviceTokenReadFailedError userInfo:nil]];
		return nil;
	}
	
	NSString			*	server		=	@"https://go.urbanairship.com";
	NSString			*	urlString	=	[NSString stringWithFormat:@"%@%@%@/", server, @"/api/device_tokens/", tokenString];
	NSURL				*	url			=	[NSURL URLWithString:urlString];
	NSMutableURLRequest	*	request		=	[NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"PUT"];
	
	if (self.deviceAlias == nil && self.deviceAlias.length == 0)
		self.deviceAlias						=	[NSString stringWithFormat:@"%@-%@-%@", [self bundleIdentifier], [self bundleVersion], [self deviceUUID]];
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
	[request addValue:
	 [NSString stringWithFormat:@"Basic %@", 
	  [Push base64forData:
	   [[NSString stringWithFormat:@"%@:%@", self.applicationKey, self.applicationSecret] 
		dataUsingEncoding: NSUTF8StringEncoding]]] 
   forHTTPHeaderField:@"Authorization"];
	
	return (NSURLRequest *)request;
}
- (NSString *)stringWithHexBytes:(NSData *)bytes 
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
		[stringBuffer appendFormat:@"%02x", (unsigned long)dataBuffer[i]];
	}
	return [[stringBuffer copy] autorelease];
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
	self.tokenConnection	=	nil;
	[self.tokenConnectionData setLength:0];
	if ([(NSObject *)self.delegate respondsToSelector:@selector(pushNotificationRegisterFailed:)])
		[self.delegate pushNotificationRegisterFailed:error];
	
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.tokenConnectionData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	self.result				=	[[[NSString alloc] initWithData:self.tokenConnectionData encoding:NSUTF8StringEncoding] autorelease];
	self.tokenConnection	=	nil;
	[self.tokenConnectionData setLength:0];
	if ([(NSObject *)self.delegate respondsToSelector:@selector(pushNotificationRegisterSucceeded:)])
		[self.delegate pushNotificationRegisterSucceeded:self];
	[UIApplication sharedApplication].networkActivityIndicatorVisible	=	NO;
}
/******************************************************************************/
#pragma mark -
#pragma mark Base 64
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
