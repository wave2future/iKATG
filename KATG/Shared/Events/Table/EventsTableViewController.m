//	
//	EventsTableViewController.m
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

#import "EventsTableViewController.h"
#import "UIViewController+Nib.h"
#import <QuartzCore/QuartzCore.h>
#import "Event.h"
#import "EventTableViewCell.h"

@interface EventsTableViewController ()
- (void)decorateCell:(UITableViewCell *)cell 
	   withIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EventsTableViewController
@synthesize adView;
/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad 
{
    [super viewDidLoad];
	//	
	//	
	//	
	NSArray	*	events	=	[model events];
	if (events)
	{
		self.items	=	events;
		[self.activityIndicator stopAnimating];
	}
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.adView	=	nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Table View Data Source
#pragma mark -
/******************************************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString	*	CellIdentifier	=	@"EventTableCell";
    static NSString	*	CellNibName		=	@"EventTableViewCell";
	
    EventTableViewCell *cell = (EventTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell	=	(EventTableViewCell *)[EventTableViewCell loadFromNibName:CellNibName owner:self];
	
	[self decorateCell:cell withIndexPath:indexPath];
	
    return cell;
}
- (void)decorateCell:(EventTableViewCell *)cell 
	   withIndexPath:(NSIndexPath *)indexPath
{
	Event	*	event	=	[self.items objectAtIndex:indexPath.row];
	
    [[cell eventTitleLabel] setText:[event Title]];
	[[cell eventDayLabel] setText:[event Day]];
	[[cell eventDateLabel] setText:[event Date]];
	[[cell eventTimeLabel] setText:[event Time]];
	
	if ([[event ShowType] boolValue])
		[[cell eventTypeImageView] setImage:[UIImage imageNamed:@"LiveShowIconTrans"]];
	else
		[[cell eventTypeImageView] setImage:[UIImage imageNamed:@"EventIconTrans"]];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table view delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)error:(NSError *)error display:(BOOL)display
{
	if (error.code == kEventsListCode)
	{
		if (display)
			BasicAlert(@"Events Error", error.domain, nil, @"OK", nil);
		
		[self.activityIndicator stopAnimating];
	}
}
- (void)eventsAvailable:(NSArray *)events
{
	self.items	=	events;
	[self reloadTableView];
	[self.activityIndicator stopAnimating];
}
/******************************************************************************/
#pragma mark -
#pragma mark Memory management
#pragma mark -
/******************************************************************************/
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[adView release];
	[super dealloc];
}

@end
