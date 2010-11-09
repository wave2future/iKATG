//	
//  ArchiveDetailViewController.m
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

#import "ArchiveDetailViewController.h"
#import "Show.h"
#import "Guest.h"
#import "RoundedView.h"
#import "PlayerController.h"
#import "TitleBarButton.h"
#import "ArrowButton.h"

@implementation ArchiveDetailViewController
@synthesize show;
@synthesize showTitleLabel, showNumberLabel, showGuestsLabel, showNotesTextView;
@synthesize	showNotesContainer;

/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad
{
	[super viewDidLoad];
	[self updateFields];
	[model showDetails:[NSString stringWithFormat:@"%@", show.ID]];
	//[model showPictures:[NSString stringWithFormat:@"%@", show.ID]];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([PlayerController sharedPlayerController].player != nil ||
		[PlayerController sharedPlayerController].streamer != nil )
	{
		TitleBarButton	*	button	=
		[[TitleBarButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
		[button setTitle:@"Now Playing" forState:UIControlStateNormal];
		[button addTarget:self 
				   action:@selector(presentPlayer) 
		 forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.titleView	=	button;
		[button release];
	}
	else
	{
		TitleBarButton	*	button	=
		[[TitleBarButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
		[button setTitle:@"Play Episode" forState:UIControlStateNormal];
		[button addTarget:self 
				   action:@selector(playButtonPressed:) 
		 forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.titleView	=	button;
		[button release];
	}
	
	ArrowButton	*	picButton	=
	[[ArrowButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
	[picButton setTitle:@"Pictures" forState:UIControlStateNormal];
	[picButton addTarget:self 
				  action:@selector(pushPicturesViewController:) 
		forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem	*	picBarButton	=
	[[UIBarButtonItem alloc] initWithCustomView:picButton];
	self.navigationItem.rightBarButtonItem	=	picBarButton;
	[picBarButton release];
	[picButton release];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.showTitleLabel		=	nil;
	self.showNumberLabel	=	nil;
	self.showGuestsLabel	=	nil;
	self.showNotesContainer	=	nil;
	self.showNotesTextView	=	nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Memory Management
#pragma mark -
/******************************************************************************/
- (void)dealloc
{
	[showTitleLabel release];
	[showNumberLabel release];
	[showGuestsLabel release];
	[showNotesContainer release];
	[showNotesTextView release];
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)showDetails:(NSString *)ID
{
	if ([ID isEqualToString:[NSString stringWithFormat:@"%@", show.ID]])
		[self updateFields];
}
- (void)updateFields
{
	self.showTitleLabel.text	=	[self.show Title];
	self.showNumberLabel.text	=	[NSString stringWithFormat:@"Show %@", [self.show Number]];
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
		self.showNotesTextView.text	=	[self.show Notes];
}
/******************************************************************************/
#pragma mark -
#pragma mark Player
#pragma mark -
/******************************************************************************/
- (IBAction)playButtonPressed:(id)sender
{
	if ([self.show URL])
		[self presentPlayer:[NSURL URLWithString:[self.show URL]]];
}
- (void)presentPlayer:(NSURL *)URL
{
	[self presentPlayer];
	[[PlayerController sharedPlayerController] preparePlayer:URL];
	[PlayerController sharedPlayerController].titleLabel.text	=	[self.show Title];
	//[[PlayerController sharedPlayerController].textView setText:[self.show Notes]];
}
- (void)presentPlayer
{
	PlayerController	*	viewController	=	[PlayerController sharedPlayerController];
	viewController.modalTransitionStyle		=	UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:viewController animated:YES];
}

@end
