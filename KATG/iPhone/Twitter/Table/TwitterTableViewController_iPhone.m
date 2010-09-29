//
//  TwitterTableViewController_iPhone.m
//  KATG
//
//  Created by Doug Russell on 9/24/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import "TwitterTableViewController_iPhone.h"
#import "Tweet.h"
#import "TwitterDetailViewController_iPhone.h"

@implementation TwitterTableViewController_iPhone

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
	TwitterDetailViewController_iPhone	*	viewController	=	
	[[TwitterDetailViewController_iPhone alloc] initWithNibName:@"TwitterDetailView_iPhone" 
														 bundle:nil];
	viewController.item	=	[self.items objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

@end
