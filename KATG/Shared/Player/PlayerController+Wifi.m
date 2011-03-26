//
//  PlayerController+Wifi.m
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

#import "PlayerController+Wifi.h"

@implementation PlayerController (Wifi)

/******************************************************************************/
#pragma mark -
#pragma mark Player Notifications
#pragma mark -
/******************************************************************************/
- (void)handlePlaybackStateNotification:(NSNotification *)note
{
	switch (self.player.loadState)
	{
		case MPMovieLoadStateUnknown:
			NSLog(@"Unknown");
			break;
		case MPMovieLoadStatePlayable:
			NSLog(@"Playable");
			break;
		case MPMovieLoadStatePlaythroughOK:
			NSLog(@"Playthrough");
			break;
		case MPMovieLoadStateStalled:
			NSLog(@"Stalled");
			break;
	}
	switch (self.player.playbackState)
	{
		case MPMoviePlaybackStateStopped:
			NSLog(@"MPMoviePlaybackStateStopped");
			break;
		case MPMoviePlaybackStatePlaying:
			NSLog(@"MPMoviePlaybackStatePlaying");
			break;
		case MPMoviePlaybackStatePaused:
			NSLog(@"MPMoviePlaybackStatePaused");
			break;
		case MPMoviePlaybackStateInterrupted:
			NSLog(@"MPMoviePlaybackStateInterrupted");
			break;
		case MPMoviePlaybackStateSeekingForward:
			NSLog(@"MPMoviePlaybackStateSeekingForward");
			break;
		case MPMoviePlaybackStateSeekingBackward:
			NSLog(@"MPMoviePlaybackStateSeekingBackward");
			break;
		default:
			break;
	}
	if (self.player.loadState == MPMovieLoadStatePlaythroughOK ||
		self.player.loadState == MPMovieLoadStatePlayable)
	{
		[self setPlayerFrame];
		[self.view addSubview:self.player.view];
		[self.activityIndicator stopAnimating];
	}
}
- (void)handleSizeNotification:(NSNotification *)note
{
	[self setPlayerFrame];
}
- (void)setPlayerFrame
{
	CGSize	boundsSize	=	[[UIScreen mainScreen] bounds].size;
	CGRect	playerFrame;
	if (CGSizeEqualToSize(self.player.naturalSize, CGSizeZero))
	{
		self.player.view.backgroundColor = [UIColor clearColor];
		if (UIInterfaceOrientationIsLandscape((self.interfaceOrientation)))
			playerFrame	=	CGRectMake(0, 10, boundsSize.height, 40);
		else
			playerFrame	=	CGRectMake(0, 10, boundsSize.width, 40);
	}
	else
	{
		self.player.controlStyle = MPMovieControlStyleEmbedded;
		playerFrame	=	self.view.bounds;
		UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, playerFrame.size.width, 44)];
		toolBar.barStyle = UIBarStyleBlackTranslucent;
		toolBar.items = [NSArray arrayWithObjects:
						 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(stop:)] autorelease], 
						 [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], nil];
		[self.player.view addSubview:toolBar];
		[toolBar release];
	}
	self.player.view.frame	=	playerFrame;
}
- (void)handleDidFinishNotification:(NSNotification *)note
{
	NSNumber	*	reason	=	[[note userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
	if (reason && ([reason intValue] == MPMovieFinishReasonPlaybackEnded))
	{
		[self reset];
		[self dismiss:nil];
	}
}

@end
