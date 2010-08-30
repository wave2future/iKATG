//
//  PlayerController.m
//  KATG Big
//
//  Created by Doug Russell on 8/15/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import "PlayerController.h"
#import "SynthesizeSingleton.h"

@interface PlayerController ()
- (void)setup;
- (void)setPlayerFrame;
@end

@implementation PlayerController
@synthesize	player;
@synthesize activityIndicator;
@dynamic	playbackState;

SYNTHESIZE_SINGLETON_FOR_CLASS(PlayerController);

- (id)init
{
	if ((self = [super init]))
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
}
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
- (void)viewDidLoad
{
	[super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.player.view.superview == nil)
	{
		[self setPlayerFrame];
		[self.view addSubview:self.player.view];
	}
}
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	if (self.player)
		[self.player.view removeFromSuperview];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.activityIndicator	=	nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (![self.player isFullscreen])
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
	[super dealloc];
}
#pragma mark -
#pragma mark Buttons
#pragma mark -
- (IBAction)dismiss:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark Player Controls
#pragma mark -
- (void)preparePlayer:(NSURL *)URL
{
	if (self.player	!= nil)
	{
		[self.player.view removeFromSuperview];
		self.player	=	nil;
	}
	self.player	=	[[[MPMoviePlayerController alloc] initWithContentURL:URL] autorelease];
	self.player.shouldAutoplay	=	YES;
	[self.activityIndicator startAnimating];
	[self.player prepareToPlay];
}
- (void)reset
{
	[self.activityIndicator stopAnimating];
	[self.player.view removeFromSuperview];
	self.player	=	nil;
}
- (MPMoviePlaybackState)playbackState
{
	return self.player.playbackState;
}
#pragma mark -
#pragma mark Player Notifications
#pragma mark -
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
	switch (self.player.playbackState) {
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
		if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
			playerFrame	=	CGRectMake(0, 10, boundsSize.height, 40);
		else
			playerFrame	=	CGRectMake(0, 10, boundsSize.width, 40);
	}
	else
	{
		CGSize	naturalSize	=	self.player.naturalSize;
		if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
			playerFrame	=	CGRectMake(0, 0, boundsSize.height, boundsSize.width - 20);
		else
			playerFrame	=	CGRectMake(0, 0, 
									   MIN(naturalSize.width, boundsSize.width), 
									   MIN(naturalSize.height, boundsSize.height - 70));
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
