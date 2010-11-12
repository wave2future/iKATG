//
//  EventOperation.m
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

#import "EventFormattingOperation.h"
#import "Event.h"
#import "EGOCache.h"
#import "DataModel.h"
#import "DataModel+Notifications.h"

@interface EventFormattingOperation ()

@property (nonatomic, readonly)	NSDateFormatter	*	formatter;
@property (nonatomic, readonly)	NSDateFormatter	*	dayFormatter;
@property (nonatomic, readonly)	NSDateFormatter	*	dateFormatter;
@property (nonatomic, readonly)	NSDateFormatter	*	timeFormatter;

- (NSDictionary *)dateFormatters:(NSDictionary *)event;
- (NSNumber *)detectShowType:(NSDictionary *)event;
- (BOOL)futureTest:(NSDate *)date;

@end

@implementation EventFormattingOperation
@synthesize	delegate = _delegate;
@synthesize unprocessedEvents = _unprocessedEvents;
@dynamic	formatter, dayFormatter, dateFormatter, timeFormatter;

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		_unprocessedEvents	=	nil;
		_formatter			=	nil;
		_dayFormatter		=	nil;
		_dateFormatter		=	nil;
		_timeFormatter		=	nil;
	}
	return self;
}
- (void)dealloc
{
	[_unprocessedEvents release];
	[_formatter release];
	[_dayFormatter release];
	[_dateFormatter release];
	[_timeFormatter release];
	[super dealloc];
}
- (NSDateFormatter *)formatter
{
	if (_formatter)
		return _formatter;
	//	
	//	Initial formatter for creating data object for event
	//	
	_formatter	=	[[NSDateFormatter alloc] init];
	[_formatter setDateStyle: NSDateFormatterLongStyle];
	[_formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[_formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
	NSTimeZone	*	timeZone	=	[NSTimeZone timeZoneWithName:@"America/New_York"];
	[_formatter setTimeZone:timeZone];
	return _formatter;
}
- (NSDateFormatter *)dayFormatter
{
	if (_dayFormatter)
		return _dayFormatter;
	//	
	//	Create localized data string for Day of the Week
	//	
	_dayFormatter	=	[[NSDateFormatter alloc] init];
	[_dayFormatter setDateStyle: NSDateFormatterLongStyle];
	[_dayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[_dayFormatter setDateFormat: @"EEE"];
	[_dayFormatter setLocale:[NSLocale currentLocale]];
	return _dayFormatter;
}
- (NSDateFormatter *)dateFormatter
{
	if (_dateFormatter)
		return _dateFormatter;
	//	
	//	Create localized data string for Month and Day of the Month
	//	
	_dateFormatter	=	[[NSDateFormatter alloc] init];
	[_dateFormatter setDateStyle: NSDateFormatterLongStyle];
	[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[_dateFormatter setDateFormat: @"MM/dd"];
	[_dateFormatter setLocale:[NSLocale currentLocale]];
	return _dateFormatter;
}
- (NSDateFormatter *)timeFormatter
{
	if (_timeFormatter)
		return _timeFormatter;
	//	
	//	Create localized data string for Time of Day
	//	
	_timeFormatter	=	[[NSDateFormatter alloc] init];
	[_timeFormatter setDateStyle: NSDateFormatterLongStyle];
	[_timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[_timeFormatter setDateFormat: @"h:mm aa"];
	[_timeFormatter setLocale:[NSLocale currentLocale]];
	return _timeFormatter;
}
- (void)main
{
	NSAutoreleasePool	*	pool	=	[[NSAutoreleasePool alloc] init];
	//	
	//	Decompose event dictionaries into managed objects
	//	
	NSMutableArray	*	processedEvents	=	[[NSMutableArray alloc] initWithCapacity:[self.unprocessedEvents count]];
	for (NSDictionary *event in self.unprocessedEvents) 
	{
		NSDictionary*	dateTimes		=	[self dateFormatters:event];
		NSDate		*	dateTime		=	[dateTimes objectForKey:@"DateTime"];
		NSString	*	title			=	[event objectForKey:@"Title"];
		NSString	*	eventID			=	[event objectForKey:@"EventId"];
		
		if ([self futureTest:dateTime] &&
			title != nil)
		{
			Event	*	processedEvent	=	[[Event alloc] init];
			if (event != nil)
			{
				[processedEvent setKeep:[NSNumber numberWithBool:YES]];
				[processedEvent setTitle:title];
				[processedEvent setEventID:eventID];
				[processedEvent setDateTime:dateTime];
				
				NSString	*	details		=	[event objectForKey:@"Details"];
				if (!details || [details isEqualToString:@"NULL"]) details	=	@"";
				[processedEvent setDetails:details];
				
				NSString	*	day			=	[dateTimes objectForKey:@"Day"];
				if (!day)		day			=	@"";
				[processedEvent setDay:day];
				
				NSString	*	date		=	[dateTimes objectForKey:@"Date"];
				if (!date)		date		=	@"";
				[processedEvent setDate:date];
				
				NSString	*	time		=	[dateTimes objectForKey:@"Time"];
				if (!time)		time		=	@"";
				[processedEvent setTime:time];
				
				NSNumber	*	showType	=	[self detectShowType:event];
				if (!showType)	showType	=	[NSNumber numberWithBool:YES];
				[processedEvent setShowType:showType];
				
				[processedEvents addObject:processedEvent];
				[processedEvent release];
			}
		}
	}
	//	
	//	Sort by DateTime
	//	
	[processedEvents sortUsingSelector:@selector(compareUsingDateTime:)];
#if 1
	NSLog(@"Store Events to cache");
#endif
	EGOCache	*	cache		=	[EGOCache currentCache];
	[cache setObject:processedEvents 
			  forKey:@"events.archive" 
// withTimeoutInterval:30];
 withTimeoutInterval:3600];
	dispatch_async(dispatch_get_main_queue(), ^{
		// Notify that events are available
		[self.delegate notifyEvents:[[processedEvents copy] autorelease]];
		// Update UI with next live show
		[self.delegate nextLiveShowTime];
	});
	[processedEvents release];
	[pool drain]; pool = nil;
}
- (NSDictionary *)dateFormatters:(NSDictionary *)event
{
	NSDictionary	*	dateTimes = nil;
	NSString		*	eventTimeString	=	[event objectForKey:@"StartDate"];
	NSDate			*	eventDateTime	=	[self.formatter dateFromString:eventTimeString];
	NSString		*	eventDay		=	[self.dayFormatter stringFromDate:eventDateTime];
	NSString		*	eventDate		=	[self.dateFormatter stringFromDate:eventDateTime];
	NSString		*	eventTime		=	[self.timeFormatter stringFromDate:eventDateTime];
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

@end
