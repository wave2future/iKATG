//
//  DataModel+SetupCleanup.h
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import "DataModel.h"

NSMutableArray * CreateNonRetainingArray();

@interface DataModel (SetupCleanup)

- (void)dateFormatters;
- (void)registerNotifications;

- (void)cleanup;
- (void)cleanupDateFormatters;
- (void)cleanupOperations;

- (void)checkReachability;
- (void)updateReachability:(Reachability*)curReach;

@end
