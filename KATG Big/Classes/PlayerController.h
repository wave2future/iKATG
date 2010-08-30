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
}

@property (nonatomic, retain)				MPMoviePlayerController	*	player;
@property (nonatomic, retain)	IBOutlet	UIActivityIndicatorView	*	activityIndicator;
@property (nonatomic, readonly)				MPMoviePlaybackState		playbackState;

+ (PlayerController *)sharedPlayerController;
- (void)preparePlayer:(NSURL *)URL;
- (void)reset;
- (IBAction)dismiss:(id)sender;

@end
