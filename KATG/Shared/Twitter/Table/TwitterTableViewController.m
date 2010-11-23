//	
//	TwitterTableViewController.m
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

#import "TwitterTableViewController.h"
#import "DataModel.h"
#import "Tweet.h"

@implementation TwitterTableViewController

/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad 
{
	[super viewDidLoad];
	
	self.navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	UISegmentedControl *segCon = 
	[[UISegmentedControl alloc] initWithItems:
	 [NSArray arrayWithObjects:@"KATG", @"KATG Clan", nil]];
	[segCon setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segCon setSelectedSegmentIndex:0];
	[segCon addTarget:self 
			   action:@selector(toggleExtendedTweets:) 
	 forControlEvents:UIControlEventValueChanged];
	segCon.autoresizingMask	= (UIViewAutoresizingFlexibleRightMargin);
	self.navigationItem.titleView = segCon;
	[segCon release];
	
	extended	=	NO;
	[self startLoading];
}
- (void)toggleExtendedTweets:(id)sender
{
	extended	=	!extended;
	[self.items removeAllObjects];
	[self reloadTableView];
	[self startLoading];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)twitterSearchFeedAvailable:(NSArray *)tweets
{
	[self.items addObjectsFromArray:tweets];
	[self reloadTableView];
	[self stopLoading];
}
/******************************************************************************/
#pragma mark -
#pragma mark Refresh
#pragma mark -
/******************************************************************************/
- (void)refresh 
{
	[model twitterSearchFeed:extended];
}

@end
