//
//  TwitterDetailViewController_iPhone.m
//	
//	Created by Doug Russell on 9/5/10.
//	Copyright 2010 Doug Russell. All rights reserved.
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

#import "TwitterDetailViewController_iPhone.h"
#import "TwitterUserTableViewController_iPhone.h"
#import "TwitterHashTagTableViewController_iPhone.h"
#import "ModalWebViewController_iPhone.h"
#import "Tweet.h"

@implementation TwitterDetailViewController_iPhone

/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad 
{
	[super viewDidLoad];
}
/******************************************************************************/
#pragma mark -
#pragma mark Rotation
#pragma mark -
/******************************************************************************/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (IBAction)userImageButtonPressed:(id)sender
{
	[self openTweet:[item From]];
}
- (void)openTweet:(NSString *)user
{
	TwitterUserTableViewController_iPhone	*	viewController	=	
	[[TwitterUserTableViewController_iPhone alloc] init];
	viewController.user	=	user;
	[self.navigationController pushViewController:viewController 
										 animated:YES];
	[viewController release];
}
- (void)openHashTag:(NSString *)hashTag
{
	TwitterHashTagTableViewController_iPhone	*	viewController	=	
	[[TwitterHashTagTableViewController_iPhone alloc] init];
	viewController.hashTag					=	hashTag;
	[(UINavigationController *)self.navigationController pushViewController:viewController 
																   animated:YES];
	[viewController release];
}
- (void)openRequest:(NSURLRequest *)request
{
	ModalWebViewController_iPhone	*	viewController	=	
	[[ModalWebViewController_iPhone alloc] init];
	viewController.request	=	request;
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}

@end
