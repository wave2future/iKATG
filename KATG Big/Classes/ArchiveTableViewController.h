//
//  ArchiveViewController.h
//  KATG Big
//
//  Created by Doug Russell on 7/10/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"

@interface ArchiveTableViewController : UITableViewController 
<DataModelDelegate, NSFetchedResultsControllerDelegate>
{
	DataModel					*	model;
	NSFetchedResultsController	*	_fetchedResultsController;
	NSManagedObjectContext		*	_showContext;
	UIActivityIndicatorView		*	_activityIndicator;
}

@property (nonatomic, retain)	NSFetchedResultsController	*	fetchedResultsController;
@property (nonatomic, retain)	NSManagedObjectContext		*	showContext;
@property (nonatomic, retain)	UIActivityIndicatorView		*	activityIndicator;

@end
