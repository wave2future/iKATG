//
//  DataModel+Notification.m
//  KATG Big
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

#import "DataModel+Notification.h"
#import "DataModel+Processing.h"
#import "ModelLogging.h"

@implementation DataModel (Notification)

//
//  In order to avoid mutation during Enumeration
//  notify methods add dlgts to a retaining array
//  if they are able to respond and then enumerate
//  accross that array.
//  Notify methods are also pushed to the main
//  thread so that there's no need for view to 
//  check for thread safety as it uses data returned.
//

/******************************************************************************/
#pragma mark -
#pragma mark Events
#pragma mark -
/******************************************************************************/

/******************************************************************************/
#pragma mark -
#pragma mark Live Show Status
#pragma mark -
/******************************************************************************/
- (void)notifyLiveShowStatus:(NSString *)status
{
	if ([NSThread isMainThread])
	{
		BOOL onAir	=	[status boolValue];
#if LogLiveShowStatus
		NSLog(@"Live Show Status: %@", onAir ? @"YES": @"NO");
#endif
		if (notifier)
		{
			//[[NSNotificationCenter defaultCenter] 
			// postNotificationName: 
			// object:];
		}
		NSMutableArray *dlgts = [[NSMutableArray alloc] init];
		for (id delegate in delegates)
		{
			if ([(NSObject *)delegate respondsToSelector:@selector(liveShowStatus:)])
			{
				[dlgts addObject:delegate];
			}
		}
		for (id delegate in dlgts)
		{
			[delegate liveShowStatus:onAir];
		}
		[dlgts release];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(notifyLiveShowStatus:) 
							   withObject:status 
							waitUntilDone:NO];
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Show Archives
#pragma mark -
/******************************************************************************/

/******************************************************************************/
#pragma mark -
#pragma mark Show Details
#pragma mark -
/******************************************************************************/
- (void)notifyShowDetails:(NSString *)ID
{
	if ([NSThread isMainThread])
	{
		if (notifier)
		{
			//[[NSNotificationCenter defaultCenter] 
			// postNotificationName: 
			// object:];
		}
		NSMutableArray *dlgts = [[NSMutableArray alloc] init];
		for (id delegate in delegates)
		{
			if ([(NSObject *)delegate respondsToSelector:@selector(showDetailsAvailable:)])
			{
				[dlgts addObject:delegate];
			}
		}
		for (id delegate in dlgts)
		{
			[delegate showDetailsAvailable:ID];
		}
		[dlgts release];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(notifyShowDetails:) 
							   withObject:ID 
							waitUntilDone:NO];
	}
}

@end
