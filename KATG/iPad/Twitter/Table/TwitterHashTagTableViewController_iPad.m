//
//  TwitterHashTagTableViewController_iPad.m
//	
//  Created by Doug Russell on 9/5/10.
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

#import "TwitterHashTagTableViewController_iPad.h"
#import "TwitterDetailViewController_iPad.h"
#import "MGSplitViewController.h"

@implementation TwitterHashTagTableViewController_iPad
@synthesize	mgsplitViewController, detailViewController;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self selectFirstRow];
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
- (void)dealloc
{
	[mgsplitViewController release];
	[detailViewController release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table View Delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	detailViewController.item	=	[self.items objectAtIndex:indexPath.row];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)twitterHashTagFeed:(NSArray *)tweets
{
	[super twitterHashTagFeed:tweets];
	[self selectFirstRow];
}

@end
