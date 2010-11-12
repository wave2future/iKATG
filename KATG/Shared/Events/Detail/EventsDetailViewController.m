//
//  EventsDetailViewController.m
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

#import "EventsDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Event.h"
#import "UIWebView+SetText.h"

@interface EventsDetailViewController ()
- (void)openRequest:(NSURLRequest *)request;
@end

@implementation EventsDetailViewController
@synthesize 	event;
@synthesize 	webContainerView, webView;
@synthesize 	titleLabel, dateTimeLabel;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.webContainerView.layer.cornerRadius	=	10;
	[self updateFields];
}
- (void)updateFields
{
	NSString	*	title		=	[event Title];
	CGSize			titleSize	=	[title sizeWithFont:titleLabel.font 
						   constrainedToSize:titleLabel.bounds.size 
							   lineBreakMode:UILineBreakModeWordWrap];
	if (titleSize.height > titleLabel.frame.size.height)
	{
		titleLabel.font	=	[UIFont fontWithName:[titleLabel.font fontName] size:14];
	}
	[titleLabel setText:title];
	
	NSString	*	dateTime	=
	[NSString stringWithFormat:@"%@ %@ %@", 
	 [event Day], 
	 [event Date], 
	 [event Time]];
	[dateTimeLabel setText:dateTime];
	
	NSString	*	details		=	event.Details;
	if (details && details.length != 0)
	{
		NSRegularExpression	*	styleRegex	=	
		[NSRegularExpression regularExpressionWithPattern:@"style=\"[^\"]*\"" 
												  options:0 
													error:nil];
		details	=
		[styleRegex stringByReplacingMatchesInString:details 
											 options:0 
											   range:NSMakeRange(0, details.length) 
										withTemplate:@""];
		details	= [details stringByReplacingOccurrencesOfString:@"http://www.keithandthegirl.com/Live/HowToListen.aspx" 
													 withString:@""];
		details	= [details stringByReplacingOccurrencesOfString:@"../Live/HowToListen.aspx" 
													 withString:@""];
		details	= [details stringByReplacingOccurrencesOfString:@"Here's how  to listen:"
													 withString:@""];
		details	= [details stringByReplacingOccurrencesOfString:@"Here's how to listen:"
													 withString:@""];
		[webView setText:details];
	}
	else
		[webView setText:@"No Event Details"];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.webContainerView	=	nil;
	self.webView			=	nil;
	self.titleLabel			=	nil;
	self.dateTimeLabel		=	nil;
}
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[webContainerView release];
	[webView release];
	[titleLabel release];
	[dateTimeLabel release];
    [super dealloc];
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
		[self openRequest:request];
		return NO;
	}
	return YES;
}
- (void)openRequest:(NSURLRequest *)request
{
	
}

@end
