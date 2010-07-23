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

@implementation ArchiveTableViewController
@synthesize shows				=	_shows;
@synthesize filteredShows		=	_filteredShows;

#pragma mark -
#pragma mark View lifecycle
#pragma mark -
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
	
	model	=	[DataModel sharedDataModel];
	[model addDelegate:self];
	
	[model shows];
	
	NSMutableArray	*	filtered	=	[[NSMutableArray alloc] initWithCapacity:1200];
	if (filtered)
	{
		self.filteredShows	=	filtered;
		[filtered release];
	}
}
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
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
}
- (void)dealloc 
{
	[_shows release];
	[_filteredShows release];
    [super dealloc];
}
#pragma mark -
#pragma mark Table view data source
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		return self.filteredShows.count;
	}
	else
	{
		return self.shows.count;
	}
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString	*	CellIdentifier	=	@"ArchiveTableViewCell";
    static NSString	*	CellNibName		=	@"ArchiveTableViewCelliPhone";
	// Load Nib
    ArchiveTableViewCell	*	cell	=
	(ArchiveTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell	=	(ArchiveTableViewCell *)[ArchiveTableViewCell 
											 loadFromNibName:CellNibName
											 owner:self];
    }
	// Get Show Object
	Show	*	show	=	 nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		show	=	(Show *)[self.filteredShows objectAtIndex:indexPath.row];
	}
	else
	{
		show	=	(Show *)[self.shows objectAtIndex:indexPath.row];
	}
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
	
	return cell;
}
#pragma mark -
#pragma mark Table view delegate
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Show	*	show	=	nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		show			=	[self.filteredShows objectAtIndex:indexPath.row];
	}
	else
	{
		show			=	[self.shows objectAtIndex:indexPath.row];
	}
	[model showDetails:[[show ID] stringValue]];
	ArchiveDetailViewController	*	viewController	=
	[[ArchiveDetailViewController alloc] initWithNibName:@"ArchiveDetailViewiPhone" 
												  bundle:nil];
	viewController.show	=	show;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}
#pragma mark -
#pragma mark Data Model Delgates
#pragma mark -
- (void)shows:(NSArray *)shows
{
	self.shows	=	shows;
	[self.tableView reloadData];
}
#pragma mark -
#pragma mark searchResultsTableView
#pragma mark -
#define kAll 0
#define kTitle 1
#define kNumber 2
#define kGuests 3
- (void)filterContentForSearchText:(NSString*)searchText
{
	// Update the filtered array based on the search text and scope.
	[self.filteredShows removeAllObjects]; // First clear the filtered array.
	
	// Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	for (Show *show in self.shows)
	{
		NSInteger	buttonIndex	=	self.searchDisplayController.searchBar.selectedScopeButtonIndex;
		
		BOOL	one	=	NO;
		if (buttonIndex == kTitle || buttonIndex == kAll)
		{
			NSRange	result	=	[[show Title] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
			one				=	(result.location != NSNotFound && result.length != 0);
		}
			
		BOOL	two	=	NO;
		if (buttonIndex == kNumber || buttonIndex == kAll)
		{
			NSRange	result	=	[[[show Number] stringValue] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
			two				=	(result.location != NSNotFound && result.length != 0);
		}
		
		BOOL	thr	=	NO;
		if (buttonIndex == kGuests || buttonIndex == kAll)
		{
			for (Guest *guest in [show Guests])
			{
				NSRange	result	=	[[guest Guest] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)];
				BOOL	match	=	(result.location != NSNotFound && result.length != 0);
				if (match)
					thr			=	YES;
			}
		}
		
		BOOL tot =  (one || two || thr);
		
		if (tot)
			[self.filteredShows addObject:show];
	}
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
    [self filterContentForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
	self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
	self.searchDisplayController.searchResultsTableView.backgroundColor = self.tableView.backgroundColor;
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
