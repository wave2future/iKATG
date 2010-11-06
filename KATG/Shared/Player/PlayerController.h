//
//  PlayerController.h
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

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <iAd/iAd.h>
#import "Reachability.h"

@class AudioStreamer;
@interface PlayerController : UIViewController 
{
	NetworkStatus				connectionType;
	//	
	//	Player for 3G
	//	
	UIButton				*	audioButton;
	AudioStreamer			*	streamer;
	NSURL					*	streamURL;
	//	
	//	Player for Wifi
	//	
	MPMoviePlayerController	*	player;
	//	
	//	Activity Indicator for wifi player start
	//	
	UIActivityIndicatorView	*	activityIndicator;
	//	
	//	Episode Info
	//	
	UILabel			*	titleLabel;
	UIWebView		*	textView;
	//	
	//	
	//	
	UIButton		*	stopButton;
	//	
	//	Shameless Money Grab
	//	
	ADBannerView	*	adBanner;
}

@property (nonatomic, retain)	IBOutlet	UIButton		*	audioButton;
@property (nonatomic, readonly)				AudioStreamer	*	streamer;

@property (nonatomic, retain)				MPMoviePlayerController	*	player;
@property (nonatomic, retain)	IBOutlet	UIActivityIndicatorView	*	activityIndicator;
@property (nonatomic, readonly)				MPMoviePlaybackState		playbackState;

@property (nonatomic, retain)	IBOutlet	UILabel			*	titleLabel;
@property (nonatomic, retain)	IBOutlet	UIWebView		*	textView;

@property (nonatomic, retain)	IBOutlet	UIButton		*	stopButton;

@property (nonatomic, retain)	IBOutlet	ADBannerView	*	adBanner;

+ (PlayerController *)sharedPlayerController;
- (void)preparePlayer:(NSURL *)URL;
- (void)reset;
- (IBAction)dismiss:(id)sender;
- (IBAction)stop:(id)sender;

@end
