//
//  ArchiveTableViewController.m
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

#import "ArchiveTableViewController.h"
#import "ArchiveTableViewCell.h"
#import "ArchiveDetailViewController.h"
#import "Show.h"
#import "Guest.h"
#import "UIViewController+Nib.h"
#import "PlayerController.h"

@interface ArchiveTableViewController ()
- (NSFetchedResultsController *)newFetchedResultsControllerForPredicate:(NSPredicate *)predicate;
- (void)decorateCell:(ArchiveTableViewCell *)cell 
	   withIndexPath:(NSIndexPath *)indexPath;
- (void)setPredicateForSearchText:(NSString*)searchText 
							scope:(NSInteger)scope;
@end

@implementation ArchiveTableViewController

/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad 
{
    [super viewDidLoad];
	//	
	//	Retrieve shows list from web api
	//	
	[model shows];
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if ([PlayerController sharedPlayerController].player != nil ||
		[PlayerController sharedPlayerController].streamer != nil )
	{
		UIBarButtonItem	*	button	=
		[[UIBarButtonItem alloc] 
		 initWithTitle:@"Now Playing"
		 style:UIBarButtonItemStyleBordered 
		 target:self 
		 action:@selector(presentPlayer)];
		self.navigationItem.rightBarButtonItem	=	button;
		[button release];
	}
	else
		self.navigationItem.rightBarButtonItem	=	nil;
}
- (NSFetchedResultsController *)fetchedResultsController
{
	//	
	//	if controller exists return it
	//	
	if (_fetchedResultsController)
		return _fetchedResultsController;
	//	
	//	otherwise make it
	//	
	_fetchedResultsController	=	[self newFetchedResultsControllerForPredicate:nil];
	
	return _fetchedResultsController;
}
- (NSFetchedResultsController *)newFetchedResultsControllerForPredicate:(NSPredicate *)predicate
{
	NSFetchRequest		*	request			=	[[NSFetchRequest alloc] init];
	NSEntityDescription	*	entity			=	[NSEntityDescription 
												 entityForName:@"Show" 
												 inManagedObjectContext:self.context];
	request.entity							=	entity;
	NSSortDescriptor	*	sortDescriptor	=	[[NSSortDescriptor alloc] 
												 initWithKey:@"PDT" 
												 ascending:NO];
	NSArray				*	sortDescriptors	=	[[NSArray alloc] initWithObjects:sortDescriptor, nil];
	request.sortDescriptors					=	sortDescriptors;
	[sortDescriptors release];
	[sortDescriptor release];
    [request setFetchBatchSize:20];
	[request setPredicate:predicate];
	NSFetchedResultsController	*	aFetchedResultsController	=	
	[[NSFetchedResultsController alloc] 
	 initWithFetchRequest:request 
	 managedObjectContext:self.context 
	 sectionNameKeyPath:nil 
	 cacheName:@"archives"];
	aFetchedResultsController.delegate		=	self;
	[request release];
	
	return aFetchedResultsController;
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
}
/******************************************************************************/
#pragma mark -
#pragma mark Table View Data Source
#pragma mark -
/******************************************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString	*	CellIdentifier	=	@"ArchiveTableViewCell";
    static NSString	*	CellNibName		=	@"ArchiveTableViewCell";
	// Load Nib
    ArchiveTableViewCell	*	cell	=	(ArchiveTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
		cell	=	(ArchiveTableViewCell *)[ArchiveTableViewCell loadFromNibName:CellNibName owner:self];
	[self decorateCell:cell withIndexPath:indexPath];
	return cell;
}
- (void)decorateCell:(ArchiveTableViewCell *)cell 
	   withIndexPath:(NSIndexPath *)indexPath
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
#pragma mark Memory management
#pragma mark -
/******************************************************************************/
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark Search
#pragma mark -
/******************************************************************************/
- (void)searchDisplayController:(UISearchDisplayController *)controller 
  didLoadSearchResultsTableView:(UITableView *)tableView
{
	//	
	//	
	//	
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;	
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;	
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self setPredicateForSearchText:searchString scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	[self setPredicateForSearchText:[self.searchDisplayController.searchBar text] scope:searchOption];
    return YES;
}
- (void)setPredicateForSearchText:(NSString*)searchText 
							scope:(NSInteger)scope
{
	[NSFetchedResultsController deleteCacheWithName:@"archives"];
	NSPredicate	*	predicate	=	nil;
	switch (scope) {
		case 1: //title
			predicate	=	[NSPredicate predicateWithFormat:@"Title contains[cd] %@", searchText];
			break;
		case 2: //guests
			predicate	=	[NSPredicate predicateWithFormat:@"Guests.Guest contains[cd] %@", searchText];
			break;
		case 3://number
			predicate	=	[NSPredicate predicateWithFormat:@"Number == %@", searchText];
			break;
		case 0: //all
		default:
			predicate	=	[NSPredicate predicateWithFormat:@"Title contains[cd] %@ or Guests.Guest contains[cd] %@ or Number == %@", searchText, searchText, searchText];
			break;
	}
	self.fetchedResultsController = [self newFetchedResultsControllerForPredicate:predicate];
	NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
#ifdef DEVELOPMENTBUILD
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
#endif
    }
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
	[NSFetchedResultsController deleteCacheWithName:@"archives"];
	self.fetchedResultsController = nil;
	NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Handle error
#ifdef DEVELOPMENTBUILD
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
#endif
    }
}
/******************************************************************************/
#pragma mark -
#pragma mark Player
#pragma mark -
/******************************************************************************/
- (void)presentPlayer
{
	PlayerController	*	viewController	=	[PlayerController sharedPlayerController];
	viewController.modalTransitionStyle		=	UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:viewController animated:YES];
}

@end
