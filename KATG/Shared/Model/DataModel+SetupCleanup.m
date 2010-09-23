//
//  DataModel+SetupCleanup.m
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#define kReachabilityURL @"app.keithandthegirl.com"

#import "DataModel+SetupCleanup.h"

const void * MyRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
void MyReleaseNoOp(CFAllocatorRef allocator, const void * value) { }
NSMutableArray * CreateNonRetainingArray() 
{
	CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
	callbacks.retain = MyRetainNoOp;
	callbacks.release = MyReleaseNoOp;
	return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

@implementation DataModel (SetupCleanup)

/******************************************************************************/
#pragma mark -
#pragma mark Setup
#pragma mark -
/******************************************************************************/
- (id)init
{
	if ((self = [super init]))
	{
		//	
		//	Non retaining array
		//	to prevent delegates
		//	from ending up in retain
		//	loops
		//	
		delegates			=	CreateNonRetainingArray();
		//	
		//	Connection Status
		//	
		connected			=	NO;
		connectionType		=	NotReachable;
		//	
		//	/*UNREVISEDCOMMENT*/
		//	
		operationQueue		=	[[NetworkOperationQueue alloc] init];
		[operationQueue setMaxConcurrentOperationCount:10];
		//	
		//	/*UNREVISEDCOMMENT*/
		//	
		delayedOperations	=	[[NSMutableArray alloc] init];
		//	
		//	/*UNREVISEDCOMMENT*/
		//	
		coreDataQueue		=	[[NSOperationQueue alloc] init];
		[coreDataQueue setMaxConcurrentOperationCount:[[NSProcessInfo processInfo] activeProcessorCount] + 1];
		//	
		//	Applications Cache Directory
		//	
		cacheDirectoryPath	=	[AppDirectoryCachePath() retain];
		//	
		//	NSDateFormatters for events
		//	
		[self dateFormatters];
		//	
		//	NSNotifications for reachability, app termination, core data
		//	
		[self registerNotifications];
		// User Defaults
		userDefaults		=	[NSUserDefaults standardUserDefaults];
		//	
		//	/*UNREVISEDCOMMENT*/
		//	
		live				=	NO;
		//	
		//	/*UNREVISEDCOMMENT*/
		//	
		[self checkReachability];
	}
	return self;
}
- (void)dateFormatters
{
	//	
	//	Initial formatter for creating data object for event
	//	
	formatter	=	[[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"MM/dd/yyyy HH:mm"];
	NSTimeZone	*	timeZone	=	[NSTimeZone timeZoneWithName:@"America/New_York"];
	[formatter setTimeZone:timeZone];
	//	
	//	Create localized data string for Day of the Week
	//	
	dayFormatter	=	[[NSDateFormatter alloc] init];
	[dayFormatter setDateStyle: NSDateFormatterLongStyle];
	[dayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dayFormatter setDateFormat: @"EEE"];
	[dayFormatter setLocale:[NSLocale currentLocale]];
	//	
	//	Create localized data string for Month and Day of the Month
	//	
	dateFormatter	=	[[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle: NSDateFormatterLongStyle];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat: @"MM/dd"];
	[dateFormatter setLocale:[NSLocale currentLocale]];
	//	
	//	Create localized data string for Time of Day
	//	
	timeFormatter	=	[[NSDateFormatter alloc] init];
	[timeFormatter setDateStyle: NSDateFormatterLongStyle];
	[timeFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[timeFormatter setDateFormat: @"h:mm aa"];
	[timeFormatter setLocale:[NSLocale currentLocale]];
}
- (void)registerNotifications
{
	//	
	//	Respond to changes in reachability
	//	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(reachabilityChanged:) 
	 name:kReachabilityChangedNotification 
	 object:nil];
	//	
	//	When app is closed attempt to release object
	//	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(releaseSingleton) 
	 name:UIApplicationWillTerminateNotification 
	 object:nil];
	//	
	//	
	//	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(mergeChangesFromContextDidSaveNotification:) 
	 name:NSManagedObjectContextDidSaveNotification 
	 object:nil];
}
/******************************************************************************/
#pragma mark -
#pragma mark Cleanup
#pragma mark -
/******************************************************************************/
- (void)dealloc
{
	[self cleanup];
	[self cleanupDateFormatters];
	[self cleanupOperations];
	[super dealloc];
}
- (void)cleanup
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	CleanRelease(delegates);
	CleanRelease(cacheDirectoryPath);
	CleanRelease(managedObjectContext);
	CleanRelease(hostReach);
}
- (void)cleanupDateFormatters
{
	CleanRelease(formatter);
	CleanRelease(dayFormatter);
	CleanRelease(dateFormatter);
	CleanRelease(timeFormatter);
}
- (void)cleanupOperations
{
	[operationQueue cancelAllOperations];
	CleanRelease(operationQueue);
	CleanRelease(delayedOperations);
	[coreDataQueue cancelAllOperations];
	CleanRelease(coreDataQueue);
}
- (void)releaseSingleton
{
	[super release];
}
/******************************************************************************/
#pragma mark -
#pragma mark Reachability
#pragma mark -
/******************************************************************************/
- (void)checkReachability 
{
	//	
	//	Register for changes in reachability and start reachability object
	//	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(reachabilityChanged:) 
	 name:kReachabilityChangedNotification 
	 object:nil];
	hostReach = 
	[[Reachability reachabilityWithHostName:kReachabilityURL] retain];
	[hostReach startNotifier];
}
- (void)reachabilityChanged:(NSNotification* )note
{
	Reachability *curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateReachability:curReach];
}
- (void)updateReachability:(Reachability*)curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
		case NotReachable:
		{
			//NSLog(@"Model Disconnected");
			connected		=	NO;
			connectionType	=	NotReachable;
			break;
		}
		case ReachableViaWWAN:
		{
			//NSLog(@"Model Connected");
			connected		=	YES;
			connectionType	=	ReachableViaWWAN;
			break;
		}
		case ReachableViaWiFi:
		{
			//NSLog(@"Model Connected");
			connected		=	YES;
			connectionType	=	ReachableViaWiFi;
			break;
		}
	}
	if (connected)
	{
		[operationQueue addOperations:delayedOperations];
		[delayedOperations removeAllObjects];
	}
}

@end
