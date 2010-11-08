//
//  EventsTableViewController_iPhone.m
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

#import "EventsTableViewController_iPhone.h"
#import "EventsDetailViewController_iPhone.h"

@implementation EventsTableViewController_iPhone

/******************************************************************************/
#pragma mark -
#pragma mark Table View Delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	EventsDetailViewController_iPhone	*	viewController	=
	[[EventsDetailViewController_iPhone alloc] initWithNibName:@"EventsDetailView_iPhone" 
														bundle:nil];
	Event	*	event	=	[self.items objectAtIndex:indexPath.row];
	viewController.event	=	event;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

@end
