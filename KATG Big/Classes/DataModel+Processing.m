//
//  DataModel+Processing.m
//
//  Created by Doug Russell on 5/5/10.
//  Copyright 2010 Doug Russell. All rights reserved.
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
#import "DataModel+Notification.h"
#import "Event.h"
#import "Show.h"
#import "Guest.h"

@implementation DataModel (Processing)
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification
{
	if ([NSThread isMainThread])
		[self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	else
		[self performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) 
							   withObject:notification 
							waitUntilDone:NO];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Operation Delegates
#pragma mark -
/******************************************************************************/
- (void)dataOperationDidFinish:(DataOperation *)op
{
	
}
- (void)dataOperationDidFail:(DataOperation *)op withError:(NSError *)error
{
	
}
/******************************************************************************/
#pragma mark -
#pragma mark Events
#pragma mark -
/******************************************************************************/
- (void)processEventsList:(NSArray *)entries
{
	//	
	//	Use data formatters to create localized event
	//	strings and store them in core data store
	//	
	if (entries && entries.count > 0)
	{
		//	
		//	Create a context for use on this thread
		//	
		NSPersistentStoreCoordinator	*	psc				=	[self.managedObjectContext persistentStoreCoordinator];
		NSManagedObjectContext			*	eventContext	=	[[NSManagedObjectContext alloc] init];
		eventContext.persistentStoreCoordinator				=	psc;
		[eventContext setPropagatesDeletesAtEndOfEvent:NO];
		//	
		//	Get Current Events for comparison later
		//	
		NSArray	*	currentEvents	=	[self currentEvents:eventContext];
		//	
		//	Decompose event dictionaries into managed objects
		//	
		[entries enumerateObjectsWithOptions:NSEnumerationReverse 
								  usingBlock: ^ void (id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary*	event			=	(NSDictionary *)obj;
			NSDictionary*	dateTimes		=	[self dateFormatters:event];
			NSDate		*	dateTime		=	[dateTimes objectForKey:@"DateTime"];
			NSString	*	title			=	[event objectForKey:@"Title"];
			NSString	*	eventID			=	[event objectForKey:@"EventId"];
			
			if ([self futureTest:dateTime] &&
				  title != nil)
			{
				Event	*	managedEvent	=	[self hasEvent:currentEvents withEventID:eventID];
				  if (managedEvent == nil)
					  managedEvent = (Event *)[NSEntityDescription insertNewObjectForEntityForName:@"Event" 
																			inManagedObjectContext:eventContext];
				  [managedEvent setKeep:[NSNumber numberWithBool:YES]];
				  [managedEvent setTitle:title];
				  [managedEvent setEventID:eventID];
				  [managedEvent setDateTime:dateTime];
				  
				  NSString	*	details		=	[event objectForKey:@"Details"];
				  if (!details || [details isEqualToString:@"NULL"]) details	=	@"";
				  [managedEvent setDetails:details];
				  
				  NSString	*	day			=	[dateTimes objectForKey:@"Day"];
				  if (!day)		day			=	@"";
				  [managedEvent setDay:day];
				  
				  NSString	*	date		=	[dateTimes objectForKey:@"Date"];
				  if (!date)		date		=	@"";
				  [managedEvent setDate:date];
				  
				  NSString	*	time		=	[dateTimes objectForKey:@"Time"];
				  if (!time)		time		=	@"";
				  [managedEvent setTime:time];
				  
				NSNumber	*	showType	=	[self detectShowType:event];
				  if (!showType)	showType	=	[NSNumber numberWithBool:YES];
				  [managedEvent setShowType:showType];
				  
				  NSError *error;
				  if (![eventContext save:&error])
				  {	// Handle Error
					  NSLog(@"Core Data Error %@", error);
				  }
			}
		}];
		dispatch_async(dispatch_get_main_queue(), ^{
			for (Event * event in currentEvents)
			{
				if (![[event Keep] boolValue])
				{
					[eventContext deleteObject:event];
					NSError	*	error;
					if (![eventContext save:&error])
					{// Handle Error
						NSLog(@"Core Data Error %@", error);
					}
				}
			}
		});
		[eventContext release];
	}
}
- (NSDictionary *)dateFormatters:(NSDictionary *)event
{
	NSDictionary	*	dateTimes = nil;
	NSString		*	eventTimeString	=	[event objectForKey:@"StartDate"];
	NSDate			*	eventDateTime	=	[formatter dateFromString:eventTimeString];
	NSString		*	eventDay		=	[dayFormatter stringFromDate:eventDateTime];
	NSString		*	eventDate		=	[dateFormatter stringFromDate:eventDateTime];
	NSString		*	eventTime		=	[timeFormatter stringFromDate:eventDateTime];
	if (eventDateTime &&
		eventDay &&
		eventDate &&
		eventTime)
	{
		dateTimes =
		[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
											 eventDateTime, 
											 eventDay, 
											 eventDate, 
											 eventTime, nil] 
									forKeys:[NSArray arrayWithObjects:
											 @"DateTime",
											 @"Day",
											 @"Date",
											 @"Time", nil]];
	}
	else
	{
		ESLog(@"Date Formatting Failed");
	}
	return dateTimes;
}
- (NSNumber *)detectShowType:(NSDictionary *)event
{
	if ([[event objectForKey:@"Title"] rangeOfString:@"Live Show"].location != NSNotFound)
		return [NSNumber numberWithBool:YES];
	else
		return [NSNumber numberWithBool:NO];
}
- (BOOL)futureTest:(NSDate *)date
{
	NSInteger	timeSince	=	[date timeIntervalSinceNow];
	NSInteger	threshHold	=	-(60/*Seconds*/ * 60 /*Minutes*/ * 12 /*Hours*/);
	BOOL		inFuture	=	(timeSince > threshHold);
	return inFuture;
}
- (NSArray *)currentEvents:(NSManagedObjectContext *)context
{
	//	
	//	Create a request for events
	//	
	NSFetchRequest		*	request	=	[[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription	*	entity	=
	[NSEntityDescription entityForName:@"Event" 
				inManagedObjectContext:context];
	[request setEntity:entity];
	NSError		*	error;
	NSArray		*	fetchResults	=
	[context executeFetchRequest:request 
						   error:&error];
	[fetchResults makeObjectsPerformSelector:@selector(setKeep:) withObject:[NSNumber numberWithBool:NO]];
	return fetchResults;
}
- (Event *)hasEvent:(NSArray *)events withEventID:(NSString *)eventID
{
	if (eventID == nil)
		return nil;
	NSUInteger	index	=
	[events indexOfObjectPassingTest: ^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
		return ([[(Event *)obj EventID] isEqualToString:eventID]);
	}];
	if (index != NSNotFound)
		return (Event *)[events objectAtIndex:index];
	else
		return nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Live Show Status
#pragma mark -
/******************************************************************************/
- (void)processLiveShowStatus:(NSArray *)entries
{
	//	
	//	Shoutcast feed status
	//	
	if (entries && entries.count > 0)
	{
		NSDictionary	*	status	=	[entries objectAtIndex:0];
		if (status)
		{
			NSString	*	onAir	=	[status objectForKey:@"OnAir"];
			[self performSelectorOnMainThread:@selector(notifyLiveShowStatus:) 
								   withObject:onAir 
								waitUntilDone:NO];
		}
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Show Archives
#pragma mark -
/******************************************************************************/
- (void)processShowsList:(NSArray *)entries
{
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
	request.fetchLimit				=	1;
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	if (entries && entries.count > 0)
	{
		for (NSDictionary *show in entries)
		{
			NSString	*	ID				=	[show objectForKey:@"I"];
			
			if ([self hasShow:request forID:[NSNumber numberWithInt:[ID intValue]]])
				continue;
			
			Show	*	managedShow = 
			(Show *)[NSEntityDescription insertNewObjectForEntityForName:@"Show" 
												  inManagedObjectContext:showContext];
			
			NSString	*	guests			=	[show objectForKey:@"G"];
			NSString	*	number			=	[show objectForKey:@"N"];
			NSString	*	pictureCount	=	[show objectForKey:@"P"];
			NSString	*	hasShowNotes	=	[show objectForKey:@"SN"];
			NSString	*	title			=	[show objectForKey:@"T"];
			NSString	*	isKATGTV		=	[show objectForKey:@"TV"];
			
			if (!guests || guests.length == 0 || [guests isEqualToString:@"NULL"])
				guests						=	@"No Guest";
			
			if ([guests rangeOfString:@","].location != NSNotFound)
			{
				NSArray	*	guestArray		=	[guests componentsSeparatedByString:@","];
				if (guestArray && guestArray.count > 0)
				{
					for (NSString *guest in guestArray)
					{
						Guest	*	managedGuest	=
						(Guest *)[NSEntityDescription insertNewObjectForEntityForName:@"Guest" 
															   inManagedObjectContext:showContext];
						
						[managedGuest addShowObject:managedShow];
						
						[managedGuest setGuest:guest];
						
						[managedShow addGuestsObject:managedGuest];
						
						NSError	*	error;
						if (![showContext save:&error])
						{	// Handle Error
							ESLog(@"Core Data Error %@", error);
						}
					}
				}
			}
			else
			{
				Guest	*	managedGuest	=
				(Guest *)[NSEntityDescription insertNewObjectForEntityForName:@"Guest" 
													   inManagedObjectContext:showContext];
				
				[managedGuest addShowObject:managedShow];
				
				[managedGuest setGuest:guests];
				
				[managedShow addGuestsObject:managedGuest];
				
				NSError	*	error;
				if (![showContext save:&error])
				{	// Handle Error
					ESLog(@"Core Data Error %@", error);
				}
			}
			
			if (ID)
			{
				NSInteger	idInt	=	[ID intValue];
				[managedShow setID:[NSNumber numberWithInt:idInt]];
			}
			if (number)
			{
				NSInteger	numInt	=	[number intValue];
				[managedShow setNumber:[NSNumber numberWithInt:numInt]];
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
			{
				BOOL	isTV	=	[isKATGTV boolValue];
				[managedShow setTV:[NSNumber numberWithBool:isTV]];
			}
			
			NSError	*	error;
			if (![showContext save:&error])
			{	// Handle Error
				ESLog(@"Core Data Error %@", error);
			}
		}
	}
	[request release];
	[showContext release];
}
- (BOOL)hasShow:(NSFetchRequest *)request forID:(NSNumber *)ID
{
	NSPredicate	*	predicate		=	[NSPredicate predicateWithFormat:@"ID == %@", ID];
	[request setPredicate:predicate];
	NSError		*	error;
	NSArray		*	fetchResults	=	[managedObjectContext executeFetchRequest:request 
																  error:&error];
	if (fetchResults == nil)
	{	// Handle Error
		NSLog(@"%@", error);
	}
	if (fetchResults.count > 0)
		return YES;
	return NO;
}
/******************************************************************************/
#pragma mark -
#pragma mark Show Details
#pragma mark -
/******************************************************************************/
- (void)procesShowDetails:(NSArray *)entries withID:(NSString *)ID
{
	if (entries && entries.count > 0)
	{
		// Create a MOC for this call
		NSDictionary	*	details	=	[entries objectAtIndex:0];
		NSFetchRequest		*	request	=	[[NSFetchRequest alloc] init];
		NSEntityDescription	*	entity	=
		[NSEntityDescription entityForName:@"Show" 
					inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		[request setFetchLimit:1];
		NSPredicate	*	predicate	=
		[NSPredicate predicateWithFormat:@"ID == %@", ID];
		[request setPredicate:predicate];
		NSError		*	error;
		NSArray		*	fetchResults	=
		[managedObjectContext executeFetchRequest:request 
											error:&error];
		if (fetchResults == nil)
		{	// Handle Error
			ESLog(@"%@", error);
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
			
			ESLog(@"%@", show);
			
			NSError	*	error;
			if (![self.managedObjectContext save:&error])
			{	// Handle Error
				ESLog(@"Core Data Error %@", error);
			}
			
			[self performSelectorOnMainThread:@selector(notifyShowDetails:) 
								   withObject:ID 
								waitUntilDone:NO];
		}
		[request release];
	}
}

@end
