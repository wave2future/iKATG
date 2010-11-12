//
//  ModalWebViewController.m
//
//  Created by Doug Russell on 5/6/10.
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

#import "ModalWebViewController.h"

static NSString * portrait = nil;
static NSString * landscape = nil;

@interface ModalWebViewController ()
- (void)setBannerSize:(UIInterfaceOrientation)orientation;
@end

@implementation ModalWebViewController
@synthesize request, webView, activityIndicator, navToolbar, adBanner, bannerIsVisible;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	//	
	//	
	//	
	[webView loadRequest:request];
	//	
	//	
	//	
	if(&ADBannerContentSizeIdentifierPortrait != nil)
		portrait = ADBannerContentSizeIdentifierPortrait;
	else
		portrait = ADBannerContentSizeIdentifier320x50;
	
	if(&ADBannerContentSizeIdentifierLandscape != nil)
		landscape = ADBannerContentSizeIdentifierLandscape;
	else
		landscape = ADBannerContentSizeIdentifier480x32;
	
	self.adBanner.requiredContentSizeIdentifiers	=	[NSSet setWithObjects: 
														 portrait, 
														 landscape, nil];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setBannerSize:[[UIDevice currentDevice] orientation]];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self setBannerSize:toInterfaceOrientation];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.webView			=	nil;
	self.activityIndicator	=	nil;
	self.navToolbar			=	nil;
	self.adBanner			=	nil;
}
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[request release];
	webView.delegate = nil;
	[webView release];
	[activityIndicator release];
	[navToolbar release];
	adBanner.delegate = nil;
	[adBanner release];
    [super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark WebViewDelegate
#pragma mark -
/******************************************************************************/
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[activityIndicator stopAnimating];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[activityIndicator startAnimating];
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
/******************************************************************************/
#pragma mark -
#pragma mark Buttons
#pragma mark -
/******************************************************************************/
- (IBAction)doneButtonPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}
- (IBAction)openButtonPressed:(id)sender
{
	UIActionSheet	*	actionSheet	=
	[[UIActionSheet alloc] initWithTitle:@"Current Webpage :" 
								delegate:self 
					   cancelButtonTitle:@"Cancel" 
				  destructiveButtonTitle:@"In Safari" 
					   otherButtonTitles:@"Copy To Pasteboard", nil];
	[actionSheet showFromToolbar:self.navToolbar];
	[actionSheet release];
}
/******************************************************************************/
#pragma mark -
#pragma mark ActionSheetDelegate
#pragma mark -
/******************************************************************************/
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		NSURL			*	URL			=	[[self.webView request] URL];
		if ([[UIApplication sharedApplication] canOpenURL:URL])
			[[UIApplication sharedApplication] openURL:URL];
		else {
			BasicAlert(@"URL Open Failed", 
					   @"System can not open URL", 
					   nil, 
					   @"Continue", 
					   nil);
		}

	}
	else if (buttonIndex == 1)
	{
		UIPasteboard	*	pasteboard	=	[UIPasteboard generalPasteboard];
		NSString		*	copyText	=	[[[self.webView request] URL] description];
		if (pasteboard && copyText)
			pasteboard.string = copyText;
	}
}
/******************************************************************************/
#pragma mark -
#pragma mark ADBannerViewDelegate
#pragma mark -
/******************************************************************************/
- (void)setBannerSize:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation))
		self.adBanner.currentContentSizeIdentifier	=	landscape;
    else
		self.adBanner.currentContentSizeIdentifier	=	portrait;
}
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	return YES;
}
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		CGFloat offset		=	banner.frame.size.height;
        banner.frame		=	CGRectOffset(banner.frame, 0, +offset);
        CGRect	rect		=	self.webView.frame;
		rect.size.height	-=	offset;
		rect.origin.y		+=	offset;
		self.webView.frame	=	rect;
		[UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		CGFloat offset		=	banner.frame.size.height;
        banner.frame = CGRectOffset(banner.frame, 0, -offset);
		CGRect	rect		=	self.webView.frame;
		rect.size.height	+=	offset;
		rect.origin.y		-=	offset;
		self.webView.frame	=	rect;
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

@end
