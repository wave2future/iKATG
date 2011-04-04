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
#import "Picture.h"
#import "Show.h"
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
	LogCmd(_cmd);
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
	op.parseType				=	ParseJSONDictionary;
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
	
	EventsAvailability status;
	events	=	[self events:&status];
	
	switch (status) {
		case kEventsAvailable:
			// Proceed as normal
			break;
		case kEventsWaitingOnWeb:
			// Stop here, events processing will call nextLiveShowTime when it's
			// done formatting and caching the events list
			return;
			break;
		case kEventsWaitingOnCache:
			// delay 1.0 second to let cache finish commiting to disk
			[self performSelector:_cmd withObject:nil afterDelay:1.0];
			return;
			break;
		case kEventsUnavailable:
			// currently this should never happen
			break;
		default:
			break;
	}
	
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
#pragma mark Events
#pragma mark -
/******************************************************************************/
- (NSArray *)events
{
	EventsAvailability status;
	return [self events:&status];
}
- (NSArray *)events:(EventsAvailability *)status
{
	//	
	//	Attempt to get events array from cache
	//	Events may be not available, available, or not yet available (0/1/2)
	//	
	EGOCache	*	cache		=	[EGOCache currentCache];
	NSInteger		hasKey		=	[cache hasCacheForKey:@"events.archive"];
	if (hasKey == 1)
	{
#if LogEventCaching
		NSLog(@"Retrieve Events from cache");
#endif
		NSArray		*	events		=	[cache objectForKey:@"events.archive"];
		if (events)
		{
			*status = kEventsAvailable;
			return events;
		}
	}
	else if (hasKey == 2)
	{
		*status = kEventsWaitingOnCache;
		return nil;
	}
#if LogEventCaching
	NSLog(@"Retrieve Events from web");
#endif
	//	
	//	Make sure there isn't already an events operation happening
	//	
	NSArray	*	ops	=	[NSArray arrayWithArray:[operationQueue operations]];
	for (NetworkOperation *anOp in ops)
	{
		if (anOp.instanceCode == kEventsListCode)
		{
			*status = kEventsWaitingOnWeb;
			return nil;
		}
	}
	for (NetworkOperation *anOp in delayedOperations)
	{
		if (anOp.instanceCode == kEventsListCode)
		{
			*status = kEventsWaitingOnWeb;
			return nil;
		}
	}
	ops	=	[NSArray arrayWithArray:[coreDataQueue operations]];
	for (NSOperation *anOp in ops)
	{
		if ([anOp isKindOfClass:[EventFormattingOperation class]])
		{
			*status = kEventsWaitingOnWeb;
			return nil;
		}
	}
	//	
	//	Then go get an updated events list
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kEventsListCode;
#if TestErrorEventHandling
	op.baseURL					=	@"http://getitdownonpaper.com";
	//op.URI						=	@"/somegarbage"; // this could be any random chunk of html to see how parser will handle it
	//op.URI					=	@"/ESModelAPI/Delay/"; // this stalls for 20 seconds then returns garbage
	op.URI						=	@"/ESModelAPI/Timeout/"; // this stalls long enough to cause a timeout
#else
	op.URI						=	kEventsFeedAddress;
#endif
	op.parseType				=	ParseXML;
	op.xPath					=	kEventsXPath;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
	
	*status = kEventsWaitingOnWeb;
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
	NSDate	*	start			=	[self.twitterSearchFormatter dateFromString:@"Sat, 01 Jan 2011 00:00:00 +0000"];
	if (start)
	{
		NSInteger	days		=	[start timeIntervalSinceDate:[NSDate date]] / -(60 /*Seconds*/ * 60 /*Minutes*/ * 24 /*Hours*/);
		op.requestType			=	POST;
		op.bodyBufferDict		=	[NSDictionary dictionaryWithObjectsAndKeys:
									 [NSString stringWithFormat:@"%d", days], @"ShowCount", nil];
	}
	
	op.parseType				=	ParseJSONArray;
	op.xPath					=	kShowArchivesXPath;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
}
- (Show *)fetchShow:(NSManagedObjectID *)objectID showID:(NSNumber *)showID
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	NSError	*	error;
	Show	*	show	=	nil;
	show				=	(Show *)[self.managedObjectContext existingObjectWithID:objectID 
																error:&error];
	if (show == nil || ![show isKindOfClass:[Show class]])
	{
		NSFetchRequest		*	request	=	[[NSFetchRequest alloc] init];
		NSEntityDescription	*	entity	=
		[NSEntityDescription entityForName:@"Show" 
					inManagedObjectContext:self.managedObjectContext];
		[request setEntity:entity];
		[request setFetchLimit:1];
		request.relationshipKeyPathsForPrefetching	=	[NSArray arrayWithObject:@"Pictures"];
		NSPredicate	*	predicate	=
		[NSPredicate predicateWithFormat:@"ID == %@", showID];
		[request setPredicate:predicate];
		NSError		*	error;
		NSArray		*	fetchResults	=
		[self.managedObjectContext executeFetchRequest:request 
												 error:&error];
		if (fetchResults.count > 0)
		{
			show = [fetchResults objectAtIndex:0];
		}
		[request release];
	}
	return show;
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
	//	/*UNREVISEDCOMMENTS*/
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
- (UIImage *)imageForURL:(NSString *)url
{
	NSParameterAssert((url != nil));
	NSParameterAssert([url isKindOfClass:[NSString class]]);
	NSParameterAssert((url.length != 0));
	//	
	//  See if image is in cache already
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
	//	
	//	Make sure there isn't already a queued request for this image
	//	
	BOOL	inQueue	=	NO;
	for (NetworkOperation *anOp in [operationQueue operations])
	{
		if ([[anOp baseURL] isEqualToString:url])
			inQueue					=	YES;
		if (inQueue)
			break;
	}
	for (NetworkOperation *anOp in delayedOperations)
	{
		if (inQueue)
			break;
		if ([[anOp baseURL] isEqualToString:url])
			inQueue					=	YES;
	}
	if (inQueue)
		return nil;
	//	
	//	Go get the image
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kGetImageCode;
	op.baseURL					=	url;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
	return nil;
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
	//  See if image is in cache already
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
	//	
	//	
	//	
	UIImage * stockImage = nil;//[UIImage imageNamed:@"KeithRelief"];
	//	
	//	Make sure there isn't already a queued request for this image
	//	
	BOOL	inQueue	=	NO;
	for (NetworkOperation *anOp in [operationQueue operations])
	{
		if ([[anOp baseURL] isEqualToString:url])
			inQueue					=	YES;
		if (inQueue)
			break;
	}
	for (NetworkOperation *anOp in delayedOperations)
	{
		if (inQueue)
			break;
		if ([[anOp baseURL] isEqualToString:url])
			inQueue					=	YES;
	}
	if (inQueue)
		return stockImage;
	//	
	//	Go get the image
	//	
	NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
	op.delegate					=	self;
	op.instanceCode				=	kGetTwitterImageCode;
	op.baseURL					=	url;
	if (connected)
		[operationQueue addOperation:op];
	else
		[delayedOperations addObject:op];
	[op release];
	return stockImage;
}

@end
