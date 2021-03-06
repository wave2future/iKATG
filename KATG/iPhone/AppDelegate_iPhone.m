//
//  AppDelegate_iPhone.m
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

#import "AppDelegate_iPhone.h"
#import "OnAirViewController_iPhone.h"
#import "EventsTableViewController_iPhone.h"
#import "ArchiveTableViewController_iPhone.h"
#import "TwitterTableViewController_iPhone.h"

@implementation AppDelegate_iPhone

/******************************************************************************/
#pragma mark -
#pragma mark Application lifecycle
#pragma mark -
/******************************************************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
	[self.activityIndicator startAnimating];
	
//	[self performSelector:@selector(loadTabs) withObject:nil afterDelay:4.0];
	
	[self loadTabs];
	
	[self.window addSubview:tabBarController.view];
	
	[window makeKeyAndVisible];
	
	return YES;
}
- (void)loadTabs
{
	OnAirViewController_iPhone *onAirViewController = [[OnAirViewController_iPhone alloc] init];
	EventsTableViewController_iPhone *eventsViewController = [[EventsTableViewController_iPhone alloc] init];
	ArchiveTableViewController_iPhone *archiveViewController = [[ArchiveTableViewController_iPhone alloc] init];
	TwitterTableViewController_iPhone *twitterViewController = [[TwitterTableViewController_iPhone alloc] init];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:
											 onAirViewController, 
											 [self wrapViewController:eventsViewController], 
											 [self wrapViewController:archiveViewController], 
											 [self wrapViewController:twitterViewController], 
											 nil];
	[onAirViewController release];
	[eventsViewController release];
	[archiveViewController release];
	[twitterViewController release];
	
	[self.activityIndicator stopAnimating];
}
- (void)applicationWillResignActive:(UIApplication *)application 
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}
- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}
- (void)applicationWillTerminate:(UIApplication *)application 
{
	/**
	 Superclass implementation saves changes in the application's managed object context before the application terminates.
	 */
	[super applicationWillTerminate:application];
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
    [super applicationDidReceiveMemoryWarning:application];
}
- (void)dealloc 
{
	[super dealloc];
}

@end
