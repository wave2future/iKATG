//
//  PlayerController.m
//	
//  Created by Doug Russell on 8/15/10.
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

#import "PlayerController.h"
#import "PlayerController+Wifi.h"
#import "PlayerController+Cellular.h"
#import "SynthesizeSingleton.h"
#import "ModalWebViewController_iPhone.h"
#import "DataModel.h"
#import "AudioStreamer.h"
#include <AudioToolbox/AudioToolbox.h>

@interface PlayerController ()
- (void)setup;
- (void)openRequest:(NSURLRequest *)request;
@end

@implementation PlayerController
@synthesize audioButton, streamer;
@synthesize	player;
@synthesize activityIndicator;
@dynamic	playbackState;
@synthesize titleLabel, textView, stopButton, adBanner;

SYNTHESIZE_SINGLETON_FOR_CLASS(PlayerController);

- (id)init
{
	[self initWithNibName:@"PlayerController" bundle:nil];
	return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
		[self setup];
	return self;
}
- (void)setup
{
	connectionType	=	[[DataModel sharedDataModel] connectionType];
	self.player	=	nil;
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(releaseSingleton) 
	 name:UIApplicationWillTerminateNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handlePlaybackStateNotification:) 
	 name:MPMoviePlayerLoadStateDidChangeNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleSizeNotification:) 
	 name:MPMovieNaturalSizeAvailableNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleDidFinishNotification:) 
	 name:MPMoviePlayerPlaybackDidFinishNotification 
	 object:nil];
	
	AudioSessionInitialize (NULL, // 'NULL' to use the default (main) run loop
							NULL, // 'NULL' to use the default run loop mode
							NULL, // callbacks
							NULL); // data to pass to your interruption listener callback
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory);
	AudioSessionSetActive(true);
}
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.textView.backgroundColor	=	[UIColor clearColor];
	self.textView.opaque			=	NO;
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.player != nil && self.player.view.superview == nil)
	{
		[self setPlayerFrame];
		[self.view addSubview:self.player.view];
	}
}
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if (self.player != nil)
		[self.player.view removeFromSuperview];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.audioButton		=	nil;
	self.activityIndicator	=	nil;
	self.titleLabel			=	nil;
	self.textView			=	nil;
	self.stopButton			=	nil;
	self.adBanner			=	nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
			toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (self.player != nil && ![self.player isFullscreen])
		[self setPlayerFrame];
}
#pragma mark -
#pragma mark Memory Management
#pragma mark -
- (void)releaseSingleton
{
	[super release];
}
- (void)dealloc
{
	[audioButton release];
	[self destroyStreamer];
	[streamURL release];
	
	[[NSNotificationCenter defaultCenter] 
	 removeObserver:self 
	 name:UIApplicationWillTerminateNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter] 
	 removeObserver:self 
	 name:MPMoviePlayerLoadStateDidChangeNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter] 
	 removeObserver:self 
	 name:MPMovieNaturalSizeAvailableNotification 
	 object:nil];
	[player release];
	
	[activityIndicator release];
	
	[titleLabel release];
	[textView release];
	
	[stopButton release];
	
	[adBanner release];
	
	[super dealloc];
}
#pragma mark -
#pragma mark Buttons
#pragma mark -
- (IBAction)dismiss:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}
- (IBAction)stop:(id)sender
{
	[self reset];
	[self dismissModalViewControllerAnimated:YES];
}
/******************************************************************************/
#pragma mark -
#pragma mark Player Controls
#pragma mark -
/******************************************************************************/
- (void)preparePlayer:(NSURL *)URL
{
	[self reset];
	connectionType	=	[[DataModel sharedDataModel] connectionType];
	switch (connectionType) {
		case NotReachable:
			
			break;
		case ReachableViaWWAN:
			streamURL	=	[URL retain];
			[self setupCellularAudioAssets];
			break;
		case ReachableViaWiFi:
			if (self.player	!= nil)
			{
				[self.player.view removeFromSuperview];
				self.player	=	nil;
			}
			self.player	=	[[[MPMoviePlayerController alloc] initWithContentURL:URL] autorelease];
			self.player.shouldAutoplay	=	YES;
			[self.activityIndicator startAnimating];
			[self.player prepareToPlay];
		default:
			break;
	}
}
- (void)reset
{
	//	
	//	Wifi Cleanup
	//	
	[self.activityIndicator stopAnimating];
	[self.player.view removeFromSuperview]; [self.player stop]; self.player	=	nil;
	//	
	//	3G Cleanup
	//	
	[self destroyStreamer];
	[streamURL release]; streamURL = nil;
	self.audioButton.hidden	=	YES;
	[self.audioButton setImage:nil forState:UIControlStateNormal];
	CGRect			frame	=	self.titleLabel.frame;
	frame.origin.x			=	10;
	frame.size.width		=	self.view.frame.size.width - 20;
	self.titleLabel.frame	=	frame;
}
- (MPMoviePlaybackState)playbackState
{
//	enum {
//		MPMovieLoadStateUnknown        = 0,
//		MPMovieLoadStatePlayable       = 1 << 0,
//		MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
//		MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
//	};
	// This is poor logic, should check for streamer or player, not connection type 
	// (connection type can change after instantiation)
	MPMoviePlaybackState	state	=	MPMovieLoadStateUnknown;
	switch (connectionType) {
		case NotReachable:
			
			break;
		case ReachableViaWWAN:
			if ([streamer isWaiting])
				state	=	MPMovieLoadStateStalled;
			else if ([streamer isPlaying])
				state	=	MPMovieLoadStatePlayable;
			else if ([streamer isIdle])
				state	=	MPMovieLoadStateUnknown;
			break;
		case ReachableViaWiFi:
			state	=	self.player.playbackState;
		default:
			break;
	}
	return state;
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
	ModalWebViewController_iPhone	*	viewController	=	
	[[ModalWebViewController_iPhone alloc] initWithNibName:@"ModalWebView_iPhone" 
													bundle:nil];
	viewController.request	=	request;
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}

@end
