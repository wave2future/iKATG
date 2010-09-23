//
//  EventsTableViewControlleriPhone.m
//  KATG Big
//
//  Created by Doug Russell on 6/9/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import "EventsTableViewControlleriPhone.h"
#import "EventTableCellView.h"
#import "EventsDetailViewControlleriPhone.h"
#import <QuartzCore/QuartzCore.h>
#import "Event.h"
#import "UIViewController+Nib.h"

@interface EventsTableViewControlleriPhone ()
- (void)decorateCell:(EventTableCellView *)cell withIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EventsTableViewControlleriPhone
@synthesize adView;
@synthesize fetchedResultsController	=	_fetchedResultsController;
@synthesize	eventContext					=	_eventContext;

#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	model	=	[DataModel sharedDataModel];
	[model addDelegate:self];
	
	NSPersistentStoreCoordinator	*	psc				=	[model.managedObjectContext persistentStoreCoordinator];
	NSManagedObjectContext			*	eventContext	=	[[NSManagedObjectContext alloc] init];
	if (eventContext)
	{
		self.eventContext								=	eventContext;
		self.eventContext.persistentStoreCoordinator	=	psc;
		[eventContext release];
	}
	
	//	
	//	Setup Fetch Controller
	//	
	NSFetchRequest		*	request			=	[[NSFetchRequest alloc] init];
	NSEntityDescription	*	entity			=	[NSEntityDescription 
												 entityForName:@"Event" 
												 inManagedObjectContext:self.eventContext];
	request.entity							=	entity;
	NSSortDescriptor	*	sortDescriptor	=	[[NSSortDescriptor alloc] 
												 initWithKey:@"DateTime" 
												 ascending:YES];
	NSArray				*	sortDescriptors	=	[[NSArray alloc] initWithObjects:sortDescriptor, nil];
	request.sortDescriptors					=	sortDescriptors;
	[sortDescriptors release];
	[sortDescriptor release];
	NSFetchedResultsController	*	fetchedResultsController	=	[[NSFetchedResultsController alloc] 
																	 initWithFetchRequest:request 
																	 managedObjectContext:self.eventContext 
																	 sectionNameKeyPath:nil 
																	 cacheName:@"events"];
	fetchedResultsController.delegate		=	self;
	self.fetchedResultsController			=	fetchedResultsController;
	[fetchedResultsController release];
	[request release];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(mergeChangesFromContextDidSaveNotification:) 
	 name:NSManagedObjectContextDidSaveNotification 
	 object:nil];
	
	NSError	*	error;
	[self.fetchedResultsController performFetch:&error];
	//	
	//	Retrieve events list from web api
	//	
	[model events];
}
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification
{
	if ([NSThread isMainThread])
		[self.eventContext mergeChangesFromContextDidSaveNotification:notification];
	else
		[self performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) 
							   withObject:notification 
							waitUntilDone:NO];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)viewDidUnload 
{
    [model removeDelegate:self];
	self.adView		=	nil;
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
	[_fetchedResultsController release];
	[_eventContext release];
	[adView release];
    [super dealloc];
}
#pragma mark -
#pragma mark Table View
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [[self.fetchedResultsController sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [(id <NSFetchedResultsSectionInfo>)[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString	*	CellIdentifier	=	@"EventTableCell";
    static NSString	*	CellNibName		=	@"EventTableCellView";
	
    EventTableCellView *cell = (EventTableCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell	=	(EventTableCellView *)[EventTableCellView loadFromNibName:CellNibName owner:self];
	
	[self decorateCell:cell withIndexPath:indexPath];
	
    return cell;
}
- (void)decorateCell:(EventTableCellView *)cell withIndexPath:(NSIndexPath *)indexPath
{
	Event	*	event	=	(Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
    [[cell eventTitleLabel] setText:[event Title]];
	[[cell eventDayLabel] setText:[event Day]];
	[[cell eventDateLabel] setText:[event Date]];
	[[cell eventTimeLabel] setText:[event Time]];
	
	if ([[event ShowType] boolValue])
		[[cell eventTypeImageView] setImage:[UIImage imageNamed:@"LiveShowIconTrans"]];
	else
		[[cell eventTypeImageView] setImage:[UIImage imageNamed:@"EventIconTrans"]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Event	*	event	=	nil;
	event				=	(Event *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	EventsDetailViewControlleriPhone *viewController = 
	[[EventsDetailViewControlleriPhone alloc] initWithNibName:@"EventsDetailView" 
													   bundle:nil];
	[viewController setEvent:event];
	[self.navigationController pushViewController:viewController 
										 animated:YES];
	[viewController release];
}
- (void)reloadTableView
{
	if ([NSThread isMainThread])
		[self.tableView reloadData];
	else
		[self performSelectorOnMainThread:@selector(reloadTableView) 
							   withObject:nil 
							waitUntilDone:NO];
}
#pragma mark -
#pragma mark Fetched Results Controller Delegates
#pragma mark -
- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	[self.tableView beginUpdates];
}
#define kAnimType UITableViewRowAnimationFade
- (void)controller:(NSFetchedResultsController*)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo 
		   atIndex:(NSUInteger)sectionIndex 
	 forChangeType:(NSFetchedResultsChangeType)type
{
	NSIndexSet	*	set	=	[NSIndexSet indexSetWithIndex:sectionIndex];
	switch(type) 
	{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:set withRowAnimation:kAnimType];
			break; 
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:set withRowAnimation:kAnimType];
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
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:kAnimType];
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:kAnimType];
			break;
		case NSFetchedResultsChangeUpdate:
			[self decorateCell:(EventTableCellView *)[self.tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
			break;
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:kAnimType];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:kAnimType];
			break;
	}
}
- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
	[[self tableView] endUpdates];
}

@end

