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

@implementation DataModel
@synthesize delegates, connected;
@synthesize managedObjectContext;
@synthesize twitterSearchRefreshURL, twitterExtendedSearchRefreshURL, twitterHashSearchRefreshURL;
@dynamic	formatter, dayFormatter, dateFormatter, timeFormatter, twitterSearchFormatter, twitterUserFormatter;

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
	NSFetchRequest		*	request			=	[[NSFetchRequest alloc] init];
	NSEntityDescription	*	entity			=	[NSEntityDescription 
												 entityForName:@"Event" 
												 inManagedObjectContext:self.managedObjectContext];
	request.entity							=	entity;
	NSSortDescriptor	*	sortDescriptor	=	[[NSSortDescriptor alloc] 
												 initWithKey:@"DateTime" 
												 ascending:YES];
	NSArray				*	sortDescriptors	=	[[NSArray alloc] initWithObjects:sortDescriptor, nil];
	request.sortDescriptors					=	sortDescriptors;
	[sortDescriptors release];
	[sortDescriptor release];
	NSPredicate	*	predicate				=	[NSPredicate predicateWithFormat:
												 @"(DateTime >= %@) AND (DateTime <= %@)", 
												 [[NSDate date] dateByAddingTimeInterval:-(60 /*Seconds*/ * 60 /*Minutes*/ * 12 /*Hours*/)], 
												 [[NSDate date] dateByAddingTimeInterval:(60 /*Seconds*/ * 60 /*Minutes*/ * 24 /*Hours*/)]];
	[request setPredicate:predicate];
	NSError		*	error;
	NSArray		*	fetchResults	=
	[self.managedObjectContext executeFetchRequest:request 
											 error:&error];
	[request release];
	
	Event		*	nextShowEvent	=	nil;
	NSString	*	guestText		=	nil;
	for (Event *event in fetchResults)
	{
		//	
		//	Make sure event is a live show
		//	is scheduled within the
		//	last 12 hours or in the future,
		//	if in the past 
		//	
		NSDate		*	date		=	[event DateTime];
		NSInteger		since		=	[date timeIntervalSinceNow];
		if ((since < 0 && live) || (since >= 0))
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
		[self notifyError:[NSError errorWithDomain:@"Core Data Fetch Failed - Entity: Event" 
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
- (void)events
{
	//	
	//	First make sure there isn't already an events operation happening
	//	
	NSArray	*	ops	=	[NSArray arrayWithArray:[operationQueue operations]];
	for (NetworkOperation	*anOp in ops)
	{
		if (anOp.instanceCode == kEventsListCode)
			return;
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
	NSDate	*	start			=	[self.formatter dateFromString:@"03/01/2010 12:00"];
	if (start)
	{
		NSInteger	days		=	[start timeIntervalSinceDate:[NSDate date]] / -(60 /*Seconds*/ * 60 /*Minutes*/ * 24 /*Hours*/);
		op.requestType			=	POST;
		op.bodyBufferDict		=	[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", days] forKey:@"ShowCount"];
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
	//	
	//	Update given show with details
	//	
//	DataOperation	*	op	=	[[DataOperation alloc] init];
//	[op setDelegate:self];
//	// Object setters are (nonatomic, copy)
//	[op setCode:kShowDetailsCode];
//	[op setURI:kShowDetailsURIAddress];
//	NSDictionary	*	bufferDict	=
//	[NSDictionary dictionaryWithObjectsAndKeys:
//	 [[ID copy] autorelease],	kShowIDKey, nil];
//	[op setBufferDict:bufferDict];
//	if (connected)
//		[operationQueue addOperation:op];
//	else
//		[delayedOperations addObject:op];
//	[op release];
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
- (UIImage *)thumbForURL:(NSString *)url
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	return [self getImage:@"48" url:url];
}
- (UIImage *)getImage:(NSString *)key url:(NSString *)url
{
	//	
	//  /*UNREVISEDCOMMENTS*/
	//	
	if (url)
	{
		NSDictionary	*	imageDict	=	[pictureCacheDictionary objectForKey:url];
		if (imageDict)
		{
			UIImage		*	image		=	[UIImage imageWithData:[imageDict objectForKey:key]];
			if (image)
			{
				CGFloat			scale	=	1.0;
				if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] &&
					[UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
				{
					scale				=	[[UIScreen mainScreen] scale];
					image				=	[UIImage imageWithCGImage:image.CGImage scale:scale orientation:0];
				}
				if (image)
					return image;
			}
		}
		
		BOOL				inQueue		=	NO;
		for (NetworkOperation *anOp in [operationQueue operations])
		{
			if ([[anOp baseURL] isEqualToString:url])
				inQueue					=	YES;
		}
		
		if (!inQueue)
		{
			NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
			op.delegate					=	self;
			// Object setters are (nonatomic, copy)
			op.instanceCode				=	kGetImageCode;
			op.baseURL					=	url;
			if (connected)
				[operationQueue addOperation:op];
			else
				[delayedOperations addObject:op];
			[op release];
		}
	}
	else
	{
		ESLog(@"URL missed for getImageForURL");
	}
	
	return nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Network Operation Delegate
#pragma mark -
/******************************************************************************/
- (void)networkOperationDidComplete:(NetworkOperation *)operation withResult:(id)result
{
	//	
	//	switch on instance code and or connectionID and forward results to wherever it should go
	//	
	switch (operation.instanceCode)
	{
		case kLiveShowStatusCode:
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			NSParameterAssert(([(NSArray *)result count] == 1));
			if ([(NSArray *)result count] > 0)
				[self processLiveShowStatus:[(NSArray *)result objectAtIndex:0]];
			break;
		case kFeedbackCode:
			
			break;
		case kChatLoginPhaseOneCode:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			NSParameterAssert(([operation.userInfo objectForKey:@"Username"] != nil));
			NSParameterAssert(([operation.userInfo objectForKey:@"password"] != nil));
			[self processChatLoginPhaseOne:[[result copy] autorelease] 
								  userName:[operation.userInfo objectForKey:@"Username"] 
								  password:[operation.userInfo objectForKey:@"password"]];
			break;
		case kChatLoginPhaseTwoCode:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			[self processChatLoginPhaseTwo:[[result copy] autorelease]];
			break;
		case kChatStartCodePhaseOne:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			[self processChatStartPhaseOne:result];
			break;
		case kChatStartCodePhaseTwo:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			[self processChatStartPhaseTwo:result];
			break;
		case kChatPollingCode:
			
			break;
		case kEventsListCode:
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			NSParameterAssert(([(NSArray *)result count] > 0));
			if ([(NSArray *)result count] > 0)
				[self processEvents:result];
			break;
		case kShowArchivesCode:
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			NSParameterAssert(([(NSArray *)result count] > 0));
			if ([(NSArray *)result count] > 0)
				[self processShowsList:result count:[[operation.bodyBufferDict objectForKey:@"ShowCount"] intValue]];
			break;
		case kShowDetailsCode:
			
			break;
		case kTwitterSearchCode:
			NSParameterAssert([result isKindOfClass:[NSDictionary class]]);
			[self processTwitterSearchFeed:result];
			break;
		case kTwitterUserFeedCode:
			NSParameterAssert([result isKindOfClass:[NSArray class]] || result == nil);
			if (result == nil)
			{
				[self notifyError:[NSError errorWithDomain:[NSString stringWithFormat:
															@"Twitter User @%@ Timeline Not Available", 
															[operation.userInfo objectForKey:@"userName"]] 
													  code:kTwitterUserFeedCode 
												  userInfo:nil] 
						  display:YES];
				break;
			}
			[self processTwitterUserFeed:result user:[operation.userInfo objectForKey:@"userName"]];
			break;
		case kTwitterHashTagCode:
			NSParameterAssert([result isKindOfClass:[NSDictionary class]]);
			[self processTwitterHashTagFeed:result];
			break;
		case kGetImageCode:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			[self processGetImage:(NSData *)result forURL:operation.baseURL];
			break;
		default:
			break;
	}
}
- (void)networkOperationDidFail:(NetworkOperation *)operation withError:(NSError *)error
{
	//	
	//	switch on instance code and or connectionID and forward error to wherever it should go
	//	
	switch (operation.instanceCode)
	{
		case kLiveShowStatusCode:
			
			break;
		case kFeedbackCode:
			
			break;
		case kChatLoginPhaseOneCode:
			
			break;
		case kChatLoginPhaseTwoCode:
			
			break;
		case kChatStartCodePhaseOne:
			
			break;
		case kChatStartCodePhaseTwo:
			
			break;
		case kChatPollingCode:
			
			break;
		case kEventsListCode:
			
			break;
		case kShowArchivesCode:
			
			break;
		case kShowDetailsCode:
			
			break;
		default:
			break;
	}
}

@end
