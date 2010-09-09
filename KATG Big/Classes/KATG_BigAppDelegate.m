//
//  KATG_BigAppDelegate.m
//
//  Created by Doug Russell on 4/26/10.
//  Copyright Doug Russell 2010. All rights reserved.
//  
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

#import "KATG_BigAppDelegate.h"
#import "DataModel.h"
#import "Reachability.h"
#import "Push.h"
#include <AudioToolbox/AudioToolbox.h>

@interface KATG_BigAppDelegate (PrivateCoreDataStack)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

#define kReachabilityURL @"www.keithandthegirl.com"

@implementation KATG_BigAppDelegate
@synthesize window, tabBarController, connected;

void uncaughtExceptionHandler(NSException *exception) 
{
	ESLog(@"Uncaught Exception: %@", exception);
}
#pragma mark -
#pragma mark Application Lifecycle
#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
#if DebugBuild
	NSLog(@"Test");
#endif
	
	NSManagedObjectContext	*	context	=	[self managedObjectContext];
	if (!context)
	{	// error
		
	}
	
	DataModel *model = [DataModel sharedDataModel];
	[model setManagedObjectContext:managedObjectContext];
	
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
	
	// APNS
	// Register for push notifications
	[[Push sharedPush] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | 
														   UIRemoteNotificationTypeBadge | 
														   UIRemoteNotificationTypeSound)];
	[[Push sharedPush] setDelegate:self];
	
	// If app is launched from a notification, display that notification in an alertview
	if ([launchOptions count] > 0) 
	{
		NSString	*	alertMessage	=
		[[[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] objectForKey:@"aps"] objectForKey:@"alert"];
		if (alertMessage)
			BasicAlert(@"Notification", alertMessage, nil, @"Continue", nil);
	}
	
	// Register reachability object
	[self checkReachability];
	
	AudioSessionInitialize (NULL,                          // 'NULL' to use the default (main) run loop
							NULL,                          // 'NULL' to use the default run loop mode
							NULL,  // a reference to your interruption callback
							NULL);                      // data to pass to your interruption listener callback
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory);
	AudioSessionSetActive(true);
    
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application 
{
	application.applicationIconBadgeNumber = 0;
}
- (void)applicationWillTerminate:(UIApplication *)application
{
	application.applicationIconBadgeNumber = 0;
	
	AudioSessionSetActive(false);
	
//	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//	//NSLog(@"Cookies Shutdown :%@", cookies);
//	if (cookies != nil)
//	{
//		//BOOL success = 
//		[NSKeyedArchiver archiveRootObject:cookies 
//									toFile:AppDirectoryCachePathAppended(@"cookies")];
//	}
	
	NSError *error = nil;
    if (managedObjectContext != nil) 
	{
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
		{
			ESLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}
#pragma mark -
#pragma mark Core Data stack
#pragma mark -
- (NSManagedObjectContext *) managedObjectContext 
{
    if (managedObjectContext != nil)
        return managedObjectContext;
    
	NSPersistentStoreCoordinator *coordinator = 
	[self persistentStoreCoordinator];
    
	if (coordinator != nil) 
	{
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
	
    return managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel 
{
    if (managedObjectModel != nil)
        return managedObjectModel;
    
	managedObjectModel = 
	[[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    
	return managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
	if (persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
    
	NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"KATG.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = 
	[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) 
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
	
    return persistentStoreCoordinator;
}
#pragma mark -
#pragma mark Application's Documents directory
#pragma mark -
- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
#pragma mark -
#pragma mark Custom URL
#pragma mark -
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//	return NO;
//}
#pragma mark -
#pragma mark Notifications
#pragma mark -
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone)
	{	
		NSLog(@"Notifications are disabled for this application. Not registering with Urban Airship");
		return;
	}
	[[Push sharedPush] setDeviceToken:[Push stringWithHexBytes:deviceToken]];
	[[Push sharedPush] send];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
#ifdef DEVELOPMENTBUILD
	ESLog(@"Remote Notification Register Failed: %@", error);
#endif
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSString	*	alertMessage	=	[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
	if (alertMessage)
		BasicAlert(@"Notification", alertMessage, nil, @"Continue", nil);
}
- (void)pushNotificationRegisterSucceeded:(Push *)push
{
#ifdef DEVELOPMENTBUILD
	ESLog(@"Push Registration Succeeded");
#endif
}
- (void)pushNotificationRegisterFailed:(NSError *)error
{
#ifdef DEVELOPMENTBUILD
	ESLog(@"Push Registration Error Occured:\n%@", error);
#endif
}
#ifdef DEVELOPMENTBUILD
- (void)tagRegisterSucceeded:(Push *)push
{
	NSLog(@"Tag Registration Succeeded");
}
- (void)tagRegisterFailed:(NSError *)error
{
	NSLog(@"Tag Registration Error Occured:\n%@", error);
}
- (void)tagUnregisterSucceeded:(Push *)push
{
	NSLog(@"Tag Unregistration Succeeded");
}
- (void)tagUnregisterFailed:(NSError *)error
{
	NSLog(@"Tag Unregistration Error Occured:\n%@", error);
}
#endif

#pragma mark -
#pragma mark Memory Management
#pragma mark -
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	
}
- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[hostReach release];
	
	[managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	
    [tabBarController release];
    [window release];
    
	[super dealloc];
}
#pragma mark -
#pragma mark Reachability
#pragma mark -
// Access user defaults, register for changes in reachability an start reachability object
- (void)checkReachability 
{
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(reachabilityChanged:) 
	 name:kReachabilityChangedNotification 
	 object:nil];
	hostReach = 
	[[Reachability reachabilityWithHostName:kReachabilityURL] retain];
	[hostReach startNotifier];
}
// Respond to changes in reachability
- (void)reachabilityChanged:(NSNotification* )notification
{
	Reachability *curReach = [notification object];
	//NSParameterAssert([curReach isKindOfClaGss:[Reachability class]]);
	[self updateReachability:curReach];
}
- (void)updateReachability:(Reachability*)curReach
{
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	switch (netStatus) {
		case NotReachable:
		{
			connected = NO;
			[NSTimer scheduledTimerWithTimeInterval:4.0 
											 target:self 
										   selector:@selector(noConnectionAlert:) 
										   userInfo:nil 
											repeats:NO];
			break;
		}
		case ReachableViaWWAN:
		{
			connected = YES;
			break;
		}
		case ReachableViaWiFi:
		{
			connected = YES;
			break;
		}
	}
}
- (void)noConnectionAlert:(NSTimer *)timer
{
	if (connected == NO)
	{
		BasicAlert(@"NO INTERNET CONNECTION", 
				   @"This Application requires an active internet connection. Please connect to wifi or cellular data network for full application functionality.", 
				   nil, 
				   @"OK", 
				   nil);
	}
}

@end

