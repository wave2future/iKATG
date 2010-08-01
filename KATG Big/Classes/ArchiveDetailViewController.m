//
//  ArchiveDetailViewController.m
//  KATG Big
//
//  Created by Doug Russell on 7/21/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import "ArchiveDetailViewController.h"
#import "Show.h"
#import "Guest.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ArchiveDetailViewController ()
- (void)makePlayer;
@end


@implementation ArchiveDetailViewController
@synthesize show;
@synthesize showTitleLabel, showNumberLabel, showGuestsLabel, showNotesTextView, playButton, player;

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	model	=	[DataModel sharedDataModel];
	
	self.showTitleLabel.text	=	[self.show Title];
	self.showNumberLabel.text		=	[NSString stringWithFormat:@"Show %@", [self.show Number]];
	NSMutableString	*	guests	=	[NSMutableString string];
	int	i	=	0;
	for (Guest *guest in [self.show Guests])
	{
		i++;
		if (i == [[self.show Guests] count])
			[guests appendString:[guest Guest]];
		else
			[guests appendFormat:@"%@, ", [guest Guest]];
	}
	self.showGuestsLabel.text	=	guests;
	if ([self.show Notes])
	{
		self.showNotesTextView.text	=	[self.show Notes];
		self.showNotesTextView.font	=	[UIFont systemFontOfSize:15];
	}
	if ([self.show URL])
	{
		[self makePlayer];
	}
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[model addDelegate:self];
}
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[model removeDelegate:self];
}
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.showTitleLabel		=	nil;
	self.showNumberLabel	=	nil;
	self.showGuestsLabel	=	nil;
	self.showNotesTextView	=	nil;
	self.playButton			=	nil;
}
- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[showTitleLabel release];
	[showNumberLabel release];
	[showGuestsLabel release];
	[showNotesTextView release];
	[playButton release];
	[player release];
    [super dealloc];
}
#pragma mark -
#pragma mark Data
#pragma mark -
- (void)showDetailsAvailable:(NSString *)ID
{
	self.showNotesTextView.text	=	[self.show Notes];
	
	if (self.player == nil || [self.show URL])
	{
		[self makePlayer];
	}
}
#pragma mark -
#pragma mark Player
#pragma mark -
- (void)makePlayer
{
	self.player	=
	[[[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[self.show URL]]] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handlePlaybackStateNotification:) 
												 name:MPMoviePlayerLoadStateDidChangeNotification 
											   object:self.player];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(handleSizeNotification:) 
												 name:MPMovieNaturalSizeAvailableNotification 
											   object:self.player];
	[player prepareToPlay];
}
- (void)handlePlaybackStateNotification:(NSNotification *)note
{
	if (self.player.loadState == MPMovieLoadStatePlaythroughOK ||
		self.player.loadState == MPMovieLoadStatePlayable)
	{
		self.player.view.frame	=	CGRectMake(0, 
											   0, 
											   320,
											   30);
		[self.view addSubview:self.player.view];
	}
}
- (void)handleSizeNotification:(NSNotification *)note
{
	self.player.view.frame	=	CGRectMake(0, 
										   0, 
										   320, 
										   self.player.naturalSize.height);
}

@end
