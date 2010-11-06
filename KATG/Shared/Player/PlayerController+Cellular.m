//
//  PlayerController+Cellular.m
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

#import "PlayerController+Cellular.h"
#import "AudioStreamer.h"

@implementation PlayerController (Cellular)

- (void)setupCellularAudioAssets 
{
	//	
	//	
	//	
	self.audioButton.hidden	=	NO;
	CGRect			frame	=	self.titleLabel.frame;
	frame.origin.x			=	self.audioButton.frame.size.width + self.audioButton.frame.origin.x + 4;
	frame.size.width		=	self.view.frame.size.width - frame.origin.x;
	self.titleLabel.frame	=	frame;
	[self setAudioButtonImage:[UIImage imageNamed:@"Play"]];
}
- (void)setAudioButtonImage:(UIImage *)image 
{
	//	
	//	
	//	
	[self.audioButton.imageView stopAnimating];
	if (!image)
		[audioButton setImage:[UIImage imageNamed:@"Play"] forState:0];
	else
	{
		[audioButton setImage:image forState:0];
		if ([audioButton.currentImage isEqual:[UIImage imageNamed:@"LoadStage0"]])
			[self pulseButton];
	}
}	
- (void)pulseButton
{
	//	
	//	
	//	
	if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
	{
		if (self.audioButton.imageView.animationImages == nil)
		{
			NSArray	*	imageArray	=
			[[NSArray alloc] initWithObjects:
			 [UIImage imageNamed:@"LoadStage0"],
			 [UIImage imageNamed:@"LoadStage1"],
			 [UIImage imageNamed:@"LoadStage2"],
			 [UIImage imageNamed:@"LoadStage3"], nil];
			self.audioButton.imageView.animationImages		=	imageArray;
			self.audioButton.imageView.animationDuration	=	0.8;
			[imageArray release];		
		}
		[self.audioButton.imageView startAnimating];
	}
}
- (IBAction)audioButtonPressed:(id)sender
{
	//	
	//	buttonPressed:
	//	
	//	Handles the play/stop button. Creates, observes and starts the
	//	audio streamer when it is a play button. Stops the audio streamer when
	//	it isn't.
	//	
	//	Parameters:
	//		sender - normally, the play/stop button.
	//	
	if ([audioButton.currentImage isEqual:[UIImage imageNamed:@"Play"]])
	{
		[self setAudioButtonImage:[UIImage imageNamed:@"LoadStage0"]];
		[self createStreamer];
		[streamer start];
	}
	else
	{
		[streamer pause];
	}
}
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	//
	// playbackStateChanged:
	//
	// Invoked when the AudioStreamer
	// reports that its playback status has changed.
	//	
	if ([streamer isWaiting])
	{
		[self setAudioButtonImage:[UIImage imageNamed:@"LoadStage0"]];
	}
	else if ([streamer isPlaying])
	{
		[self setAudioButtonImage:[UIImage imageNamed:@"Pause"]];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setAudioButtonImage:[UIImage imageNamed:@"Play"]];
	}
	else if ([streamer isPaused])
	{
		[self setAudioButtonImage:[UIImage imageNamed:@"Play"]];
	}
}
- (void)createStreamer
{
	// 
	// createStreamer
	//
	// Creates or recreates the AudioStreamer object.
	//	
	if (streamer)
		return;
	
	[self destroyStreamer];
	
	streamer		=	[[AudioStreamer alloc] initWithURL:streamURL];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playbackStateChanged:)
	 name:ASStatusChangedNotification
	 object:streamer];
}
- (void)destroyStreamer
{
	//
	// destroyStreamer
	//
	// Removes the streamer, the UI update timer and the change notification
	//	
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
		 removeObserver:self
		 name:ASStatusChangedNotification
		 object:streamer];
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

@end
