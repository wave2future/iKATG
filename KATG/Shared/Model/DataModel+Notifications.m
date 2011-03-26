//
//  DataModel+Notifications.m
//	
//  Created by Doug Russell on 6/30/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//
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

#import "DataModel+Notifications.h"

@implementation DataModel (Notifications)

//	
//  In order to avoid mutation during FastEnumeration
//	a retaining array is created of the current delegates
//	and then enumeration occurs accross that array.
//	

/******************************************************************************/
#pragma mark -
#pragma mark Error
#pragma mark -
/******************************************************************************/
- (void)notifyError:(NSError *)error display:(BOOL)display
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(error:display:)])
			[delegate error:error display:display];
	}
	[dlgts release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Live Show Status
#pragma mark -
/******************************************************************************/
- (void)notifyLiveShowStatus:(BOOL)onAir
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(liveShowStatus:)])
			[delegate liveShowStatus:onAir];
	}
	[dlgts release];
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)notifyNextLiveShowTime:(NSDictionary *)nextLiveShow
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(nextLiveShowTime:)])
			[delegate nextLiveShowTime:nextLiveShow];
	}
	[dlgts release];
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)notifyEvents:(NSArray *)events
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		
		if ([delegate respondsToSelector:@selector(eventsAvailable:)])
			[delegate eventsAvailable:events];
	}
	[dlgts release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Shows
#pragma mark -
/******************************************************************************/
- (void)notifyShowDetails:(NSString *)ID
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(showDetails:)])
			[delegate showDetails:ID];
	}
	[dlgts release];
}
- (void)notifyShowPictures:(NSArray *)pictures
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(showPictures:)])
			[delegate showPictures:pictures];
	}
	[dlgts release];
}
- (void)notifyGetImageForURL:(NSString *)url
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(imageAvailableForURL:)])
			[delegate imageAvailableForURL:url];
	}
	[dlgts release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Twitter
#pragma mark -
/******************************************************************************/
- (void)notifyTwitterSearchFeed:(NSArray *)result
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(twitterSearchFeedAvailable:)])
			[delegate twitterSearchFeedAvailable:result];
	}
	[dlgts release];
}
- (void)notifyTwitterUserFeed:(NSArray *)result
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(twitterUserFeed:)])
			[delegate twitterUserFeed:result];
	}
	[dlgts release];
}
- (void)notifyTwitterHashTagFeed:(NSArray *)result
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(twitterHashTagFeed:)])
			[delegate twitterHashTagFeed:result];
	}
	[dlgts release];
}
- (void)notifyGetTwitterImageForURL:(NSString *)url
{
	NSMutableArray	*	dlgts	=	[[NSMutableArray alloc] initWithArray:delegates];
	for (id delegate in dlgts)
	{
		if ([delegate respondsToSelector:@selector(twitterImageAvailableForURL:)])
			[delegate twitterImageAvailableForURL:url];
	}
	[dlgts release];
}

@end
