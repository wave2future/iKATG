//
//  AppDelegate_Shared.m
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

#import "AppDelegate_Shared.h"
#import "DataModel.h"

@implementation AppDelegate_Shared
@synthesize window, tabBarController;

void uncaughtExceptionHandler(NSException *exception) 
{
	ESLog(@"Uncaught Exception: %@", exception);
}
/******************************************************************************/
#pragma mark -
#pragma mark Application Life Cycle
#pragma mark -
/******************************************************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	//	
	//	
	//	
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	//	
	//	
	//	
	[[DataModel sharedDataModel] setManagedObjectContext:self.managedObjectContext];
	//	
	//	
	//	
	NSArray	*	cookies	=	[NSKeyedUnarchiver unarchiveObjectWithFile:AppDirectoryCachePathAppended(@"cookies")];
	if (cookies != nil)
	{
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
		for (NSHTTPCookie *cookie in cookies)
		{
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
		}
	}
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application 
{
	[self saveContext];
	NSArray	*	cookies	=	[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	if (cookies != nil)
		[NSKeyedArchiver archiveRootObject:cookies 
									toFile:AppDirectoryCachePathAppended(@"cookies")];
	application.applicationIconBadgeNumber = 0;
}
- (void)applicationDidEnterBackground:(UIApplication *)application 
{
	[self saveContext];
	NSArray	*	cookies	=	[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	if (cookies != nil)
		[NSKeyedArchiver archiveRootObject:cookies 
									toFile:AppDirectoryCachePathAppended(@"cookies")];
	application.applicationIconBadgeNumber = 0;
}
- (void)saveContext 
{
    NSError *error = nil;
    if (managedObjectContext_ != nil) 
	{
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) 
		{
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}
/******************************************************************************/
#pragma mark -
#pragma mark Core Data Stack
#pragma mark -
/******************************************************************************/
- (NSManagedObjectContext *)managedObjectContext 
{
	/**
	 Returns the managed object context for the application.
	 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
	 */
	if (managedObjectContext_ != nil)
		return managedObjectContext_;
	
    NSPersistentStoreCoordinator	*	coordinator	=	[self persistentStoreCoordinator];
    if (coordinator != nil)
	{
		managedObjectContext_	=	[[NSManagedObjectContext alloc] init];
		[managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}
- (NSManagedObjectModel *)managedObjectModel 
{
	/**
	 Returns the managed object model for the application.
	 If the model doesn't already exist, it is created from the application's model.
	 */
	if (managedObjectModel_ != nil)
		return managedObjectModel_;
	
	NSString	*	modelPath	=	[[NSBundle mainBundle] pathForResource:@"KATG" ofType:@"momd"];
	NSURL		*	modelURL	=	[NSURL fileURLWithPath:modelPath];
	managedObjectModel_			=	[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
	return managedObjectModel_;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
	/**
	 Returns the persistent store coordinator for the application.
	 If the coordinator doesn't already exist, it is created and the application's store added to it.
	 */
	if (persistentStoreCoordinator_ != nil)
		return persistentStoreCoordinator_;
	
	NSURL	*	storeURL	=	[NSURL fileURLWithPath:
								 [[self applicationDocumentsDirectory] 
								  stringByAppendingPathComponent: @"KATG.sqlite"]];
    
    NSError	*	error		=	nil;
    persistentStoreCoordinator_	=	[[NSPersistentStoreCoordinator alloc] 
									 initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType 
												   configuration:nil 
															 URL:storeURL 
														 options:nil 
														   error:&error])
	{
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}
/******************************************************************************/
#pragma mark -
#pragma mark Application's Documents Directory
#pragma mark -
/******************************************************************************/
- (NSString *)applicationDocumentsDirectory
{
	/**
	 Returns the path to the application's Documents directory.
	 */
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
/******************************************************************************/
#pragma mark -
#pragma mark Memory management
#pragma mark -
/******************************************************************************/
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}
- (void)dealloc
{
	[managedObjectContext_ release];
	[managedObjectModel_ release];
	[persistentStoreCoordinator_ release];
	
	[tabBarController release];
	[window release];
	[super dealloc];
}


@end

