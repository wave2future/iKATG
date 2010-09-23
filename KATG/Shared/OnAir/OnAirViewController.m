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
- (void)updateNextLiveShowLabel:(NSDate *)date;
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
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self.nextLiveShowActivityIndicator startAnimating];
	[self.liveShowStatusActivityIndicator startAnimating];
	[self.guestActivityIndicator startAnimating];
	
	[self setupAudioAssets];
	
	[model liveShowStatus];
	
	[model events];
	
	[model nextLiveShowTime];
		
	[self registerNotifications];
		
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
#pragma mark Memory Management
#pragma mark -
/******************************************************************************/
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc 
{
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
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)error:(NSError *)error display:(BOOL)display
{
	if (error.code == kNextLiveShowCode)
	{
		self.guestLabel.text		=	@"Unknown";
		[self.guestActivityIndicator stopAnimating];
		self.nextLiveShowLabel.text	=	@"Unknown";
		[self.nextLiveShowActivityIndicator stopAnimating];
	}
}
- (void)liveShowStatus:(BOOL)live
{
	self.live					=	live;
	liveShowStatusLabel.text	=	[NSString stringWithFormat:@"%@", self.live ? @"Live" : @"Not Live"];
	[self.liveShowStatusActivityIndicator stopAnimating];
}
- (void)nextLiveShowTime:(NSDictionary *)nextLiveShow
{
	Event	*	event		=	[nextLiveShow objectForKey:@"event"];
	[self updateNextLiveShowLabel:event.DateTime];
	self.guestLabel.text	=	[nextLiveShow objectForKey:@"guest"];
	[self.guestActivityIndicator stopAnimating];
}
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)updateNextLiveShowLabel:(NSDate *)date
{
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
#pragma mark UserDefaults
#pragma mark -
/******************************************************************************/
- (void)registerNotifications
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self
	 selector:@selector(handleBackgroundNotification) 
	 name:UIApplicationDidEnterBackgroundNotification 
	 object:nil];
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(handleForegroundNotification) 
	 name:UIApplicationWillEnterForegroundNotification 
	 object:nil];
}
- (void)handleForegroundNotification
{
	[model liveShowStatus];
	
//	liveShowTimer	=
//	[[NSTimer scheduledTimerWithTimeInterval:180.0 
//									  target:self 
//									selector:@selector(updateLiveShowStatusTimer:) 
//									userInfo:nil 
//									 repeats:YES] retain];
	
	[model events];
	
	[self loadDefaults];
}
- (void)handleBackgroundNotification
{
//	[liveShowTimer invalidate]; 
//	CleanRelease(liveShowTimer);
	[self writeDefaults];
}

@end
