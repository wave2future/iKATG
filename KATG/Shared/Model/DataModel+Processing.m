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
#import "Guest.h"
#import "Tweet.h"
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
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			NSParameterAssert(([(NSArray *)result count] > 0));
			if ([(NSArray *)result count] > 0)
				[self procesShowDetails:[(NSArray *)result objectAtIndex:0] 
								 withID:[operation.bodyBufferDict objectForKey:kShowIDKey]];
			break;
		case kShowPicturesCode:
			NSParameterAssert([result isKindOfClass:[NSArray class]]);
			//NSParameterAssert(([(NSArray *)result count] > 0));
			NSLog(@"%@", result);
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
			[self notifyError:[NSError errorWithDomain:@"Events Unavailable" 
												  code:kEventsListCode 
											  userInfo:nil] display:NO];
			break;
		case kShowArchivesCode:
			
			break;
		case kShowDetailsCode:
			
			break;
		default:
			break;
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification
{
	//	
	//	Merge in any changes in other mocs on the main thread
	//	
	if ([NSThread isMainThread])
		[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	else
		[self performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) 
							   withObject:notification 
							waitUntilDone:NO];
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
	NSParameterAssert(([[(NSDictionary *)result objectForKey:kOnAirKey] isEqualToString:@"0"] ||
					   [[(NSDictionary *)result objectForKey:kOnAirKey] isEqualToString:@"1"]));
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
- (void)processChatLoginPhaseOne:(id)result 
				userName:(NSString *)userName 
				password:(NSString *)password
{
	CXMLDocument	*	htmlParser	=	[[[CXMLDocument alloc] 
										  initWithData:(NSData *)result 
										  options:0 
										  error:nil] autorelease];
	NSParameterAssert((htmlParser != nil));
	
	NSDictionary	*	nameSpace	=	[NSDictionary dictionaryWithObject:@"http://www.w3.org/1999/xhtml" 
																	forKey:@"xhtml"];
	NSArray			*	inputArray	=	[htmlParser nodesForXPath:@"//xhtml:input"
												namespaceMappings:nameSpace 
															error:nil];
	NSParameterAssert((inputArray != nil));
	NSParameterAssert((inputArray.count != 0));
	
	NSString		*	viewState	=	nil;
	NSString		*	eventValidation	=	nil;
	
	for (CXMLElement *input in inputArray)
	{
		if ([[[input attributeForName:@"name"] stringValue] isEqualToString:@"__VIEWSTATE"])
			viewState	=	[[[input attributeForName:@"value"] stringValue] copy];
		else if ([[[input attributeForName:@"name"] stringValue] isEqualToString:@"__EVENTVALIDATION"])
			eventValidation	=	[[[input attributeForName:@"value"] stringValue] copy];
		if (viewState && eventValidation)
			break;
	}
	if (viewState && 
		eventValidation && 
		userName && 
		password)
	{
		NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
		op.delegate					=	self;
		op.instanceCode				=	kChatLoginPhaseTwoCode;
		op.baseURL					=	kChatLoginBaseURLAddress;
		op.URI						=	kChatLoginURIAddress;
		op.requestType				=	POST;
		op.bodyBufferDict			=	[NSDictionary dictionaryWithObjectsAndKeys:
										 userName,			@"Username",
										 password,			@"password",
										 @"Login",			@"ButtonLogin",
										 viewState,			@"__VIEWSTATE", 
										 eventValidation,	@"__EVENTVALIDATION", nil];
		[operationQueue addOperation:op];
		[op release];
	}
	else
	{
		//	error
	}
	[viewState release];
	[eventValidation release];
}
- (void)processChatLoginPhaseTwo:(id)result
{
	NSString	*	response	=	[[[NSString alloc] 
									  initWithData:(NSData *)result 
									  encoding:NSUTF8StringEncoding] autorelease];
	if ([response rangeOfString:@"Login successful!"].location != NSNotFound)
	{
		[self notifyLogin];
		[self chatStart];
	}
	else
	{
		CXMLDocument	*	htmlParser	=	[[[CXMLDocument alloc] initWithData:(NSData *)result 
																		options:0 
																		  error:nil] autorelease];
		NSParameterAssert((htmlParser != nil));
		
		NSDictionary	*	nameSpace	=	[NSDictionary dictionaryWithObject:@"http://www.w3.org/1999/xhtml" 
															   forKey:@"xhtml"];
		NSArray			*	fontArray	=	[htmlParser nodesForXPath:@"//xhtml:font" 
										 namespaceMappings:nameSpace 
													 error:nil];
		NSParameterAssert((fontArray != nil));
		NSParameterAssert((fontArray.count != 0));
		
		CXMLElement		*	font		=	[fontArray objectAtIndex:0];
		NSParameterAssert((font != nil));
		
		if ([[font stringValue] isEqualToString:@"Incorrect password"])
		{
			[self notifyError:[NSError errorWithDomain:@"Login Failed - Incorrect Password" 
												  code:kChatLoginPhaseTwoCode 
											  userInfo:nil] 
					  display:YES];
		}
		else if ([[font stringValue] rangeOfString:@"Not a valid user name"].location != NSNotFound)
		{
			[self notifyError:[NSError errorWithDomain:@"Login Failed - Invalid Username" 
												  code:kChatLoginPhaseTwoCode 
											  userInfo:nil] 
					  display:YES];
		}
		else 
		{
			[self notifyError:[NSError errorWithDomain:@"Login Failed" 
												  code:kChatLoginPhaseTwoCode 
											  userInfo:nil] 
					  display:YES];
		}
	}
}
- (void)processChatStartPhaseOne:(id)result
{
	NSString			*	html	=	[[[NSString alloc] initWithData:(NSData *)result encoding:NSUTF8StringEncoding] autorelease];
	NSError				*	error	=	NULL;
	NSRegularExpression	*	regex	=	[NSRegularExpression regularExpressionWithPattern:@"clientid='([0-9a-fA-F-]*)"
																				  options:0
																					error:&error];
	NSArray				*	matches	=	[regex matchesInString:html
													   options:0
														 range:NSMakeRange(0, [html length])];
	NSString			*	clientID=	nil;
	if (matches.count > 0)
	{
		NSTextCheckingResult	*	result	=	[matches objectAtIndex:0];
		NSRange	range;
		if (result.numberOfRanges == 1)
		{
			range	=	[result rangeAtIndex:0];
			NSArray	*	splitArray	=	[[html substringWithRange:range] componentsSeparatedByString:@"='"];
			if (splitArray.count == 2)
				clientID	=	[[splitArray objectAtIndex:1] retain];
		}
		else if (result.numberOfRanges > 1)
		{
			range	=	[result rangeAtIndex:1];
			clientID=	[[html substringWithRange:range] retain];
		}
		[clientID autorelease];
	}
	if (clientID != nil)
	{
		NetworkOperation	*	op	=	[[NetworkOperation alloc] init];
		op.delegate					=	self;
		op.instanceCode				=	kChatStartCodePhaseTwo;	
		
		NSString	*	unixTime	=	[NSString stringWithFormat:@"%d-%18.17f", 
										 (long)[[NSDate date] timeIntervalSince1970],
										 (float)random()/RAND_MAX];
		NSString	*	url			=	[NSString stringWithFormat:@"http://www.keithandthegirl.com/Chat/ChatClient/chat.rane.js.aspx?type=invoke&rand=%@", unixTime];
		
		NSMutableURLRequest	*	request	=
		[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] 
								cachePolicy:NSURLRequestUseProtocolCachePolicy 
							timeoutInterval:15.0];
		[request setHTTPMethod:@"POST"];
		[request addValue:@"CuteSoft.Chat.ChatRaneService, CuteSoft.Chat, Version=3.1.0.0, Culture=neutral, PublicKeyToken=da0fc3a24b6f18ba" 
		 forHTTPHeaderField:@"ranetype"];
		[request addValue:@"Connect" 
		 forHTTPHeaderField:@"ranemethod"];
		[request addValue:@"no-cache" 
	   forHTTPHeaderField:@"Pragma"];
		[request addValue:@"no-cache" 
	   forHTTPHeaderField:@"Cache-Control"];
		[request addValue:@"Referer" 
	   forHTTPHeaderField:@"http://www.keithandthegirl.com/chat/chatroom.aspx"];
		NSString	*	bodyPayload	=	[NSString stringWithFormat:@"#<rane><request><arg#Ct=\"complex\"><i#Cv=\"%@\"#Ct=\"string\"#Cp=\"ClientId\"></i><i#Cv=\"Lobby\"#Ct=\"string\"#Cp=\"Location\"></i><i#Cv=\"1\"#Ct=\"string\"#Cp=\"LocationId\"></i><i#Ct=\"undefined\"#Cp=\"GuestName\"></i><i#Ct=\"undefined\"#Cp=\"Password\"></i><i#Cv=\"DHTML\"#Ct=\"string\"#Cp=\"Software\"></i><i#Ct=\"undefined\"#Cp=\"InstantTargetUserId\"></i></arg></request></rane>", clientID];
		//NSString	*	bodyPayload	=	EncodeHTMLEntities([NSString stringWithFormat:@"#<rane><request><arg#Ct=\"complex\"><i#Cv=\"%@\"#Ct=\"string\"#Cp=\"ClientId\"></i><i#Cv=\"Lobby\"#Ct=\"string\"#Cp=\"Location\"></i><i#Cv=\"1\"#Ct=\"string\"#Cp=\"LocationId\"></i><i#Ct=\"undefined\"#Cp=\"GuestName\"></i><i#Ct=\"undefined\"#Cp=\"Password\"></i><i#Cv=\"DHTML\"#Ct=\"string\"#Cp=\"Software\"></i><i#Ct=\"undefined\"#Cp=\"InstantTargetUserId\"></i></arg></request></rane>", clientID]);
		[request setHTTPBody:
		 [bodyPayload dataUsingEncoding:NSUTF8StringEncoding]];
		op.request					=	request;
		
		[operationQueue addOperation:op];
		[op release];
	}
}
- (void)processChatStartPhaseTwo:(id)result
{
	NSLog(@"%@", [[[NSString alloc] initWithData:(NSData *)result encoding:NSUTF8StringEncoding] autorelease]);
}
- (void)processChatPolling:(id)result
{
	CXMLDocument	*	parser	=	[[[CXMLDocument alloc] 
									  initWithData:(NSData *)result 
									  options:0 
									  error:nil] autorelease];
	NSArray	*	resultNodes	=
	[parser nodesForXPath:@"//i[@p='Message']" 
					error:nil];
	for (CXMLNode *node in resultNodes)
	{
		NSArray		*	textNodes	=	[node nodesForXPath:@"//i[@p='MessageText']" error:nil];
		CXMLElement	*	textNode	=	[textNodes objectAtIndex:0];
		NSString	*	text		=	[[textNode attributeForName:@"v"] stringValue];
		
		NSArray		*	whisperNodes	=	[node nodesForXPath:@"//i[@p='Whisper']" error:nil];
		CXMLElement	*	whisperNode		=	[whisperNodes objectAtIndex:0];
		NSString	*	whisper			=	[[whisperNode attributeForName:@"v"] stringValue];
		
		NSArray		*	senderNodes	=	[node nodesForXPath:@"//i[@p='DisplayName']" error:nil];
		CXMLElement	*	senderNode	=	[senderNodes objectAtIndex:0];
		NSString	*	sender		=	[[senderNode attributeForName:@"v"] stringValue];
		
		NSLog(@"Message From %@ : %@ (Whisper: %@)", sender, text, whisper);
	}
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
#define kCutoffShow 1200
	[coreDataQueue addOperationWithBlock:^() {
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		NSArray	*	shows	=	(NSArray *)result;
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
		NSEntityDescription	*	entity	=	[NSEntityDescription entityForName:@"Show" 
														inManagedObjectContext:showContext];
		request.entity					=	entity;
        request.relationshipKeyPathsForPrefetching  =   [NSArray arrayWithObject:@"Guest"];
		request.fetchLimit				=	count + 100;
		NSPredicate	*	predicate		=	[NSPredicate predicateWithFormat:@"Number >= kCutoffShow or TV == YES"];
		[request setPredicate:predicate];
		NSError		*	anError;
		NSArray		*	fetchResults	=	[managedObjectContext executeFetchRequest:request 
																				error:&anError];
		if (fetchResults == nil)
		{	// Handle Error
			NSLog(@"%@", anError);
		}
		//	
		//	/*UNREVISEDCOMMENTS*/
		//	
		for (NSDictionary *show in shows)
		{
			NSString	*	number			=	[show objectForKey:@"N"];
			NSInteger		numInt			=	0;
			if (number)
				numInt						=	[number intValue];
			NSString	*	isKATGTV		=	[show objectForKey:@"TV"];
			BOOL			isTV			=	NO;
			if (isKATGTV)
				isTV						=	[isKATGTV boolValue];
			
			//if (numInt > kCutoffShow) continue;
			if (numInt < kCutoffShow && !isTV) continue;
			
			NSString	*	ID				=	[show objectForKey:@"I"];
			
			Show	*	managedShow			=	nil;
			managedShow						=	[self hasShow:fetchResults 
														forID:[NSNumber numberWithInt:[ID intValue]]];
			if (!managedShow)
				managedShow					=	(Show *)[NSEntityDescription insertNewObjectForEntityForName:@"Show" 
																					  inManagedObjectContext:showContext];
			
			NSString	*	guests			=	[show objectForKey:@"G"];
			NSString	*	pdt				=	[show objectForKey:@"PDT"];
			NSString	*	pictureCount	=	[show objectForKey:@"P"];
			NSString	*	hasShowNotes	=	[show objectForKey:@"SN"];
			NSString	*	title			=	[show objectForKey:@"T"];
			
			NSSet		*	existingGuests	=	[managedShow Guests];
			if (!guests || guests.length == 0 || [guests isEqualToString:@"NULL"])
				guests						=	@"No Guest";
			
			if ([guests rangeOfString:@","].location != NSNotFound)
			{
				NSArray	*	guestArray		=	[guests componentsSeparatedByString:@","];
				if (guestArray && guestArray.count > 0)
				{
					for (NSString *guest in guestArray)
					{
						BOOL	exists	=	NO;
						for (Guest *existingGuest in existingGuests)
						{
							if ([[existingGuest Guest] isEqualToString:guest])
							{
								exists	=	YES;
								break;
							}
						}
						if (exists)
							continue;
						Guest	*	managedGuest	=
						(Guest *)[NSEntityDescription insertNewObjectForEntityForName:@"Guest" 
															   inManagedObjectContext:showContext];
						[managedGuest addShowObject:managedShow];
						[managedGuest setGuest:guest];
						[managedShow addGuestsObject:managedGuest];
					}
				}
			}
			else
			{
				BOOL	exists	=	NO;
				for (Guest *existingGuest in existingGuests)
				{
					if ([[existingGuest Guest] isEqualToString:guests])
					{
						exists	=	YES;
						break;
					}
				}
				if (!exists)
				{
					Guest	*	managedGuest	=
					(Guest *)[NSEntityDescription insertNewObjectForEntityForName:@"Guest" 
														   inManagedObjectContext:showContext];
					[managedGuest addShowObject:managedShow];
					[managedGuest setGuest:guests];
					[managedShow addGuestsObject:managedGuest];
				}
			}
			if (ID)
			{
				NSInteger	idInt	=	[ID intValue];
				[managedShow setID:[NSNumber numberWithInt:idInt]];
			}
			if (number)
				[managedShow setNumber:[NSNumber numberWithInt:numInt]];
			if (pdt)
			{
				double	pdtDouble	=	[pdt doubleValue];
				[managedShow setPDT:[NSNumber numberWithDouble:pdtDouble]];
			}
			if (pictureCount)
			{
				NSInteger	picCnt	=	[pictureCount intValue];
				[managedShow setPictureCount:[NSNumber numberWithInt:picCnt]];
			}
			if (hasShowNotes)
			{
				BOOL	hasShwNts	=	[hasShowNotes boolValue];
				[managedShow setHasNotes:[NSNumber numberWithBool:hasShwNts]];
			}
			if (title)
			{
				[managedShow setTitle:title];
			}
			if (isKATGTV)
				[managedShow setTV:[NSNumber numberWithBool:isTV]];
		}
		//NSLog(@"Save Shows");
		NSError	*	error;
		if (![showContext save:&error])
		{	// Handle Error
			ESLog(@"Core Data Error %@", error);
#ifdef DEVELOPMENTBUILD
            abort();
#endif
		}
		[request release];
		[showContext release];
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
	[coreDataQueue addOperationWithBlock:^() {
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
	[coreDataQueue addOperationWithBlock:^() {
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
		request.relationshipKeyPathsForPrefetching	=	[NSArray arrayWithObject:@"Pictures"];
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
			
		}
		[request release];
		[showContext release];
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
	[coreDataQueue addOperationWithBlock:^() {
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
			for (int i = 0; i < 100; i++)
			{
				[pictureCacheDictionary removeObjectForKey:[[pictureCacheDictionary allKeys] objectAtIndex:i]];
			}
		}
	}
}

@end
