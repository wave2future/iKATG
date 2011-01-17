//	
//  ArchivePictureViewController.m
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

#import "ArchivePictureViewController.h"
#import "ArchivePictureDetailViewController.h"
#import "Show.h"
#import "Picture.h"
#import "ImageGridTableViewCell.h"
#import "ImageGridButton.h"

@implementation ArchivePictureViewController
@synthesize show;
@synthesize images;

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
- (void)dealloc 
{
	[images release];
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
	
	self.navigationItem.title = NSLocalizedString(@"Pictures", @"");
	
	self.tableView.rowHeight = [ImageGridTableViewCell cellHeight];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	imagesAcross = floor((self.view.bounds.size.width / [ImageGridTableViewCell cellHeight]));
	
	NSSet	*	pictures	=	[show Pictures];
	self.images = [pictures allObjects];
	if (pictures.count == 0)
		[model showPictures:[self.show.ID stringValue]];
	else
		[self.activityIndicator stopAnimating];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	imagesAcross = floor((self.view.bounds.size.width / [ImageGridTableViewCell cellHeight]));
	[self.tableView reloadData];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
}
/******************************************************************************/
#pragma mark -
#pragma mark Model Delegate Methods
#pragma mark -
/******************************************************************************/
- (void)showPicturesAvailable:(NSString *)ID
{
	if ([NSThread isMainThread])
	{
		[self.activityIndicator stopAnimating];
		NSSet	*	pictures	=	[show Pictures];
		self.images = [pictures allObjects];
		[self reloadTableView];
	}
	else
		[self performSelectorOnMainThread:@selector(showPicturesAvailable:) 
							   withObject:ID 
							waitUntilDone:NO];
}
- (void)imageAvailableForURL:(NSString *)url
{
	if ([NSThread isMainThread])
	{
		for (int i = 0; i < self.images.count; i++)
		{
			Picture *pic = [self.images objectAtIndex:i];
			if ([pic.ThumbURL isEqual:url])
			{
				int row = floor(i / imagesAcross);
				[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:row 
																									inSection:0], nil] 
									  withRowAnimation:UITableViewRowAnimationNone];
			}
		}
	}
	else
		[self performSelectorOnMainThread:@selector(imageAvailableForURL:) 
							   withObject:url 
							waitUntilDone:NO];
}
#pragma mark -
#pragma mark Table view data source
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return ceil((double)images.count / (double)imagesAcross);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    ImageGridTableViewCell *cell = (ImageGridTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[ImageGridTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
	NSInteger location = indexPath.row * imagesAcross;
	NSInteger length = imagesAcross;
	if ((location + length) > images.count)
		length = images.count - location;
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(location, length)];
	NSArray *cellImages = [images objectsAtIndexes:indexes];
	[cell setImages:cellImages 
			 forRow:indexPath.row 
		 withTarget:self 
			 action:@selector(imageButtonPressed:)];
	
    return cell;
}
- (void)imageButtonPressed:(ImageGridButton *)sender
{
	ArchivePictureDetailViewController *viewController = [[ArchivePictureDetailViewController alloc] init];
	viewController.picture = [self.images objectAtIndex:sender.index];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

@end
