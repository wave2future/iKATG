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

@interface OnAirViewController_iPad ()
- (void)processFeedbackPosition;
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
	[self.chatView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.keithandthegirl.com/chat/iChatroom.aspx"]]];
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
	[self.chatView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.keithandthegirl.com/chat/iChatroom.aspx"]]];
}
- (void)handleInactiveNotification:(NSNotification *)note
{
	//[super performSelector:@selector(handleInactiveNotification:) withObject:note];
	[self.chatView loadHTMLString:@"" baseURL:nil];
}
/******************************************************************************/
#pragma mark -
#pragma mark WebViewDelegate
#pragma mark -
/******************************************************************************/
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self.chatView loadHTMLString:@"Error" baseURL:nil];
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
#if 0
	NSLog(@"\nRequest: %@\nHeaders: %@\nBody: %@", 
		  request, 
		  [request allHTTPHeaderFields], 
		  [[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] autorelease]);	
#endif
	return YES;
}

@end
