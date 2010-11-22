//	
//	TwitterDetailViewController.m
//	ESTwitterViewer
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

#import "TwitterDetailViewController.h"
#import "ModalWebViewController.h"
#import "ModalWebViewController_iPhone.h"
#import "TwitterUserTableViewController.h"
#import "UIWebView+SetText.h"
#import <QuartzCore/QuartzCore.h>
#import "Tweet.h"

@interface TwitterDetailViewController ()
- (void)updateFields;
- (void)openRequest:(NSURLRequest *)request;
@end

@implementation TwitterDetailViewController
@dynamic	item;
@synthesize	userImageButton;
@synthesize	fromLabel;
@synthesize	webView;
@synthesize timeSinceLabel;

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
	self.webView.opaque				=	NO;
	self.webView.backgroundColor	=	[UIColor clearColor];
	//	
	//	
	//	
	if (item)
		[self updateFields];
	//	
	//	
	//	
	self.userImageButton.layer.borderColor	=	[[UIColor blackColor] CGColor];
	self.userImageButton.layer.borderWidth	=	1.0;
	self.userImageButton.layer.shadowColor	=	[[UIColor blackColor] CGColor];
	self.userImageButton.layer.shadowOffset	=	CGSizeMake(2.0, 2.0);
	self.userImageButton.layer.shadowRadius	=	3.0;
	self.userImageButton.layer.shadowOpacity	=	0.5;
}
- (Tweet *)item
{
	return item;
}
- (void)setItem:(Tweet *)anItem
{
	[anItem retain];
	CleanRelease(item);
	item	=	anItem;
	if (item != nil)
		[self updateFields];
}
- (void)updateFields
{
	UIImage *userImage = [model twitterImageForURL:[item ImageURL]];
	[self.userImageButton setBackgroundImage:userImage forState:UIControlStateNormal];
	self.fromLabel.text		=	[item From];
	self.navigationItem.title	=	[item From];
	[self.webView setText:[item WebViewText]];
	NSInteger		timeSince	=	-[[item Date] timeIntervalSinceNow];
	NSString	*	interval	=	@"seconds";
	if (timeSince > 60)
	{
		interval				=	@"minutes";
		timeSince				/=	60;
		if (timeSince > 60) 
		{
			interval			=	@"hours";
			timeSince			/=	60;
			if (timeSince > 24)
			{
				interval		=	@"days";
				timeSince		/=	24;
				if (timeSince > 7)
				{
					interval	=	@"weeks";
					timeSince	/=	7;
				}
			}
		}
	}
	NSString	*	since		=	[NSString stringWithFormat:@"tweeted %d %@ ago", timeSince, interval];
	self.timeSinceLabel.text	=	since;
}
- (void)viewDidUnload 
{
	[super viewDidUnload];
	self.userImageButton	=	nil;
	self.fromLabel	=	nil;
	self.webView	=	nil;
	self.timeSinceLabel	=	nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Rotation
#pragma mark -
/******************************************************************************/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return YES;
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
	[item release];
	[userImageButton release];
	[fromLabel release];
	[webView release];
	[timeSinceLabel release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegate Methods
#pragma mark -
/******************************************************************************/
- (void)twitterImageAvailableForURL:(NSString *)url
{
	if ([url isEqualToString:[item ImageURL]])
	{
		UIImage *userImage = [model twitterImageForURL:[item ImageURL]];
		[self.userImageButton setBackgroundImage:userImage forState:UIControlStateNormal];
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (IBAction)userImageButtonPressed:(id)sender
{
	
}
/******************************************************************************/
#pragma mark -
#pragma mark Web View
#pragma mark -
/******************************************************************************/
- (BOOL)webView:(UIWebView *)webView 
shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		if ([[[request URL] scheme] isEqualToString:@"tweet"])
			[self openTweet:[[request URL] host]];
		else if ([[[request URL] scheme] isEqualToString:@"hashtag"])
			[self openHashTag:[[request URL] host]];
		else
			[self openRequest:request];
		return NO;
	}
	return YES;
}
- (void)openTweet:(NSString *)user
{
	
}
- (void)openHashTag:(NSString *)hashTag
{
	[model twitterHashTagFeed:hashTag];
}
- (void)openRequest:(NSURLRequest *)request
{
	ModalWebViewController	*	viewController	=	nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		viewController	=	
		[[ModalWebViewController alloc] initWithNibName:@"ModalWebView_iPad" 
												 bundle:nil];
		viewController.request	=	request;
		
		// Present Modal with no settings for a full screen browser
		// or add presentation and transition style to flipcard into the center of the screen
		[viewController setModalPresentationStyle:UIModalPresentationFormSheet];
		[viewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self presentModalViewController:viewController animated:YES];
	}
    else
	{
		viewController	=	
		[[ModalWebViewController_iPhone alloc] initWithNibName:@"ModalWebView_iPhone" 
														bundle:nil];
		viewController.request	=	request;
		[self presentModalViewController:viewController animated:YES];
	}
	[viewController release];
}

@end
