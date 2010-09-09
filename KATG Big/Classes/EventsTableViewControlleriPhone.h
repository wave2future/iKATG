//
//  EventsTableViewControlleriPhone.h
//  KATG Big
//
//  Created by Doug Russell on 6/9/10.
//  Copyright 2010 Doug Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModel.h"
#import <iAd/iAd.h>

@interface EventsTableViewControlleriPhone : UITableViewController 
<DataModelDelegate, ADBannerViewDelegate, NSFetchedResultsControllerDelegate>
{
	DataModel					*	model;
	ADBannerView				*	adView;
	NSFetchedResultsController	*	_fetchedResultsController;
	NSManagedObjectContext		*	_eventContext;
}

@property (nonatomic, retain)	IBOutlet	ADBannerView	*	adView;
@property (nonatomic, retain)	NSFetchedResultsController	*	fetchedResultsController;
@property (nonatomic, retain)	NSManagedObjectContext		*	eventContext;

@end
