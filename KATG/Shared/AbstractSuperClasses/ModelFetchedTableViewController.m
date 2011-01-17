//
//  ModelTableViewController.m
//	
//  Created by Doug Russell on 4/26/10.
//  Copyright Doug Russell 2010. All rights reserved.
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

#import "ModelFetchedTableViewController.h"

@interface ModelFetchedTableViewController ()
- (void)decorateCell:(UITableViewCell *)cell 
	   withIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ModelFetchedTableViewController
@dynamic fetchedResultsController, context;
@synthesize activityIndicator;

/******************************************************************************/
#pragma mark -
#pragma mark Setup Cleanup
#pragma mark -
/******************************************************************************/
- (id)init
{
	if ((self = [super initWithStyle:UITableViewStylePlain]))
	{
		
	}
	return self;
}
- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}
- (void)dealloc 
{
    [model removeDelegate:self]; model = nil;
	CleanRelease(_fetchedResultsController);
	CleanRelease(_context);
	CleanRelease(activityIndicator);
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
	//	Default Background Color
	//	
	self.tableView.backgroundColor = [DefaultValues defaultBackgroundColor];
	//	
	//	
	//	
	self.clearsSelectionOnViewWillAppear = YES;
	//	
	//	Instantiate Model and add self as delegate
	//	
	model	=	[DataModel sharedDataModel];
	[model addDelegate:self];
	//	
	//	
	//	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(mergeChangesFromContextDidSaveNotification:) 
	 name:NSManagedObjectContextDidSaveNotification 
	 object:nil];
	//	
	//	
	//	
	UIActivityIndicatorView	*	anActivityIndicator	=
	[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	if (anActivityIndicator)
	{
		self.activityIndicator					=	anActivityIndicator;
		UIBarButtonItem				*	button	=	[[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
		self.navigationItem.rightBarButtonItem	=	button;
		[button release];
		[anActivityIndicator release];
	}
	[self.activityIndicator startAnimating];
	//	
	//	
	//	
	BOOL	success	=	[self.fetchedResultsController performFetch:nil];
	if (success)
		[self.activityIndicator stopAnimating];
}
- (NSFetchedResultsController *)fetchedResultsController
{
	return nil;
}
- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
	[fetchedResultsController retain];
	CleanRelease(_fetchedResultsController);
	_fetchedResultsController	=	fetchedResultsController;
}
- (NSManagedObjectContext *)context
{
	if (_context)
		return _context;
	NSPersistentStoreCoordinator	*	psc		=	[model.managedObjectContext persistentStoreCoordinator];
	_context									=	[[NSManagedObjectContext alloc] init];
	_context.persistentStoreCoordinator	=	psc;
	return _context;
}
- (void)setContext:(NSManagedObjectContext *)context
{
	[context retain];
	CleanRelease(_context);
	_context	=	context;
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.fetchedResultsController	=	nil;
	self.context					=	nil;
	self.activityIndicator			=	nil;
}
/******************************************************************************/
#pragma mark -
#pragma mark Rotation
#pragma mark -
/******************************************************************************/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}
/******************************************************************************/
#pragma mark -
#pragma mark Core Data
#pragma mark -
/******************************************************************************/
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification
{
	if ([NSThread isMainThread])
		[self.context mergeChangesFromContextDidSaveNotification:notification];
	else
		[self performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) 
							   withObject:notification 
							waitUntilDone:NO];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table view data source
#pragma mark -
/******************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [[self.fetchedResultsController sections] count];
}
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
	return [(id <NSFetchedResultsSectionInfo>)[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return nil;
}
- (void)decorateCell:(UITableViewCell *)cell 
	   withIndexPath:(NSIndexPath *)indexPath
{
	
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
/******************************************************************************/
#pragma mark -
#pragma mark Table view delegate
#pragma mark -
/******************************************************************************/
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
}
/******************************************************************************/
#pragma mark -
#pragma mark Fetched Results Controller Delegates
#pragma mark -
/******************************************************************************/
- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
	[self.activityIndicator stopAnimating];
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
			[self decorateCell:[self.tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
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
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)error:(NSError *)error display:(BOOL)display
{
	
}

@end

