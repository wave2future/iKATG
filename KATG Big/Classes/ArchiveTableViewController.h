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
<DataModelDelegate>
{
	DataModel		*	model;
	NSArray			*	_shows;
	NSMutableArray	*	_filteredShows;
}

@property (nonatomic, retain)	NSArray					*	shows;
@property (nonatomic, retain)	NSMutableArray			*	filteredShows;

@end
