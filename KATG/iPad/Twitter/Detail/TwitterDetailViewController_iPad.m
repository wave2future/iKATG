//
//  TwitterDetailViewController_iPad.m
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

#import "TwitterDetailViewController_iPad.h"
#import "TwitterUserTableViewController_iPad.h"
#import "TwitterHashTagTableViewController_iPad.h"
#import "ModalWebViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "RoundedView.h"
#import "MGSplitViewController.h"

@implementation TwitterDetailViewController_iPad
@synthesize mgsplitViewController, topView, bottomView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	//	
	//	
	//	
	self.topView.layer.shadowColor		=	[[UIColor blackColor] CGColor];
	self.topView.layer.shadowOffset		=	CGSizeMake(2.0, 2.0);
	self.topView.layer.shadowRadius		=	3.0;
	self.topView.layer.shadowOpacity	=	0.5;
	//	
	//	
	//	
	self.bottomView.layer.shadowColor	=	[[UIColor blackColor] CGColor];
	self.bottomView.layer.shadowOffset	=	CGSizeMake(2.0, 2.0);
	self.bottomView.layer.shadowRadius	=	3.0;
	self.bottomView.layer.shadowOpacity	=	0.5;
}
- (void)dealloc
{
	CleanRelease(mgsplitViewController);
	CleanRelease(topView);
	CleanRelease(bottomView);
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)openTweet:(NSString *)user
{
	TwitterUserTableViewController_iPad	*	viewController	=	[[TwitterUserTableViewController_iPad alloc] init];
	viewController.user						=	user;
	viewController.mgsplitViewController	=	mgsplitViewController;
	viewController.detailViewController		=	self;
	[(UINavigationController *)self.mgsplitViewController.masterViewController pushViewController:viewController 
										 animated:YES];
	[viewController release];
}
- (void)openHashTag:(NSString *)hashTag
{
	TwitterHashTagTableViewController_iPad	*	viewController	=	
	[[TwitterHashTagTableViewController_iPad alloc] init];
	viewController.hashTag					=	hashTag;
	viewController.mgsplitViewController	=	mgsplitViewController;
	viewController.detailViewController		=	self;
	[(UINavigationController *)self.mgsplitViewController.masterViewController pushViewController:viewController 
																						 animated:YES];
	[viewController release];
}
- (void)openRequest:(NSURLRequest *)request
{
	ModalWebViewController_iPad	*	viewController	=	
	[[ModalWebViewController_iPad alloc] init];
	viewController.request					=	request;
	viewController.modalPresentationStyle	=	UIModalPresentationFormSheet;
	viewController.modalTransitionStyle		=	UIModalTransitionStyleFlipHorizontal;
	[self.mgsplitViewController presentModalViewController:viewController animated:YES];
	[viewController release];
}

@end
