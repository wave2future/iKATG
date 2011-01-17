//
//  OnAirViewController_iPhone.m
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

#define kPhoneNumber @"tel:+16465028682"

#import "OnAirViewController_iPhone.h"
#import "OnAirViewController+Feedback.h"

@interface OnAirViewController_iPhone ()
- (void)registerKeyboardNotifications;
- (void)unfoldFeedbackView;
- (void)foldupFeedbackView;
@end

@implementation OnAirViewController_iPhone
@synthesize callButton;

/******************************************************************************/
#pragma mark -
#pragma mark Setup Cleanup
#pragma mark -
/******************************************************************************/
- (void)dealloc
{
	[callButton release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	initialFeedbackViewFrame	=	CGRectNull;
	initialCommentViewFrame		=	CGRectNull;
	initialSubmitButtonFrame	=	CGRectNull;
	NSURL	*	url				=	[NSURL URLWithString:kPhoneNumber];
	if (![[UIApplication sharedApplication] canOpenURL:url])
	{
		callButton.hidden		=	YES;
		callButton.enabled		=	NO;
		CGRect playButtonRect	=	audioButton.frame;
		playButtonRect.origin.x	=	(ScreenDimensionsInPoints().size.width / 2) - (playButtonRect.size.width / 2);
		audioButton.frame		=	playButtonRect;
	}
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self registerKeyboardNotifications];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.callButton	=	nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}
/******************************************************************************/
#pragma mark -
#pragma mark Keyboard
#pragma mark -
/******************************************************************************/
- (void)registerKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(keyboardWillShow:) 
	 name:UIKeyboardWillShowNotification 
	 object:nil];
}
- (void)keyboardWillShow:(NSNotification *)note
{
	[self unfoldFeedbackView];
}
/******************************************************************************/
#pragma mark -
#pragma mark TextView
#pragma mark -
/******************************************************************************/
- (BOOL)textView:(UITextView *)textView 
shouldChangeTextInRange:(NSRange)range 
 replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"])
	{
		[textView resignFirstResponder];
		[self foldupFeedbackView];
		return NO;
	}
	return YES;
}
/******************************************************************************/
#pragma mark -
#pragma mark TextField
#pragma mark -
/******************************************************************************/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self foldupFeedbackView];
	return NO;
}
/******************************************************************************/
#pragma mark -
#pragma mark Feedback View
#pragma mark -
/******************************************************************************/
- (void)sendFeedback
{
	[super sendFeedback];
	[self foldupFeedbackView]; 
}
- (void)unfoldFeedbackView
{
	if ([[self.tabBarController selectedViewController] isEqual:self])
	{
		if (CGRectIsNull(initialFeedbackViewFrame))
		{
			initialFeedbackViewFrame	=	[self.feedbackView frame];
			initialCommentViewFrame		=	[self.commentView frame];
			initialSubmitButtonFrame	=	[self.submitButton frame];
		}
		if (CGRectEqualToRect(initialFeedbackViewFrame, [self.feedbackView frame]))
		{
			self.infoButton.hidden	=	YES;
			
			[UIView beginAnimations:NULL context:NULL];
			[UIView setAnimationDuration:0.3];
			
			CGRect frame			=	[self.feedbackView frame];
			frame.size.height		=	frame.size.height + 130.0;
			[self.feedbackView setFrame:frame];
			
			frame					=	[self.commentView frame];
			frame.origin.y			=	frame.origin.y + 40.0;
			frame.size.height		=	frame.size.height +	90.0;
			[self.commentView setFrame:frame];
			
			frame					=	[self.submitButton frame];
			frame.origin.y			=	frame.origin.y + 176.0;
			[self.submitButton setFrame:frame];
			[self.submitButton setAlpha:1.0];
			
			[UIView commitAnimations];
		}
	}
}
- (void)foldupFeedbackView
{
	self.infoButton.hidden	=	NO;
	[UIView beginAnimations:NULL context:NULL];
	[UIView setAnimationDuration:0.3];
	[self.feedbackView setFrame:initialFeedbackViewFrame];
	[self.commentView setFrame:initialCommentViewFrame];
	[self.submitButton setFrame:initialSubmitButtonFrame];
	[self.submitButton setAlpha:0.0];
	[UIView commitAnimations];
}
/******************************************************************************/
#pragma mark -
#pragma mark Buttons
#pragma mark -
/******************************************************************************/
- (IBAction)callButtonPressed:(id)sender 
{
	//
	// Using a webview so that OS returns to 
	// app immediately instead of phone app
	//
	/////////THIS IS ABANDONING A WEBVIEW EVERYTIME THE BUTTON IS PRESSED///////////
	NSURL		*	url		=	[NSURL URLWithString:kPhoneNumber];
	UIWebView	*	webview =	[[UIWebView alloc] initWithFrame:[callButton frame]];
	webview.alpha			=	0.0;
	[webview loadRequest:[NSURLRequest requestWithURL:url]];
	[self.view insertSubview:webview belowSubview:callButton];
	[webview release];
}

@end
