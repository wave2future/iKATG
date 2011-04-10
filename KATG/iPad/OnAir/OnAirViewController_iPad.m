//
//  OnAirViewController_iPad.m
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

#import "OnAirViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "GradButton.h"
#import "ModalWebViewController_iPad.h"

@interface OnAirViewController_iPad ()
- (void)processFeedbackPosition;
- (void)loadChat;
- (void)loadError;
- (void)openRequest:(NSURLRequest *)request;
@end

@implementation OnAirViewController_iPad
@synthesize playerView, chatView, activityIndicator;

/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad
{
	[super viewDidLoad];
	feedbackResizingMask	=	self.feedbackView.autoresizingMask;
	[self loadChat];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.submitButton setNeedsDisplay];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.playerView	=	nil;
	self.chatView	=	nil;
	self.activityIndicator	=	nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{return YES;}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
										 duration:(NSTimeInterval)duration
{
	if ([self.tabBarController.selectedViewController isEqual:self])
		[self.submitButton setNeedsDisplay];
}
/******************************************************************************/
#pragma mark -
#pragma mark Memory Management
#pragma mark -
/******************************************************************************/
- (void)dealloc
{
	[playerView release];
	[chatView release];
	[activityIndicator release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Feedback
#pragma mark -
/******************************************************************************/
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[super textViewDidBeginEditing:textView];
	[self processFeedbackPosition];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	[super textViewDidEndEditing:textView];
	//	
	//	This is a kludge to handle the keyboard visiblity
	//	
	[self performSelector:@selector(processFeedbackPosition) 
			   withObject:nil 
			   afterDelay:0.1];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self processFeedbackPosition];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	//	
	//	This is a kludge to handle the keyboard visiblity
	//	
	[self performSelector:@selector(processFeedbackPosition) 
			   withObject:nil 
			   afterDelay:0.1];
}
- (void)processFeedbackPosition
{
	CGRect	feedbackFrame	=	self.feedbackView.frame;
	if ([self.nameField isFirstResponder] ||
		[self.locationField isFirstResponder] ||
		[self.commentView isFirstResponder])
	{
		self.feedbackView.autoresizingMask	=	UIViewAutoresizingFlexibleWidth;
		CGRect	frame	=	self.feedbackView.frame;
		frame.origin.x	=	self.view.frame.size.width / 2 - frame.size.width / 2;
		frame.origin.y	=	0;
		if(!CGRectEqualToRect(feedbackFrame, frame))
		{
			[UIView beginAnimations:NULL context:NULL];
			[UIView setAnimationDuration:0.5];
			self.feedbackView.frame	=	frame;
			[UIView commitAnimations];
		}
	}
	else
	{
		self.feedbackView.autoresizingMask	=	feedbackResizingMask;
		CGRect	frame	=	self.feedbackView.frame;
		frame.origin.x	=	self.view.frame.size.width - frame.size.width;
		frame.origin.y	=	self.view.frame.size.height - frame.size.height;
		if(!CGRectEqualToRect(feedbackFrame, frame))
		{
			[UIView beginAnimations:NULL context:NULL];
			[UIView setAnimationDuration:0.8];
			self.feedbackView.frame	=	frame;
			[UIView commitAnimations];
		}
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark Notifications
#pragma mark -
/******************************************************************************/
- (void)handleActiveNotification:(NSNotification *)note
{
	//[super performSelector:@selector(handleActiveNotification:) withObject:note];
	[self loadChat];
}
- (void)handleInactiveNotification:(NSNotification *)note
{
	//[super performSelector:@selector(handleInactiveNotification:) withObject:note];
	[self.chatView loadHTMLString:@"" baseURL:nil];
}
- (void)loadChat
{
	[self.chatView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.keithandthegirl.com/chat/iChatroom.aspx"]]];
}
- (void)loadError
{
	[self.chatView loadHTMLString:@"<html><head></head><body><p>Error<br /><a href=\"http://www.keithandthegirl.com/chat/iChat.aspx\">Try Again?</a></body></html>" baseURL:nil];
}
/******************************************************************************/
#pragma mark -
#pragma mark WebViewDelegate
#pragma mark -
/******************************************************************************/
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self loadError];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self.activityIndicator stopAnimating];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self.activityIndicator startAnimating];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
#if 1
	NSLog(@"\nRequest: %@\nHeaders: %@\nBody: %@\nType: %d", 
		  request, 
		  [request allHTTPHeaderFields], 
		  [[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] autorelease],
		  navigationType);	
#endif
	if ((navigationType == UIWebViewNavigationTypeFormSubmitted) && 
		[[request URL] isEqual:[NSURL URLWithString:@"http://www.keithandthegirl.com/chat/iChat-Login.aspx"]])
	{
		NSString *referer = [[request valueForHTTPHeaderField:@"Referer"] lowercaseString];
		if ([referer isEqualToString:@"http://www.keithandthegirl.com/chat/ichat-login.aspx"])
		{
			[[DataModel sharedDataModel] loginToChatWithRequest:request];
			return NO;
		}
	}
	else if ((navigationType == UIWebViewNavigationTypeLinkClicked) &&
			  [[request URL] isEqual:[NSURL URLWithString:@"http://www.keithandthegirl.com/chat/Chat-Login.aspx"]])
	{
		[self.chatView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.keithandthegirl.com/chat/iChat-Login.aspx"]]];
		return NO;
	}
	else if ((navigationType == UIWebViewNavigationTypeLinkClicked) &&
			 [[request URL] isEqual:[NSURL URLWithString:@"http://www.keithandthegirl.com/forums/register.php"]])
	{
		[self openRequest:request];
		return NO;
	}
	else if ((navigationType == UIWebViewNavigationTypeLinkClicked) &&
			 [[request URL] isEqual:[NSURL URLWithString:@"http://www.keithandthegirl.com/forums/login.php?do=lostpw"]])
	{
		[self openRequest:request];
		return NO;
	}
	return YES;
}
- (void)openRequest:(NSURLRequest *)request
{
	ModalWebViewController_iPad	*	viewController	=	
	[[ModalWebViewController_iPad alloc] init];
	viewController.request					=	request;
	viewController.modalPresentationStyle	=	UIModalPresentationFormSheet;
	viewController.modalTransitionStyle		=	UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegate
#pragma mark -
/******************************************************************************/
- (void)chatLoginSuccessful:(BOOL)chat
{
	if (chat)
		[self loadChat];
	else
		[self loadError];
}

@end
