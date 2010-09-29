//
//  TwitterUserTableViewController_iPhone.m
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

#import "TwitterUserTableViewController_iPhone.h"
#import "Tweet.h"
#import "TwitterDetailViewController.h"

@implementation TwitterUserTableViewController_iPhone

/******************************************************************************/
#pragma mark -
#pragma mark Table Data Source
#pragma mark -
/******************************************************************************/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat			height		=	27.0;
	NSString	*	text		=	[[self.items objectAtIndex:indexPath.row] Text];
	CGSize			textSize	=	[text sizeWithFont:[UIFont boldSystemFontOfSize:18.0] constrainedToSize:CGSizeMake(225, 180)];
	height						+=	textSize.height + 6;
	return MAX(56.0, height);
}
/******************************************************************************/
#pragma mark -
#pragma mark Table View Delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	TwitterDetailViewController	*	viewController	=	[[TwitterDetailViewController alloc] initWithNibName:@"TwitterDetailView_iPhone" bundle:nil];
	viewController.item								=	[self.items objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

@end
