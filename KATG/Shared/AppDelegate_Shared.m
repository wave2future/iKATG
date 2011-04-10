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
@synthesize window, tabBarController, activityIndicator;

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
	//	Start the data model
	//	
	[DataModel sharedDataModel];
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
	
	self.window.backgroundColor = [DefaultValues defaultBackgroundColor];
	
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application 
{
	[[DataModel sharedDataModel] saveContext];
	NSArray	*	cookies	=	[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	if (cookies != nil)
		[NSKeyedArchiver archiveRootObject:cookies 
									toFile:AppDirectoryCachePathAppended(@"cookies")];
	application.applicationIconBadgeNumber = 0;
}
- (void)applicationDidEnterBackground:(UIApplication *)application 
{
	[[DataModel sharedDataModel] saveContext];
	NSArray	*	cookies	=	[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	if (cookies != nil)
		[NSKeyedArchiver archiveRootObject:cookies 
									toFile:AppDirectoryCachePathAppended(@"cookies")];
	application.applicationIconBadgeNumber = 0;
}
- (UINavigationController *)wrapViewController:(UIViewController *)viewController
{
	NSParameterAssert(viewController != nil);
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	NSParameterAssert(navController != nil);
	navController.navigationBar.tintColor = [DefaultValues defaultToolbarTint];
	return [navController autorelease];
}
/******************************************************************************/
#pragma mark -
#pragma mark Notifications
#pragma mark -
/******************************************************************************/
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	if ([application enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone)
	{
#ifdef DEVELOPMENTBUILD
		NSLog(@"Notifications are disabled for this application. Not registering with Urban Airship");
#endif
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
	[tabBarController release];
	[activityIndicator release];
	[window release];
	[super dealloc];
}


@end

