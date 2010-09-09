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
#import "PlayerController.h"

@interface ArchiveDetailViewController ()
- (void)presentPlayer:(NSURL *)URL;
- (void)presentPlayer;
- (void)updateFields;
@end

@implementation ArchiveDetailViewController
@synthesize show;
@synthesize showTitleLabel, showNumberLabel, showGuestsLabel, showNotesTextView, playButton;
@synthesize	showNotesContainer;

#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
- (void)viewDidLoad 
{
    [super viewDidLoad];
		
	model	=	[DataModel sharedDataModel];
	
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
	
	if ([self.show URL])
		self.playButton.hidden		=	NO;
	
	CGRect	notesFrame;
	if ([self.show Notes])
	{
		self.showNotesTextView.text	=	[self.show Notes];
		CGSize	contentSize			=	self.showNotesTextView.contentSize;
		notesFrame					=	self.showNotesContainer.frame;
		notesFrame.size.height		=	contentSize.height + 30;
		self.showNotesContainer.frame	=	notesFrame;
	}
	
	notesFrame						=	self.showNotesContainer.frame;
	[(UIScrollView *)self.view setContentSize:CGSizeMake(320, notesFrame.origin.y + notesFrame.size.height + 30)];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([PlayerController sharedPlayerController].player != nil)
	{
		UIBarButtonItem	*	button	=
		[[UIBarButtonItem alloc] 
		 initWithTitle:[NSString stringWithFormat:@"Now Playing: Show %@", [PlayerController sharedPlayerController].showNumber] 
		 style:UIBarButtonItemStyleBordered 
		 target:self 
		 action:@selector(presentPlayer)];
		self.navigationItem.rightBarButtonItem	=	button;
		[button release];
	}
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[model addDelegate:self];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[model removeDelegate:self];
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.showTitleLabel		=	nil;
	self.showNumberLabel	=	nil;
	self.showGuestsLabel	=	nil;
	self.showNotesContainer	=	nil;
	self.showNotesTextView	=	nil;
	self.playButton			=	nil;
}
#pragma mark -
#pragma mark Memory Management
#pragma mark -
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[showTitleLabel release];
	[showNumberLabel release];
	[showGuestsLabel release];
	[showNotesContainer release];
	[showNotesTextView release];
	[playButton release];
    [super dealloc];
}
#pragma mark -
#pragma mark Buttons
#pragma mark -
- (IBAction)playButtonPressed:(id)sender
{
	if ([self.show URL])
	{
		[self presentPlayer:[NSURL URLWithString:[self.show URL]]];
		self.playButton.hidden	=	YES;
	}
}
- (void)presentPlayer:(NSURL *)URL
{
	[self presentPlayer];
	[[PlayerController sharedPlayerController] preparePlayer:URL];
	[[PlayerController sharedPlayerController] setShowNumber:[self.show Number]];
}
- (void)presentPlayer
{
	PlayerController	*	viewController	=	[PlayerController sharedPlayerController];
	viewController.modalTransitionStyle		=	UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:viewController animated:YES];
}
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
- (void)showDetailsAvailable:(NSString *)ID
{
	[self updateFields];
}

@end
