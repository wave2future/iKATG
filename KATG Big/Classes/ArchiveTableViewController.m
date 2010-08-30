//
//  ArchiveViewController.m
//  KATG Big
//
//  Created by Doug Russell on 7/10/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import "ArchiveTableViewController.h"
#import "Show.h"
#import "Guest.h"
#import "ArchiveTableViewCell.h"
#import "UIViewController+Nib.h"
#import "ArchiveDetailViewController.h"
#import "PlayerController.h"

@interface ArchiveTableViewController ()
- (void)decorateCell:(ArchiveTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ArchiveTableViewController
@synthesize fetchedResultsController	=	_fetchedResultsController;
@synthesize	showContext					=	_showContext;
@synthesize activityIndicator			=	_activityIndicator;

#pragma mark -
#pragma mark View lifecycle
#pragma mark -
- (void)viewDidLoad 
{
    [super viewDidLoad];
	//	
	//	Setup Model
	//	
	model	=	[DataModel sharedDataModel];
	[model addDelegate:self];
	//	
	//	Set up a local managed object context
	//	
	NSPersistentStoreCoordinator	*	psc			=	[model.managedObjectContext persistentStoreCoordinator];
	NSManagedObjectContext			*	showContext	=	[[NSManagedObjectContext alloc] init];
	if (showContext)
	{
		self.showContext							=	showContext;
		self.showContext.persistentStoreCoordinator	=	psc;
		[showContext release];
	}
	//	
	//	Setup Fetch Controller
	//	
	NSFetchRequest		*	request			=	[[NSFetchRequest alloc] init];
	NSEntityDescription	*	entity			=	[NSEntityDescription 
												 entityForName:@"Show" 
												 inManagedObjectContext:self.showContext];
	request.entity							=	entity;
	NSSortDescriptor	*	sortDescriptor	=	[[NSSortDescriptor alloc] 
												 initWithKey:@"ID" 
												 ascending:NO];
	NSArray				*	sortDescriptors	=	[[NSArray alloc] initWithObjects:sortDescriptor, nil];
	request.sortDescriptors					=	sortDescriptors;
	[sortDescriptors release];
	[sortDescriptor release];
	NSFetchedResultsController	*	fetchedResultsController	=	[[NSFetchedResultsController alloc] 
																	 initWithFetchRequest:request 
																	 managedObjectContext:self.showContext 
																	 sectionNameKeyPath:nil 
																	 cacheName:@"archives"];
	fetchedResultsController.delegate		=	self;
	self.fetchedResultsController			=	fetchedResultsController;
	[fetchedResultsController release];
	[request release];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(mergeChangesFromContextDidSaveNotification:) 
	 name:NSManagedObjectContextDidSaveNotification 
	 object:nil];
	
	UIActivityIndicatorView	*	activityIndicator	=	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	if (activityIndicator)
	{
		self.activityIndicator						=	activityIndicator;
		[activityIndicator release];
		[self.activityIndicator setHidesWhenStopped:YES];
		self.activityIndicator.center				=	self.view.center;
		[self.view addSubview:self.activityIndicator];
	}
	
	NSError	*	error;
	[self.fetchedResultsController performFetch:&error];
	//if (error)
	//	ESLog(@"Archive Fetch Failed: %@", error);
	//	
	//	Retrieve shows list from web api
	//	
	[model shows];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([PlayerController sharedPlayerController].player != nil)
	{
		UIBarButtonItem	*	button	=
		[[UIBarButtonItem alloc] 
		 initWithTitle:@"Player" 
		 style:UIBarButtonItemStyleBordered 
		 target:self 
		 action:@selector(presentPlayer)];
		self.navigationItem.rightBarButtonItem	=	button;
		[button release];
	}
	else
		self.navigationItem.rightBarButtonItem	=	nil;
}
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification
{
	if ([NSThread isMainThread])
	{
		[self.showContext mergeChangesFromContextDidSaveNotification:notification];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) 
							   withObject:notification
							waitUntilDone:NO];
	}
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
#pragma mark Memory management
#pragma mark -
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidUnload 
{
	[super viewDidUnload];
	[model removeDelegate:self];
	self.activityIndicator	=	nil;
}
- (void)dealloc 
{
	[_fetchedResultsController release];
	[_showContext release];
	[_activityIndicator release];
    [super dealloc];
}
#pragma mark -
#pragma mark Table View Data Source
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [[self.fetchedResultsController sections] count];
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [(id <NSFetchedResultsSectionInfo>)[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString	*	CellIdentifier	=	@"ArchiveTableViewCell";
    static NSString	*	CellNibName		=	@"ArchiveTableViewCelliPhone";
	// Load Nib
    ArchiveTableViewCell	*	cell	=	(ArchiveTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell	=	(ArchiveTableViewCell *)[ArchiveTableViewCell loadFromNibName:CellNibName owner:self];
	[self decorateCell:cell withIndexPath:indexPath];
	return cell;
}
- (void)decorateCell:(ArchiveTableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
	// Get Show Object
	Show			*	show	=	(Show *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	// Set Number
	cell.showNumberLabel.text	=	[[show Number] stringValue];
	// Set Title
	cell.showTitleLabel.text	=	[show Title];
	// Set Guests
	NSMutableString	*	guests	=	[NSMutableString string];
	int	i	=	0;
	for (Guest *guest in [show Guests])
	{
		i++;
		if (i == [[show Guests] count])
			[guests appendString:[guest Guest]];
		else
			[guests appendFormat:@"%@, ", [guest Guest]];
	}
	
	cell.showGuestsLabel.text	=	guests;
	// Set Show Type Icon (Audio or TV)
	if ([[show TV] boolValue])
		cell.showTypeImageView.image	=	[UIImage imageNamed:@"TVShow"];
	else 
		cell.showTypeImageView.image	=	[UIImage imageNamed:@"AudioShow"];
	// Set Notes Icon
	if ([[show HasNotes] boolValue])
		cell.showNotesImageView.image	=	[UIImage imageNamed:@"HasNotes"];
	else
		cell.showNotesImageView.image	=	nil;
	// Set Pictures Icon
	if ([[show PictureCount] intValue] > 0)
		cell.showPicsImageView.image	=	[UIImage imageNamed:@"HasPics"];
	else
		cell.showPicsImageView.image	=	nil;
}
#pragma mark -
#pragma mark Table View Delegate
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Show	*	show	=	nil;
	show				=	(Show *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	[model showDetails:[[show ID] stringValue]];
	ArchiveDetailViewController	*	viewController	=
	[[ArchiveDetailViewController alloc] initWithNibName:@"ArchiveDetailViewiPhone" 
												  bundle:nil];
	viewController.show	=	show;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}
#pragma mark -
#pragma mark Fetched Results Controller Delegates
#pragma mark -
- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	[self.tableView beginUpdates];
}
- (void)controller:(NSFetchedResultsController*)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo 
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type
{
	NSIndexSet	*	set	=	[NSIndexSet indexSetWithIndex:sectionIndex];
	switch(type) 
	{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationFade];
			break; 
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}
- (void)controller:(NSFetchedResultsController*)controller 
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath*)newIndexPath
{
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
			[self decorateCell:(ArchiveTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
			break;
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}
- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
	[[self tableView] endUpdates];
}
#pragma mark -
#pragma mark Player
#pragma mark -
- (void)presentPlayer
{
	PlayerController	*	viewController	=	[PlayerController sharedPlayerController];
	viewController.modalTransitionStyle		=	UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:viewController animated:YES];
}

@end
