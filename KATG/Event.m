//
//  Event.m
//	
//	Created by Doug Russell on 9/5/10.
//	Copyright 2010 Doug Russell. All rights reserved.
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

#import "Event.h"

@implementation Event

@synthesize Time;
@synthesize Date;
@synthesize DateTime;
@synthesize ShowType;
@synthesize Details;
@synthesize EventID;
@synthesize Title;
@synthesize Keep;
@synthesize Day;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self != nil)
	{
		self.Time		=	[aDecoder decodeObject];
		self.Date		=	[aDecoder decodeObject];
		self.DateTime	=	[aDecoder decodeObject];
		self.ShowType	=	[aDecoder decodeObject];
		self.Details	=	[aDecoder decodeObject];
		self.EventID	=	[aDecoder decodeObject];
		self.Title		=	[aDecoder decodeObject];
		self.Keep		=	[aDecoder decodeObject];
		self.Day		=	[aDecoder decodeObject];
	}
	return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:Time];
	[aCoder encodeObject:Date];
	[aCoder encodeObject:DateTime];
	[aCoder encodeObject:ShowType];
	[aCoder encodeObject:Details];
	[aCoder encodeObject:EventID];
	[aCoder encodeObject:Title];
	[aCoder encodeObject:Keep];
	[aCoder encodeObject:Day];
}
- (NSComparisonResult)compareUsingDateTime:(Event *)evnt
{
	return [self.DateTime compare:evnt.DateTime];
}
- (void)dealloc
{
	[Time release];
	[Date release];
	[DateTime release];
	[ShowType release];
	[Details release];
	[EventID release];
	[Title release];
	[Keep release];
	[Day release];
	[super dealloc];
}

@end
