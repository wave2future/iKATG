//
//  DataModel+Notifications.h
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import "DataModel.h"

@interface DataModel (Notifications)

/******************************************************************************/
#pragma mark -
#pragma mark Error
#pragma mark -
/******************************************************************************/
- (void)notifyError:(NSError *)error display:(BOOL)display;
/******************************************************************************/
#pragma mark -
#pragma mark Live Show Status
#pragma mark -
/******************************************************************************/
- (void)notifyLiveShowStatus:(BOOL)onAir;
/******************************************************************************/
#pragma mark -
#pragma mark 
#pragma mark -
/******************************************************************************/
- (void)notifyNextLiveShowTime:(NSDictionary *)nextLiveShow;
/******************************************************************************/
#pragma mark -
#pragma mark Chat
#pragma mark -
/******************************************************************************/
- (void)notifyLogin;

@end
