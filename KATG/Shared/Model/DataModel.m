//
//  DataModel.m
//	
//  Created by Doug Russell on 4/26/10.
//  Copyright Doug Russell 2010. All rights reserved.
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

#import "DataModel.h"
#import "SynthesizeSingleton.h"
#import "DataModel+Processing.h"
#import "DataModel+Notifications.h"
#import "Event.h"
#import "EGOCache.h"
#import "EventFormattingOperation.h"

@implementation DataModel
@synthesize delegates;
@synthesize connected, connectionType;
@synthesize managedObjectContext;
@synthesize twitterSearchRefreshURL, twitterExtendedSearchRefreshURL, twitterHashSearchRefreshURL;
@dynamic	twitterSearchFormatter, twitterUserFormatter;

SYNTHESIZE_SINGLETON_FOR_CLASS(DataModel);

/******************************************************************************/
#pragma mark -
#pragma mark Delegates
#pragma mark -
/******************************************************************************/
- (void)addDelegate:(id<DataModelDelegate>)dlgt
{
	//	
	//	Adds delegete to delegates array if not already added.
	//	Delegates array is non retaining to avoid retain loops.
	//	This might be faster if it used a set instead of an array.
	//	
	//	Delegate object must conform to the DataModelDelegate protocol.
	//	
	//	This is synchronized to avoid collisions with removeDelegate
	//	or other addDelegate calls.
	//	
	//	Not matching a addDelegate: call with a removeDelegate:
	//	call may cause released objects to be addressed.
	//	
	@synchronized(self)
	{
		if (![delegates containsObject:dlgt])
		{
			[delegates addObject:dlgt];
		}
	}
}
- (void)removeDelegate:(id<DataModelDelegate>)dlgt
{
	//	
	//	Remove delegete from the delegates array.
	//	
	//	Delegate object must conform to the DataModelDelegate protocol.
	//	
	//	This is synchronized to avoid collisions with removeDelegate
	//	or other addDelegate calls.
	//	
	//	Not matching a addDelegate: call with a removeDelegate:
	//	call may cause released objects to be addressed.
	//	
	//	Multiple removeDelegate calls would be wasteful, but would not
	//	raise an error or exception.
	//	
	@synchronized(self)
	{
		[delegates removeObject:dlgt];
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Live Show Status
#pragma mark -
/******************************************************************************/
- (void)liveShowStatus
{
	//
	//  Checks the Live Show Status
	//	This is based on the hosts turning on
	//	the live show indicator on the website
	//	manually and does not directly poll the
	//	shoutcast servers status
	//		
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kLiveShowStatusCode;
	op.URI						=	kLiveShowStatusAddress;
	op.parseType				=	ParseXML;
	op.xPath					=	kOnAirXPath;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Next Live Show Time
#pragma mark -
/******************************************************************************/
- (void)nextLiveShowTime
{
	NSArray		*	events;
	Event		*	nextShowEvent	=	nil;
	NSString	*	guestText		=	nil;
	
	events	=	[self events];
	
	for (Event *event in events)
	{
		//	
		//	
		//	
		if (![[event ShowType] boolValue])
			continue;
		//	
		//	
		//	
		NSDate		*	date		=	[event DateTime];
		NSInteger		since		=	[date timeIntervalSinceNow];
		if (((since > -(12 * 3600)) && (since < 0)  && live) || (since >= 0))
			nextShowEvent			=	event;
		else
			continue;
		NSString	*	title		=	[event Title];
		if (title)
			guestText				=	[self performSelector:@selector(findGuest:) withObject:title];
		break;
	}
	if (nextShowEvent && guestText)
		[self notifyNextLiveShowTime:
		 [NSDictionary dictionaryWithObjectsAndKeys:
		  nextShowEvent,	@"event",
		  guestText,		@"guest", nil]];
	else
		[self notifyError:[NSError errorWithDomain:@"Events Unavailable" 
											  code:kNextLiveShowCode 
										  userInfo:nil] 
				  display:NO];
}
- (NSString *)findGuest:(NSString *)eventTitle
{
	NSString		*	guestText	=	nil;
	NSRange				range		=	[eventTitle rangeOfString:@"Live Show with " 
										  options:(NSAnchoredSearch | 
												   NSCaseInsensitiveSearch)];
	if (range.location != NSNotFound)
	{
		NSString	*	guest		=
		[eventTitle stringByReplacingOccurrencesOfString:@"Live Show with " 
											  withString:@"" 
												 options:(NSAnchoredSearch | 
														  NSCaseInsensitiveSearch)
												   range:NSMakeRange(0, eventTitle.length)];
		if (guest)
			guestText				=	guest;
	}
	else
		guestText					=	@"No Guest(s)";
	
	return guestText;
}
/******************************************************************************/
#pragma mark -
#pragma mark Feedback
#pragma mark -
/******************************************************************************/
- (void)feedback:(NSString *)name 
		location:(NSString *)location 
		 comment:(NSString *)comment
{
	//	
	//  Send in feedback for hosts to read during live show
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kLiveShowStatusCode;
	op.URI						=	kLiveShowStatusAddress;
	op.parseType				=	ParseXML;
	op.xPath					=	kOnAirXPath;
	op.bodyBufferDict			=	[NSDictionary dictionaryWithObjectsAndKeys:
									 [[name copy] autorelease],		@"Name",
									 [[location copy] autorelease],	@"Location",
									 [[comment copy] autorelease],	@"Comment",
									 @"Send+Comment",				@"ButtonSubmit",
									 @"3",							@"HiddenVoxbackId",
									 @"IEOSE",						@"HiddenMixerCode", nil];
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Chat
#pragma mark -
/******************************************************************************/
- (void)chatLogin:(NSString *)userName 
		 password:(NSString *)password
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	if (userName &&
		userName.length > 0 &&
		password &&
		password.length >0)
	{
		NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
		op.delegate					=	self;
		op.instanceCode				=	kChatLoginPhaseOneCode;
		op.baseURL					=	kChatLoginBaseURLAddress;
		op.URI						=	kChatLoginURIAddress;
		op.userInfo					=	[NSDictionary dictionaryWithObjectsAndKeys:
										 userName, @"Username",
										 password, @"password", nil];
		if (connected)
			[operationQueue addOperation:op];
		else
			[delayedOperations addObject:op];
		[op release];
	}
	else
	{
		//	error
	}
}
- (void)chatStart
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kChatStartCodePhaseOne;
	op.baseURL					=	kChatStartBaseURLAddress;
	op.URI						=	kChatStartURIAddress;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Events
#pragma mark -
/******************************************************************************/
- (NSArray *)events
{
	EGOCache	*	cache		=	[EGOCache currentCache];
	NSInteger		hasKey		=	[cache hasCacheForKey:@"events.archive"];
	if (hasKey == 1)
	{
#if LogEventCaching
		NSLog(@"Retrieve Events from cache");
#endif
		NSArray		*	events		=	[cache objectForKey:@"events.archive"];
		if (events)
			return events;
	}
	else if (hasKey == 2)
	{
		return nil;
	}
#if LogEventCaching
	NSLog(@"Retrieve Events from web");
#endif
	//	
	//	First make sure there isn't already an events operation happening
	//	
	NSArray	*	ops	=	[NSArray arrayWithArray:[operationQueue operations]];
	for (NetworkOperation *anOp in ops)
	{
		if (anOp.instanceCode == kEventsListCode)
			return nil;
	}
	for (NetworkOperation *anOp in delayedOperations)
	{
		if (anOp.instanceCode == kEventsListCode)
			return nil;
	}
	ops	=	[NSArray arrayWithArray:[coreDataQueue operations]];
	for (NSOperation *anOp in ops)
	{
		if ([anOp isKindOfClass:[EventFormattingOperation class]])
			return nil;
	}
	//	
	//	Then go get an updated events list
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kEventsListCode;
	op.URI						=	kEventsFeedAddress;
	op.parseType				=	ParseXML;
	op.xPath					=	kEventsXPath;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
	//	
	//	
	//	
	return nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Shows
#pragma mark -
/******************************************************************************/
- (void)shows
{
	//	
	//	Retrieve list of show archive
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kShowArchivesCode;
	op.URI						=	kShowListURIAddress;
	// Using the twitter date formatter to avoid creating another dateformatter just for this
	NSDate	*	start			=	[self.twitterSearchFormatter dateFromString:@"Mon, 01 Apr 2010 07:36:57 +0000"];
	if (start)
	{
		NSInteger	days		=	[start timeIntervalSinceDate:[NSDate date]] / -(60 /*Seconds*/ * 60 /*Minutes*/ * 24 /*Hours*/);
		op.requestType			=	POST;
		op.bodyBufferDict		=	[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSString stringWithFormat:@"%d", days], @"ShowCount", nil];
	}
	op.parseType				=	ParseXML;
	op.xPath					=	kShowArchivesXPath;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
- (void)showDetails:(NSString *)ID
{
	NSParameterAssert([ID isKindOfClass:[NSString class]]);
	//	
	//	Update given show with details
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kShowDetailsCode;
	op.URI						=	kShowDetailsURIAddress;
	op.requestType				=	POST;
	op.bodyBufferDict			=	[NSDictionary dictionaryWithObjectsAndKeys:
									 [[ID copy] autorelease], kShowIDKey, nil];
	op.parseType				=	ParseXML;
	op.xPath					=	kShowDetailsXPath;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
- (void)showPictures:(NSString *)ID
{
	NSParameterAssert([ID isKindOfClass:[NSString class]]);
	//	
	//	Update given show with details
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kShowPicturesCode;
	op.URI						=	kShowPicturesURIAddress;
	op.requestType				=	POST;
	op.bodyBufferDict			=	[NSDictionary dictionaryWithObjectsAndKeys:
									 [[ID copy] autorelease], kShowIDKey, nil];
	op.parseType				=	ParseXML;
	op.xPath					=	kShowPicturesXPath;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Twitter
#pragma mark -
/******************************************************************************/
- (void)twitterSearchFeed:(BOOL)extended
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	if (extended)
		self.twitterSearchRefreshURL	=	nil;
	else
		self.twitterSearchRefreshURL	=	nil;
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kTwitterSearchCode;
	if (extended)
	{
		op.baseURL				=	kTwitterSearchFeedBaseURLAddress;
		if (self.twitterSearchRefreshURL)
			op.URI				=	[NSString stringWithFormat:@"%@%@", @"/search.json", self.twitterExtendedSearchRefreshURL];
		else
			op.URI				=	kTwitterSearchExtendedFeedURIAddress;
	}
	else
	{
		op.baseURL				=	kTwitterSearchFeedBaseURLAddress;
		if (self.twitterSearchRefreshURL)
			op.URI				=	[NSString stringWithFormat:@"%@%@", @"/search.json", self.twitterSearchRefreshURL];
		else
			op.URI				=	kTwitterSearchFeedURIAddress;
	}
	op.parseType				=	ParseJSONDictionary;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
- (void)twitterUserFeed:(NSString *)userName
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kTwitterUserFeedCode;
	op.baseURL					=	kTwitterBaseURLAddress;
	op.URI						=	[NSString stringWithFormat:
									 @"%@%@%@", 
									 kTwitterUserURIAddress, 
									 userName, 
									 @".json"];
	op.userInfo					=	[NSDictionary dictionaryWithObject:userName forKey:@"userName"];
	op.parseType				=	ParseJSONArray;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
- (void)twitterHashTagFeed:(NSString *)hashTag
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kTwitterHashTagCode;
	op.baseURL					=	kTwitterSearchFeedBaseURLAddress;
	//if (self.twitterSearchRefreshURL)
	//	op.URI				=	[NSString stringWithFormat:@"%@%@", @"/search.json", self.twitterSearchRefreshURL];
	//else
	//	op.URI				=	kTwitterSearchFeedURIAddress;
	op.URI						=	[NSString stringWithFormat:@"/search.json?q=%%23%@", hashTag];
	op.parseType				=	ParseJSONDictionary;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
- (UIImage *)twitterImageForURL:(NSString *)url
{
	NSParameterAssert((url != nil));
	NSParameterAssert([url isKindOfClass:[NSString class]]);
	NSParameterAssert((url.length != 0));
	//	
	//  /*UNREVISEDCOMMENTS*/
	//	
	NSData	*	imageData	=	[pictureCacheDictionary objectForKey:url];
	if (imageData)
	{
		UIImage		*	image	=	[UIImage imageWithData:imageData];
		if (image)
		{
			CGFloat		scale	=	[[UIScreen mainScreen] scale];
			if (scale != 1.0)
				image			=	[UIImage imageWithCGImage:image.CGImage scale:scale orientation:0];
			if (image)
				return image;
		}
	}
	BOOL			inQueue		=	NO;
	for (NetworkOperation *anOp in [operationQueue operations])
	{
		if ([[anOp baseURL] isEqualToString:url])
			inQueue					=	YES;
	}
	
	if (!inQueue)
	{
		NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
		op.delegate					=	self;
		op.instanceCode				=	kGetTwitterImageCode;
		op.baseURL					=	url;
		if (connected)
			[operationQueue addOperation:op];
		else
			[delayedOperations addObject:op];
		[op release];
	}
	return nil;
}

@end
