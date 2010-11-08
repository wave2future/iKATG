//
//  DataModel+SetupCleanup.m
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
		//	
		//	/*UNREVISEDCOMMENT*/
		//	
		pictureCacheDictionary	=	[[OrderedDictionary alloc] init];
	}
	return self;
}
- (void)dateFormatters
{
	twitterSearchFormatter	=	nil;
	twitterUserFormatter	=	nil;
}
- (NSDateFormatter *)twitterSearchFormatter
{
	if (twitterSearchFormatter)
		return twitterSearchFormatter;
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	twitterSearchFormatter	=	[[NSDateFormatter alloc] init];
	[twitterSearchFormatter setDateStyle: NSDateFormatterLongStyle];
	[twitterSearchFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	//@"Mon, 06 Sep 2010 07:36:57 +0000";
	[twitterSearchFormatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss ZZZ"];
	return twitterSearchFormatter;
}
- (NSDateFormatter *)twitterUserFormatter
{
	if (twitterUserFormatter)
		return twitterUserFormatter;
	//	
	//	/*UNREVISEDCOMMENTS*/
	//	
	twitterUserFormatter	=	[[NSDateFormatter alloc] init];
	[twitterUserFormatter setDateStyle: NSDateFormatterLongStyle];
	[twitterUserFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	//"created_at" = "Wed Sep 08 21:51:09 +0000 2010";
	[twitterUserFormatter setDateFormat: @"EEE MMM dd HH:mm:ss ZZZ yyyy"];
	return twitterUserFormatter;
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
	CleanRelease(twitterSearchRefreshURL);
	CleanRelease(twitterExtendedSearchRefreshURL);
	CleanRelease(twitterHashSearchRefreshURL);
	CleanRelease(pictureCacheDictionary);
}
- (void)cleanupDateFormatters
{
	CleanRelease(twitterSearchFormatter);
	CleanRelease(twitterUserFormatter);
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
