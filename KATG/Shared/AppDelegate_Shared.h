//
//  AppDelegate_Shared.h
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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Push.h"

@interface AppDelegate_Shared : NSObject 
<UIApplicationDelegate, UITabBarDelegate, PushDelegate> 
{
	UIWindow				*	window;
	UITabBarController		*	tabBarController;
	UIActivityIndicatorView	*	activityIndicator;
@private
	NSManagedObjectContext			*	managedObjectContext_;
	NSManagedObjectModel			*	managedObjectModel_;
	NSPersistentStoreCoordinator	*	persistentStoreCoordinator_;
}

@property (nonatomic, retain)	IBOutlet	UIWindow				*	window;
@property (nonatomic, retain)	IBOutlet	UITabBarController		*	tabBarController;
@property (nonatomic, retain)	IBOutlet	UIActivityIndicatorView	*	activityIndicator;

@property (nonatomic, retain, readonly)	NSManagedObjectContext			*	managedObjectContext;
@property (nonatomic, retain, readonly)	NSManagedObjectModel			*	managedObjectModel;
@property (nonatomic, retain, readonly)	NSPersistentStoreCoordinator	*	persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
- (UINavigationController *)wrapViewController:(UIViewController *)viewController;

@end
