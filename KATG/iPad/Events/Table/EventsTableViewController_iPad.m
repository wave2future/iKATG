//
//  EventsTableViewController_iPad.m
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

#import "EventsTableViewController_iPad.h"
#import "EventsDetailViewController_iPad.h"
#import "EventTableViewCell.h"
#import "MGSplitViewController.h"

@implementation EventsTableViewController_iPad
@synthesize mgsplitViewController, detailViewController;

/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad
{
	[super viewDidLoad];
	mgsplitViewController.showsMasterInPortrait	=	YES;
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self selectFirstRow];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{return YES;}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	NSArray	*	indexPaths	=	[self.tableView indexPathsForVisibleRows];
	[self.tableView reloadRowsAtIndexPaths:indexPaths 
						  withRowAnimation:UITableViewRowAnimationFade];
}
- (void)selectFirstRow
{
	if ([self.tableView numberOfSections] > 0 && 
		[self.tableView numberOfRowsInSection:0] > 0) 
	{
		NSIndexPath	*	indexPath	=	[NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView selectRowAtIndexPath:indexPath 
									animated:YES 
							  scrollPosition:UITableViewScrollPositionTop];
		[self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
	}
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.mgsplitViewController	=	nil;
	self.detailViewController	=	nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)dealloc
{
	[mgsplitViewController release];
	[detailViewController release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table View Data Source
#pragma mark -
/******************************************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	EventTableViewCell *cell = (EventTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryViewColor = [UIColor clearColor];
	cell.selectedAccessoryViewColor = [UIColor whiteColor];
	
    return cell;
}
/******************************************************************************/
#pragma mark -
#pragma mark Table View Delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Event	*	event	=	(Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	self.detailViewController.event	=	event;
	[self.detailViewController updateFields];
}

@end
