//
//  OnAirViewController.m
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

#import "OnAirViewController.h"
#import "OnAirViewController+AudioStreamer.h"
#import "OnAirViewController+Feedback.h"
#import "GradButton.h"
#import "Rounded.h"
#import "AudioStreamer.h"
#import "Event.h"

@interface OnAirViewController ()
- (void)startLiveShowStatusTimer;
- (void)stopLiveShowStatusTimer;
- (void)startNextLiveShowTimer:(NSDate *)dateTime;
- (void)stopNextLiveShowTimer;
- (void)updateNextLiveShowLabel:(NSTimer *)timer;
- (void)registerNotifications;
@end

@implementation OnAirViewController
@synthesize feedbackView, nameField, locationField, commentView, submitButton, infoButton;
@synthesize audioButton;
@synthesize volumeView;
@synthesize nextLiveShowLabel, nextLiveShowActivityIndicator;
@synthesize live = _live;
@synthesize liveShowStatusLabel, liveShowStatusActivityIndicator;
@synthesize guestLabel, guestActivityIndicator;

/******************************************************************************/
#pragma mark -
#pragma mark Setup Cleanup
#pragma mark -
/******************************************************************************/
- (id)init
{
	if ((self = [super init]))
	{
		self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"On Air", @"")  
														 image:[UIImage imageNamed:@"OnAirTab"] 
														   tag:0] autorelease];
	}
	return self;
}
- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self stopLiveShowStatusTimer];
	[self stopNextLiveShowTimer];
	[feedbackView release];
	[nameField release];
	[locationField release];
	[commentView release];
	[submitButton release];
	[infoButton release];
	[audioButton release];
	[streamer release];
	[volumeView release];
	[nextLiveShowLabel release];
	[nextLiveShowActivityIndicator release];
	[liveShowStatusLabel release];
	[liveShowStatusActivityIndicator release];
	[guestLabel release];
	[guestActivityIndicator release];
    [super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	//	
	//	Start activity indicators for show info
	//	
	
	[self.nextLiveShowActivityIndicator startAnimating];
	[self.liveShowStatusActivityIndicator startAnimating];
	[self.guestActivityIndicator startAnimating];
	
	//	
	//	Setup audiostreamer and volume control
	//	
	
	[self setupAudioAssets];
	
	//	
	//	Poll for show info and set timers to keep things up to date
	//	
	
	[self startLiveShowStatusTimer];
	
	//	
	//	Register for notifications of application state
	//	
		
	[self registerNotifications];
	
	//	
	//	Resume playback and set name and location
	//	
	
	[self loadDefaults];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.feedbackView	=	nil;
	self.nameField		=	nil;
	self.locationField	=	nil;
	self.commentView	=	nil;
	self.submitButton	=	nil;
	self.infoButton		=	nil;
	self.audioButton	=	nil;
	self.volumeView		=	nil;
	self.nextLiveShowLabel	=	nil;
	self.nextLiveShowActivityIndicator	=	nil;
	self.liveShowStatusLabel	=	nil;
	self.liveShowStatusActivityIndicator	=	nil;
	self.guestLabel		=	nil;
	self.guestActivityIndicator	=	nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)error:(NSError *)error display:(BOOL)display
{
	if (error.code == kNextLiveShowCode ||
		error.code == kEventsListCode)
	{
		self.guestLabel.text		=	@"No Scheduled Guests";
		[self.guestActivityIndicator stopAnimating];
		self.nextLiveShowLabel.text	=	@"No Scheduled Show";
		[self.nextLiveShowActivityIndicator stopAnimating];
	}
}
- (void)liveShowStatus:(BOOL)live
{
	self.live					=	live;
	liveShowStatusLabel.text	=	[NSString stringWithFormat:@"%@", self.live ? @"Live" : @"Not Live"];
	[self.liveShowStatusActivityIndicator stopAnimating];
	[model nextLiveShowTime];
}
- (void)nextLiveShowTime:(NSDictionary *)nextLiveShow
{
	// Get Event
	Event	*	event		=	[nextLiveShow objectForKey:@"event"];
	// Cleanup any existing timer and start a new one to update countdown to live show
	[self startNextLiveShowTimer:event.DateTime];
	// Set guest label
	self.guestLabel.text	=	[nextLiveShow objectForKey:@"guest"];
	[self.guestActivityIndicator stopAnimating];
}
/******************************************************************************/
#pragma mark -
#pragma mark Timer Methods
#pragma mark -
/******************************************************************************/
- (void)startLiveShowStatusTimer
{
	[liveShowStatusTimer invalidate]; CleanRelease(liveShowStatusTimer);
	NSInvocation	*	pollLiveShowStatusInvocation	=	
	[NSInvocation invocationWithMethodSignature:[model methodSignatureForSelector:@selector(liveShowStatus)]];
	[pollLiveShowStatusInvocation setTarget:model];
	[pollLiveShowStatusInvocation setSelector:@selector(liveShowStatus)];
	liveShowStatusTimer	=	[[NSTimer scheduledTimerWithTimeInterval:180.0 
														invocation:pollLiveShowStatusInvocation 
														   repeats:YES] retain];
	[liveShowStatusTimer fire];
}
- (void)stopLiveShowStatusTimer
{
	[liveShowStatusTimer invalidate]; 
	CleanRelease(liveShowStatusTimer);
}
- (void)startNextLiveShowTimer:(NSDate *)dateTime
{
	// Cleanup any existing timer and start a new one to update countdown to live show
	[nextLiveShowTimer invalidate]; CleanRelease(nextLiveShowTimer);
	nextLiveShowTimer		=	[[NSTimer scheduledTimerWithTimeInterval:60.0 
														   target:self 
														 selector:@selector(updateNextLiveShowLabel:) 
														 userInfo:dateTime 
														  repeats:YES] retain];
	[nextLiveShowTimer fire];
}
- (void)stopNextLiveShowTimer
{
	[nextLiveShowTimer invalidate]; 
	CleanRelease(nextLiveShowTimer);
}
- (void)updateNextLiveShowLabel:(NSTimer *)timer
{
	//LogCmd(_cmd);
	NSDate		*	date		=	(NSDate *)[timer userInfo];
	NSString	*	timeString	=	nil;
	NSInteger		since		=	[date timeIntervalSinceNow];
	if (since < 0 && self.live)
		timeString = @"NOW!";
	else
	{
		NSInteger	d			=	since / 86400;
		NSInteger	h			=	since / 3600 - d * 24;
		NSInteger	m			=	since / 60 - d * 1440 - h * 60;
		timeString				=	[NSString stringWithFormat:@"%02d : %02d : %02d", d, h, m];
	}
	self.nextLiveShowLabel.text	=	timeString;
	[self.nextLiveShowActivityIndicator stopAnimating];
}
/******************************************************************************/
#pragma mark -
#pragma mark Buttons
#pragma mark -
/******************************************************************************/
- (IBAction)submitButtonPressed:(id)sender
{
	[self sendFeedback];
}
- (IBAction)audioButtonPressed:(id)sender
{
    [self _audioButtonPressed:sender];
}
- (IBAction)infoButtonPressed:(id)sender 
{
	BasicAlert(@"Keith and The Girl", 
			   @"This is for anyone into hearing and learning about the Keith and The Girl show on the go. Listen live, check upcoming live events, watch KATGtv video episodes, see show notes and pictures, and much more. Take a look around, and enjoy.", 
			   nil, 
			   @"OK", 
			   nil);
}
/******************************************************************************/
#pragma mark -
#pragma mark Notification
#pragma mark -
/******************************************************************************/
- (void)registerNotifications
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(handleBackgroundNotification:) 
	 name:UIApplicationDidEnterBackgroundNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(handleForegroundNotification:) 
	 name:UIApplicationWillEnterForegroundNotification 
	 object:nil];
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(handleActiveNotification:) 
	 name:UIApplicationDidBecomeActiveNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(handleInactiveNotification:) 
	 name:UIApplicationWillResignActiveNotification 
	 object:nil];
}
- (void)handleForegroundNotification:(NSNotification *)note
{
#ifdef DEVELOPMENTBUILD
	ESLog(@"Foreground");
#endif
	//	
	//	Clear the show info being displayed and
	//	start activity indicators until new info can
	//	replace it
	//	
	
	self.liveShowStatusLabel.text	=	@"";
	[self.liveShowStatusActivityIndicator startAnimating];
	
	self.nextLiveShowLabel.text		=	@"";
	[self.nextLiveShowActivityIndicator startAnimating];
	
	self.guestLabel.text			=	@"";
	[self.guestActivityIndicator startAnimating];
	
	//	
	//	Go get fresh data for next live show, live show status, and show guests
	//	
	
	[self startLiveShowStatusTimer];
	
	//	
	//	Resume playback, set name and location
	//	
	
	[self loadDefaults];
}
- (void)handleBackgroundNotification:(NSNotification *)note
{
#ifdef DEVELOPMENTBUILD
	ESLog(@"Background");
#endif
	
	//	
	//	Invalidate and release UI update timers
	//	
	
	[self stopLiveShowStatusTimer];
	[self stopNextLiveShowTimer];
	
	//	
	//	Store playback state, name and location
	//	
	
	[self writeDefaults];
}
- (void)handleActiveNotification:(NSNotification *)note
{
#ifdef DEVELOPMENTBUILD
	ESLog(@"Active");
#endif
}
- (void)handleInactiveNotification:(NSNotification *)note
{
#ifdef DEVELOPMENTBUILD
	ESLog(@"Inactive");
#endif
}

@end
