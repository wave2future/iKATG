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

#import "ModelTableViewController.h"

@implementation ModelTableViewController
@synthesize items;
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
	CleanRelease(items);
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
}
- (void)viewDidUnload 
{
    [super viewDidUnload];
	self.activityIndicator	=	nil;
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
#pragma mark Table view data source
#pragma mark -
/******************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
	return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return nil;
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
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)error:(NSError *)error display:(BOOL)display
{
	
}

@end
