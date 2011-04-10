//
//  DataModel.h
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
#import "DataModelDelegate.h"
#import "DataModelMetaData.h"
#import "Reachability.h"
#import "NetworkOperationQueue.h"
#import "OrderedDictionary.h"

@class Show;
@interface DataModel : NSObject
{
	//	
	//  Delegate array for returning data asynchronously
	//	
	NSMutableArray			*	delegates;
	//	
	//	Internet connectivity
	//	
	//	Connection Type
	//	enum {
	//	NotReachable,
	//	ReachableViaWiFi,
	//	ReachableViaWWAN,
	//	} NetworkStatus;
	//	
	Reachability			*	hostReach;
	BOOL						connected;
	NetworkStatus				connectionType;
	//
	//  Default location for storing data
	//
	NSString				*	cacheDirectoryPath;
	//
	//  Application Defaults
	//
	NSUserDefaults			*	userDefaults;
	//	
	//	Network Operation Queue
	//	Handles api calls to the web and parsing
	//	
	NetworkOperationQueue	*	operationQueue;
	//	
	//	
	//	
	NSMutableArray			*	delayedOperations;
	//	
	//	NSOperationQueue to handle core data work
	//	
	NSOperationQueue		*	coreDataQueue;
	//	
	//	Twitter
	//	
	NSDateFormatter			*	twitterSearchFormatter;
	NSDateFormatter			*	twitterUserFormatter;
	NSString				*	twitterSearchRefreshURL;
	NSString				*	twitterExtendedSearchRefreshURL;
	NSString				*	twitterHashSearchRefreshURL;
	OrderedDictionary		*	pictureCacheDictionary;
	//	
	//	
	//	
	BOOL						live;
	//	
	//	Core Data Stack
	//	
	NSManagedObjectModel			*	managedObjectModel_;
	NSPersistentStoreCoordinator	*	persistentStoreCoordinator_;
}

/******************************************************************************/
#pragma mark -
#pragma mark Accessors
#pragma mark -
/******************************************************************************/
@property (nonatomic, retain)			NSMutableArray	*	delegates;
@property (readwrite, assign, getter=isConnected)	BOOL	connected;
@property (nonatomic, readonly)				NetworkStatus	connectionType;
@property (nonatomic, retain, readonly)	NSManagedObjectContext			*	managedObjectContext;
@property (nonatomic, retain, readonly)	NSManagedObjectModel			*	managedObjectModel;
@property (nonatomic, retain, readonly)	NSPersistentStoreCoordinator	*	persistentStoreCoordinator;
/******************************************************************************/
#pragma mark -
#pragma mark Setup Methods
#pragma mark -
/******************************************************************************/
//
//  DataModel *modelSingleton = [DataModel sharedDataModel];
//  Return data model singleton
//
+ (DataModel *)sharedDataModel;
//
//  [modelSingleton addDelegate:self];
//  Add a delegate to the delegate array 
//  (register as a delegate to receive methods from the PartyCameraDataModelDelegate protocol)
//
- (void)addDelegate:(id<DataModelDelegate>)delegate;
//
//  [modelSingleton removeDelegate:self];
//  Remove a delegate from the delegate array
//  (It is critical to that any add delegate call is matched with a 
//  remove delegate call in order to ensure accurate retain counts)
//
- (void)removeDelegate:(id<DataModelDelegate>)delegate;
/******************************************************************************/
#pragma mark -
#pragma mark Core Data Stack
#pragma mark -
/******************************************************************************/
- (NSString *)applicationDocumentsDirectory;
- (void)saveContext;
/******************************************************************************/
#pragma mark -
#pragma mark API Calls
#pragma mark -
/******************************************************************************/
//	
//  Check live show status 
//  (this is set by the hosts, not an actual check of the shoutcast feeds status)
//  Returns on - (void)liveShowStatus:(BOOL)live;
//	
- (void)liveShowStatus;
//	
//	/*UNREVISEDCOMMENTS*/
//	
- (void)nextLiveShowTime;
//	
//	Login To Chat
//	
- (void)loginToChatWithRequest:(NSURLRequest *)request;
//	
//  Submit feedback to hosts
//  Doesn't return any confirmation of success
//	
- (void)feedback:(NSString *)name 
		location:(NSString *)location 
		 comment:(NSString *)comment;
//	
//  Model Object Event:
//  @property (nonatomic, retain) NSString * Title;
//  @property (nonatomic, retain) NSString * EventID;
//  @property (nonatomic, retain) NSDate   * DateTime;
//  @property (nonatomic, retain) NSString * Day;
//  @property (nonatomic, retain) NSString * Date;
//  @property (nonatomic, retain) NSString * Time;
//  @property (nonatomic, retain) NSNumber * ShowType; (BOOL: YES for Show, No for Event)
//  @property (nonatomic, retain) NSString * Details;
//	
- (NSArray *)events;
//
//  Retrieve list of shows in archive
//  Returns on - (void)shows:(NSArray *)shows;
//  NSArray of
//  NSManagedObject subclass Show
//	@property (nonatomic, retain) NSString * ForumThread;
//	@property (nonatomic, retain) NSNumber * HasNotes;
//	@property (nonatomic, retain) NSNumber * ID;
//	@property (nonatomic, retain) NSString * URL;
//	@property (nonatomic, retain) NSNumber * Number;
//	@property (nonatomic, retain) NSNumber * TV;
//	@property (nonatomic, retain) NSString * Title;
//	@property (nonatomic, retain) NSString * Notes;
//	@property (nonatomic, retain) NSString * Quote;
//	@property (nonatomic, retain) NSNumber * PictureCount;
//	@property (nonatomic, retain) NSSet* Guests;
//	@property (nonatomic, retain) NSSet* Pictures;
//
- (void)shows;
//	
//	
//	
- (Show *)fetchShow:(NSManagedObjectID *)objectID showID:(NSNumber *)showID;
//
//	Updates existing instance of 
//  NSManagedObject subclass Show
//	@property (nonatomic, retain) NSString * ForumThread;
//	@property (nonatomic, retain) NSNumber * HasNotes;
//	@property (nonatomic, retain) NSNumber * ID;
//	@property (nonatomic, retain) NSString * URL;
//	@property (nonatomic, retain) NSNumber * Number;
//	@property (nonatomic, retain) NSNumber * TV;
//	@property (nonatomic, retain) NSString * Title;
//	@property (nonatomic, retain) NSString * Notes;
//	@property (nonatomic, retain) NSString * Quote;
//	@property (nonatomic, retain) NSNumber * PictureCount;
//	@property (nonatomic, retain) NSSet* Guests;
//	@property (nonatomic, retain) NSSet* Pictures;
//
//	With Notes, Quote, URL
//
- (void)showDetails:(NSString *)ID;
//	
//	/*UNREVISEDCOMMENTS*/
//	
- (void)showPictures:(NSString *)ID;
//	
//	/*UNREVISEDCOMMENTS*/
//	
- (UIImage *)imageForURL:(NSString *)url;
//	
//	Parse a twitter search json feed
//	
- (void)twitterSearchFeed:(BOOL)extended;
//	
//	/*UNREVISEDCOMMENTS*/
//	
- (void)twitterUserFeed:(NSString *)userName;
//	
//	/*UNREVISEDCOMMENTS*/
//	
- (void)twitterHashTagFeed:(NSString *)hashTag;
//	
//	/*UNREVISEDCOMMENTS*/
//	
- (UIImage *)twitterImageForURL:(NSString *)url;

@end

@interface DataModel ()
@property (nonatomic, retain)	NSString	*	twitterSearchRefreshURL;
@property (nonatomic, retain)	NSString	*	twitterExtendedSearchRefreshURL;
@property (nonatomic, retain)	NSString	*	twitterHashSearchRefreshURL;
@property (nonatomic, readonly)	NSDateFormatter	*	twitterSearchFormatter;
@property (nonatomic, readonly)	NSDateFormatter	*	twitterUserFormatter;
- (NSArray *)events:(EventsAvailability *)status;
@end
