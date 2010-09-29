//	
//	ModelTwitterTableViewController.m
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

#import "ModelTwitterTableViewController.h"
#import "TwitterTableViewCell.h"
#import "UIViewController+Nib.h"
#import "DataModel.h"
#import "Tweet.h"

@interface ModelTwitterTableViewController ()
- (void)decorateCell:(TwitterTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ModelTwitterTableViewController
@synthesize items;

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
	self.items	=	[NSMutableArray arrayWithCapacity:50];
	//	
	//	
	//	
	model	=	[DataModel sharedDataModel];
	[model addDelegate:self];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
}
/******************************************************************************/
#pragma mark -
#pragma mark Memory Management
#pragma mark -
/******************************************************************************/
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[model removeDelegate:self]; model	=	nil;
	[items release];
    [super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)error:(NSError *)error display:(BOOL)display
{
	if (error.code == kTwitterUserFeedCode)
	{
		if (display)
			BasicAlert(@"Twitter Error", error.domain, nil, @"OK", nil);
	}
}
- (void)imageAvailableForURL:(NSString *)url
{
	NSArray				*	indexPaths				=	nil;
	indexPaths										=	[self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *path in indexPaths)
	{
		NSInteger			row						=	path.row;
		if (row >= 0 && row < self.items.count)
		{
			NSString		*	rowURL				=	[[self.items objectAtIndex:row] ImageURL];
			if ([rowURL isEqualToString:url])
			{
				TwitterTableViewCell	*	cell	=	(TwitterTableViewCell *)[self.tableView cellForRowAtIndexPath:path];
				cell.userImageView.image			=	[model thumbForURL:url];
				// To fade in image:
				//[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
				// To just pop in image: (one or the other not both)
				[cell setNeedsLayout];
			}
		}
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Table view data source
#pragma mark -
/******************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
	return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString	*	CellIdentifier	=	@"TwitterTableViewCell";
    static NSString	*	CellNibName		=	@"TwitterTableViewCell";
	// Load Nib
    TwitterTableViewCell	*	cell	=	(TwitterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell	=	(TwitterTableViewCell *)[TwitterTableViewCell loadFromNibName:CellNibName owner:self];
	[self decorateCell:cell withIndexPath:indexPath];
	return cell;
}
- (void)decorateCell:(TwitterTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
	NSString	*	userName	=	[[self.items objectAtIndex:indexPath.row] From];
	if (userName)
		cell.userNameLabel.text		=	[NSString stringWithFormat:@"@%@", userName];
	cell.userImageView.image	=	[model thumbForURL:[[self.items objectAtIndex:indexPath.row] ImageURL]];
	cell.tweetTextLabel.text	=	[[self.items objectAtIndex:indexPath.row] Text];
	NSInteger		timeSince	=	-[[[self.items objectAtIndex:indexPath.row] Date] timeIntervalSinceNow];
	NSString	*	interval	=	@"s";
	if (timeSince > 60)
	{
		interval				=	@"s";
		timeSince				/=	60;
		if (timeSince > 60) 
		{
			interval			=	@"h";
			timeSince			/=	60;
			if (timeSince > 24)
			{
				interval		=	@"d";
				timeSince		/=	24;
				if (timeSince > 7)
				{
					interval	=	@"w";
					timeSince	/=	7;
				}
			}
		}
	}
	NSString	*	since		=	[NSString stringWithFormat:@"%d%@", timeSince, interval];
	cell.timeSinceLabel.text	=	since;
}
- (void)reloadTableView
{
	if ([NSThread isMainThread])
		[self.tableView reloadData];
	else
		[self performSelectorOnMainThread:@selector(reloadTableView) 
							   withObject:nil 
							waitUntilDone:NO];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table View Delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
}
/******************************************************************************/
#pragma mark -
#pragma mark Refresh
#pragma mark -
/******************************************************************************/
- (void)refresh 
{
	
}

@end
