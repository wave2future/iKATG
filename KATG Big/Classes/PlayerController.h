//
//  PlayerController.h
//  KATG Big
//
//  Created by Doug Russell on 8/15/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerController : UIViewController 
{
	MPMoviePlayerController	*	player;
	UIActivityIndicatorView	*	activityIndicator;
	NSString				*	showNumber;
}

@property (nonatomic, retain)				MPMoviePlayerController	*	player;
@property (nonatomic, retain)	IBOutlet	UIActivityIndicatorView	*	activityIndicator;
@property (nonatomic, readonly)				MPMoviePlaybackState		playbackState;
@property (nonatomic, retain)				NSString				*	showNumber;

+ (PlayerController *)sharedPlayerController;
- (void)preparePlayer:(NSURL *)URL;
- (void)reset;
- (IBAction)dismiss:(id)sender;

@end
