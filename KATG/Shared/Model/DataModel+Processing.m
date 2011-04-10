//
//  DataModel+Processing.m
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

#import "DataModel+Processing.h"
#import "DataModel+Notifications.h"
#import "Event.h"
#import "Show.h"
#import "Tweet.h"
#import "Picture.h"
#import "TouchXML.h"
#import "UIImage+MyAdditions.h"
#import "EventFormattingOperation.h"

@implementation DataModel (Processing)

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
			NSParameterAssert([result isKindOfClass:[NSDictionary class]]);
			[self processLiveShowStatus:(NSDictionary *)result];
			break;
		case kFeedbackCode:
			
			break;
		case kEventsListCode:
#if TestErrorEventHandling == 0
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			NSParameterAssert(([(NSArray *)result count] > 0));
#endif
			if ([(NSArray *)result count] > 0)
				[self processEvents:result];
			else
				[self notifyError:[NSError errorWithDomain:@"Events Unavailable" 
													  code:kEventsListCode 
												  userInfo:nil] display:NO];
			break;
		case kShowArchivesCode:
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			NSParameterAssert(([(NSArray *)result count] > 0));
			if ([(NSArray *)result count] > 0)
				[self processShowsList:result 
								 count:[[operation.bodyBufferDict objectForKey:@"ShowCount"] intValue]];
			break;
		case kShowDetailsCode:
			NSParameterAssert([result isKindOfClass:[NSDictionary class]]);
			if ([(NSArray *)result count] > 0)
				[self procesShowDetails:(NSDictionary *)result 
								 withID:[operation.bodyBufferDict objectForKey:kShowIDKey]];
			break;
		case kShowPicturesCode:
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			[self procesShowPictures:result 
							  withID:[operation.bodyBufferDict objectForKey:kShowIDKey]];
			break;
		case kGetImageCode:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			[self processGetImage:(NSData *)result forURL:operation.baseURL];
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
		case kGetTwitterImageCode:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			[self processGetTwitterImage:(NSData *)result forURL:operation.baseURL];
			break;
		case kChatCode:
			NSParameterAssert([result isKindOfClass:[NSData class]]);
			[self processChatLogin:(NSData *)result];
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
		case kEventsListCode:
			[self notifyError:[NSError errorWithDomain:@"Events Unavailable" 
												  code:kEventsListCode 
											  userInfo:nil] display:NO];
			break;
		case kShowArchivesCode:
			
			break;
		case kShowDetailsCode:
			
			break;
		case kShowPicturesCode:
			
			break;
		case kGetImageCode:
			
			break;
		default:
			break;
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Live Show
#pragma mark -
/******************************************************************************/
- (void)processLiveShowStatus:(id)result
{
	//	
	//	/*UNREVISEDCOMMENT*/
	//	
	NSParameterAssert([result isKindOfClass:[NSDictionary class]]);
	BOOL	onAir	=	[[(NSDictionary *)result objectForKey:kOnAirKey] boolValue];
	if (onAir != live)
		[self nextLiveShowTime];
	live			=	onAir;
	[self notifyLiveShowStatus:live];
}
/******************************************************************************/
#pragma mark -
#pragma mark Chat
#pragma mark -
/******************************************************************************/
- (void)processChatLogin:(id)result
{
	NSParameterAssert([result isKindOfClass:[NSData class]]);
	NSString *resultString = [[[NSString alloc] initWithData:(NSData *)result encoding:NSUTF8StringEncoding] autorelease];
	BOOL success = ([resultString rangeOfString:@"Login successful" options:NSCaseInsensitiveSearch].location != NSNotFound);
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self notifyChatLogin:success];
	});
}
/******************************************************************************/
#pragma mark -
#pragma mark Events
#pragma mark -
/******************************************************************************/
- (void)processEvents:(id)result
{
	//	
	//	Use data formatters to create localized event
	//	strings and store them in the cache
	//	
	//NSParameterAssert([result isKindOfClass:[NSArray class]]);
	EventFormattingOperation	*	op	=	[[EventFormattingOperation alloc] init];
	op.delegate							=	self;
	op.unprocessedEvents				=	(NSArray *)result;
	[coreDataQueue addOperation:op];
	[op release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Shows
#pragma mark -
/******************************************************************************/
- (void)processShowsList:(id)result count:(NSInteger)count
{
#define kCutoffShow 1300
	[coreDataQueue addOperationWithBlock:^(void) {
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		NSArray	*	shows	=	(NSArray *)result;
		//	
		//	Get a moc for this thread
		//	
		NSManagedObjectContext			*	showContext	=	[self managedObjectContext];
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		NSFetchRequest		*	request	=	[[NSFetchRequest alloc] init];
		NSEntityDescription	*	entity	=	[NSEntityDescription entityForName:@"Show" 
														inManagedObjectContext:showContext];
		request.entity					=	entity;
        request.relationshipKeyPathsForPrefetching  =   [NSArray arrayWithObject:@"Guest"];
		request.fetchLimit				=	count + 100;
		NSPredicate	*	predicate		=	[NSPredicate predicateWithFormat:@"Number >= %d or TV == YES", kCutoffShow];
		[request setPredicate:predicate];
		NSError		*	anError = nil;
		NSArray		*	fetchResults	=	[showContext executeFetchRequest:request error:&anError];
		if (fetchResults == nil)
		{	// Handle Error
			NSLog(@"%@", anError);
		}
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		for (NSDictionary *show in shows)
		{
			NSNumber	*	number			=	[show objectForKey:@"N"];
			NSInteger		numInt			=	0;
			if (number)
				numInt						=	[number intValue];
			NSNumber	*	isKATGTV		=	[show objectForKey:@"TV"];
			BOOL			isTV			=	NO;
			if (isKATGTV)
				isTV						=	[isKATGTV boolValue];
			
			//if (numInt > kCutoffShow) continue;
			if (numInt < kCutoffShow && !isTV) continue;
			
			NSNumber	*	ID				=	[show objectForKey:@"I"];
			
			Show		*	managedShow		=	nil;
			managedShow						=	[self hasShow:fetchResults 
														forID:ID];
			if (!managedShow)
				managedShow					=	(Show *)[NSEntityDescription insertNewObjectForEntityForName:@"Show" 
																					  inManagedObjectContext:showContext];
			
			NSString	*	guests			=	[show objectForKey:@"G"];
			NSNumber	*	pdt				=	[show objectForKey:@"PDT"];
			NSNumber	*	pictureCount	=	[show objectForKey:@"P"];
			NSNumber	*	hasShowNotes	=	[show objectForKey:@"SN"];
			NSString	*	title			=	[show objectForKey:@"T"];
			
			
			if (!guests || guests.length == 0 || [guests isEqualToString:@"NULL"])
				guests	=	NSLocalizedString(@"No Guest", @"");
			
			[managedShow setGuests:guests];
			
			if (ID)
			{
				[managedShow setID:ID];
			}
			if (number)
				[managedShow setNumber:[NSNumber numberWithInt:numInt]];
			if (pdt)
			{
				[managedShow setPDT:pdt];
			}
			if (pictureCount)
			{
				[managedShow setPictureCount:pictureCount];
			}
			if (hasShowNotes)
			{
				[managedShow setHasNotes:hasShowNotes];
			}
			if (title)
				[managedShow setTitle:title];
			
			if (isKATGTV)
				[managedShow setTV:isKATGTV];
		}
		//NSLog(@"Save Shows");
		NSError	*	error;
		if (![showContext save:&error])
		{	// Handle Error
			ESLog(@"Core Data Error %@", error);
		}
		[request release];
	}];
}
- (Show *)hasShow:(NSArray *)recentShows forID:(NSNumber *)ID
{
	for (Show *show in recentShows)
	{
		if ([show.ID isEqualToNumber:ID])
			return show;
	}
	return nil;
}
- (void)procesShowDetails:(NSDictionary *)details withID:(NSString *)ID
{
	[coreDataQueue addOperationWithBlock:^(void) {
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		NSPersistentStoreCoordinator	*	psc			=	[self.managedObjectContext persistentStoreCoordinator];
		NSManagedObjectContext			*	showContext	=	[[NSManagedObjectContext alloc] init];
		showContext.persistentStoreCoordinator			=	psc;
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		NSFetchRequest		*	request	=	[[NSFetchRequest alloc] init];
		NSEntityDescription	*	entity	=
		[NSEntityDescription entityForName:@"Show" 
					inManagedObjectContext:showContext];
		[request setEntity:entity];
		[request setFetchLimit:1];
		request.relationshipKeyPathsForPrefetching	=	[NSArray arrayWithObject:@"Guest"];
		NSPredicate	*	predicate	=
		[NSPredicate predicateWithFormat:@"ID == %@", ID];
		[request setPredicate:predicate];
		NSError		*	error;
		NSArray		*	fetchResults	=
		[showContext executeFetchRequest:request 
								   error:&error];
		if (fetchResults == nil)
		{	// Handle Error
			ESLog(@"%@", error);
#ifdef DEVELOPMENTBUILD
            abort();
#endif
		}
		if (fetchResults.count > 0)
		{
			Show		*	show	=	[fetchResults objectAtIndex:0];
			
			NSString	*	notes	=	[details objectForKey:@"Detail"];
			if (!notes || notes.length == 0 || [notes isEqualToString:@"NULL"])
				notes				=	@"No Show Notes";
			else
			{					
				notes	=	[notes stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n • "];
			}
			[show setNotes:[NSString stringWithFormat:@" • %@", notes]];
			
			NSString	*	quote	=	[details objectForKey:@"Description"];
			if (!quote || quote.length == 0 || [quote isEqualToString:@"NULL"])
				quote				=	@"No Quote";
			[show setQuote:quote];
			
			NSString	*	URL		=	[details objectForKey:@"FileUrl"];
			if (!URL || [URL isEqualToString:@"NULL"])
				URL				=	@"";
			[show setURL:URL];
			
			NSError	*	error;
			if (![showContext save:&error])
			{	// Handle Error
				ESLog(@"Core Data Error %@", error);
#ifdef DEVELOPMENTBUILD
				abort();
#endif
			}
			
			[self performSelectorOnMainThread:@selector(notifyShowDetails:) 
								   withObject:ID 
								waitUntilDone:NO];
		}
		[request release];
		[showContext release];
	}];
}
- (void)procesShowPictures:(NSArray *)pictures withID:(NSString *)ID
{
	[coreDataQueue addOperationWithBlock:^(void) {
		NSMutableArray *pictureObjects = [[NSMutableArray alloc] init];
		for (NSDictionary *picture in pictures)
		{
			NSString	*	thumbURL	=	[picture objectForKey:@"url"];
			NSString	*	url			=	ReplaceString(thumbURL, @"-Thumb", @"");
			if (!url || (url.length == 0))
				continue;
			
			Picture *pictureObject = [[Picture alloc] init];
			
			if (pictureObject)
			{
				pictureObject.URL			=	url;
				pictureObject.thumbURL		=	thumbURL;
				
				NSString	*	description	=	[picture objectForKey:@"description"];
				NSString	*	title		=	[picture objectForKey:@"title"];
				
				if (description)
					pictureObject.desc	=	description;
				
				if (title)
					pictureObject.title		=	title;
				
				[pictureObjects addObject:pictureObject];
			}
			
			[pictureObject release];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self notifyShowPictures:pictureObjects];
		});
		
		[pictureObjects release];
	}];
}
- (void)processGetImage:(NSData *)imgData forURL:(NSString *)url
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	[coreDataQueue addOperationWithBlock:^(void) {
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		UIImage	*	image	=	[UIImage imageWithData:imgData];
		if (!image)
		{
			return;
		}
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		CGFloat		scale	=	1.0;
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
			scale			=	[[UIScreen mainScreen] scale];
		if (scale != 1.0)
			image = [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
		
		[self addToCache:imgData key:url];
		
		[self performSelectorOnMainThread:@selector(notifyGetImageForURL:) 
							   withObject:url 
							waitUntilDone:NO];
	}];
}
/******************************************************************************/
#pragma mark -
#pragma mark Twitter
#pragma mark -
/******************************************************************************/
- (void)processTwitterSearchFeed:(id)result
{
	//	
	//	Decompose results into Tweet model objects
	//	
	self.twitterSearchRefreshURL	=	[(NSDictionary *)result objectForKey:@"refresh_url"];
	NSArray	*	results				=	[(NSDictionary *)result objectForKey:@"results"];
	if (results != nil)
		[self notifyTwitterSearchFeed:[self processTweets:results]];
}
- (NSArray *)processTweets:(NSArray *)tweets
{
	NSMutableArray	*	resultsProxy	=	[[NSMutableArray alloc] initWithCapacity:tweets.count];
	//	
	//	Create Regex to extract @handles (use NSCLassFromString for iOS < 4.0)
	//	
	NSError			*	errorAt			=	NULL;
	id					regexAt			=	[NSClassFromString(@"NSRegularExpression") regularExpressionWithPattern:@"@([\\w|_|\\d]+)"
																					   options:NSRegularExpressionCaseInsensitive
																						 error:&errorAt];
	NSError			*	errorHash		=	NULL;
	id					regexHash		=	[NSClassFromString(@"NSRegularExpression") regularExpressionWithPattern:@"#([\\w|_|\\d]+)"
																						options:NSRegularExpressionCaseInsensitive
																						  error:&errorHash];
	for (NSDictionary *result in tweets)
	{
		Tweet	*	tweet		=	[[Tweet alloc] init];
		tweet.From				=	[result objectForKey:kFromUserKey];
		CGFloat	scale			=	1.0;
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
			scale				=	[[UIScreen mainScreen] scale];
		if (scale == 2.0)
			tweet.ImageURL			=	[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@.json?size=bigger", tweet.From];
		else
			tweet.ImageURL			=	[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@.json?size=normal", tweet.From];
		NSString	*	text	=	[result objectForKey:kTextKey];
		tweet.Text				=	DecodeHTMLEntities(text);
		NSString	*	webText	=	[[text copy] autorelease];
		if (regexAt)
		{
			NSArray		*	matches	=	[regexAt matchesInString:text
												  options:0
													range:NSMakeRange(0, [text length])];
			for (NSTextCheckingResult *match in matches)
			{
				NSRange			matchRange	=	[match range];
				NSString	*	string		=	[text substringWithRange:matchRange];
				webText						=	ReplaceString(webText, string, [NSString stringWithFormat:@"<a href=\"tweet://%@\">%@</a>",  ReplaceString(string, @"@", @""), string]);
			}
		}
		if (regexHash)
		{
			NSArray		*	matches	=	[regexHash matchesInString:text
													options:0
													  range:NSMakeRange(0, [text length])];
			for (NSTextCheckingResult *match in matches)
			{
				NSRange			matchRange	=	[match range];
				NSString	*	string		=	[text substringWithRange:matchRange];
				webText						=	ReplaceString(webText, string, [NSString stringWithFormat:@"<a href=\"hashtag://%@\">%@</a>",  ReplaceString(string, @"#", @""), string]);
			}
		}
		tweet.WebViewText		=	webText;
		tweet.Date				=	[self.twitterSearchFormatter dateFromString:[result objectForKey:kDateKey]];
		
		[resultsProxy addObject:tweet];
		
		[tweet release]; tweet = nil;
	}
	
	return [(NSArray *)resultsProxy autorelease];
}
- (void)processTwitterUserFeed:(id)result user:(NSString *)user
{
	//	
	//	Decompose results into Tweet model objects
	//	
	[self notifyTwitterUserFeed:[self processUserTweets:(NSArray *)result user:user]];
}
- (NSArray *)processUserTweets:(NSArray *)tweets user:(NSString *)user
{
	NSMutableArray	*	resultsProxy	=	[[NSMutableArray alloc] initWithCapacity:tweets.count];
	//	
	//	Create Regex to extract @handles (use NSCLassFromString for iOS < 4.0)
	//	
	NSError			*	errorAt			=	NULL;
	id					regexAt			=	[NSClassFromString(@"NSRegularExpression") regularExpressionWithPattern:@"@([\\w|_|\\d]+)"
																					   options:NSRegularExpressionCaseInsensitive
																						 error:&errorAt];
	NSError			*	errorHash		=	NULL;
	id					regexHash		=	[NSClassFromString(@"NSRegularExpression") regularExpressionWithPattern:@"#([\\w|_|\\d]+)"
																						options:NSRegularExpressionCaseInsensitive
																						  error:&errorHash];
	for (NSDictionary *result in tweets)
	{
		Tweet	*	tweet		=	[[Tweet alloc] init];
		tweet.From				=	user;
		CGFloat	scale			=	1.0;
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
			scale				=	[[UIScreen mainScreen] scale];
		if (scale == 2.0)
			tweet.ImageURL			=	[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@.json?size=bigger", user];
		else
			tweet.ImageURL			=	[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image/%@.json?size=normal", user];
		NSString	*	text	=	[result objectForKey:kTextKey];
		tweet.Text				=	text;
		NSString	*	webText	=	[[text copy] autorelease];
		if (regexAt)
		{
			NSArray		*	matches	=	[regexAt matchesInString:text
												  options:0
													range:NSMakeRange(0, [text length])];
			for (NSTextCheckingResult *match in matches)
			{
				NSRange			matchRange	=	[match range];
				NSString	*	string		=	[text substringWithRange:matchRange];
				webText						=	ReplaceString(webText, string, [NSString stringWithFormat:@"<a href=\"tweet://%@\">%@</a>",  ReplaceString(string, @"@", @""), string]);
			}
		}
		if (regexHash)
		{
			NSArray		*	matches	=	[regexHash matchesInString:text
													options:0
													  range:NSMakeRange(0, [text length])];
			for (NSTextCheckingResult *match in matches)
			{
				NSRange			matchRange	=	[match range];
				NSString	*	string		=	[text substringWithRange:matchRange];
				webText						=	ReplaceString(webText, string, [NSString stringWithFormat:@"<a href=\"hashtag://%@\">%@</a>",  ReplaceString(string, @"#", @""), string]);
			}
		}
		tweet.WebViewText		=	webText;
		tweet.Date				=	[self.twitterUserFormatter dateFromString:[result objectForKey:kDateKey]];
		
		[resultsProxy addObject:tweet];
		
		[tweet release]; tweet = nil;
	}
	
	return [(NSArray *)resultsProxy autorelease];
}
- (void)processTwitterHashTagFeed:(id)result
{
	//	
	//	Decompose results into Tweet model objects
	//	
	//self.twitterSearchRefreshURL	=	[(NSDictionary *)result objectForKey:@"refresh_url"];
	NSArray	*	results				=	[(NSDictionary *)result objectForKey:@"results"];
	if (results != nil)
		[self notifyTwitterHashTagFeed:[self processTweets:results]];
}
- (void)processGetTwitterImage:(NSData *)imgData forURL:(NSString *)url
{
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	[coreDataQueue addOperationWithBlock:^(void) {
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		UIImage	*	thumb	=	[UIImage imageWithData:imgData];
		if (!thumb)
		{
			NSLog(@"%@", [[[NSString alloc] initWithData:imgData encoding:NSUTF8StringEncoding] autorelease]);
			return;
		}
		CGFloat		scale	=	1.0;
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
			scale			=	[[UIScreen mainScreen] scale];
		if (scale == 2.0)
		{ // Scaling the 73 pixel bigger size twitter provides up to 96 to be double
			// the size of the normal 48 so that it can be made into an image
			// with a 2.0 scale. Not optimal, but better than a 48 pixel 1.0 scale image.
			thumb			=	[thumb scaledToSize:CGSizeMake(96.0, 96.0)];
		}
		else
		{
			if ((thumb.size.width > 48.0 || thumb.size.height > 48.0))
				thumb		=	[thumb scaledToSize:CGSizeMake(48.0, 48.0)];
		}
		
		NSData	*	thumbData	=	UIImagePNGRepresentation(thumb);
		
		if (thumbData)
			[self addToCache:thumbData key:url];
		else 
			ESLog(@"Image missed %@", [[[NSString alloc] initWithData:imgData encoding:NSUTF8StringEncoding] autorelease]);
		
		[self performSelectorOnMainThread:@selector(notifyGetTwitterImageForURL:) 
							   withObject:url 
							waitUntilDone:NO];
	}];
}
- (void)addToCache:(id<NSObject>)object key:(id)key
{
	//	
	//  /*UNREVISEDCOMMENT*/
	//	
	@synchronized(pictureCacheDictionary)
	{
		[pictureCacheDictionary setObject:object forKey:key];
		if (pictureCacheDictionary.count > 300)
		{
			[pictureCacheDictionary removeObjectFromIndex:100 To:(pictureCacheDictionary.count - 1)];
		}
	}
}

@end
