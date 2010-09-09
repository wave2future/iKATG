//	
//	Push.h
//  
//	Created by Doug Russell.
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

#import <Foundation/Foundation.h>

typedef enum {
	noError								=	0,
	deviceTokenReadFailedError			=	1 << 0,
	applicationKeyReadFailedError		=	1 << 1,
	applicationSecretReadFailedError	=	1 << 2,
} PushErrorCode;

@protocol PushDelegate;

@interface Push : NSObject 
{
@public
	id<PushDelegate>	_delegate;
	NSString		*	_deviceToken;
	NSString		*	_deviceAlias;
@private
	NSString		*	_applicationKey;
	NSString		*	_applicationSecret;
	NSURLConnection	*	_tokenConnection;
	NSURLConnection	*	_tagConnection;
	NSURLConnection	*	_untagConnection;
}

@property (nonatomic, assign)	id<PushDelegate>	delegate;
@property (nonatomic, retain)	NSString		*	deviceAlias;
@property (nonatomic, retain)	NSString		*	deviceToken;

+ (Push *)sharedPush;
- (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types;
- (void)unregisterForRemoteNotifications;
- (void)send;
- (void)tag:(NSString *)tag;
+ (NSString *)stringWithHexBytes:(NSData *)bytes;

@end

@protocol PushDelegate
- (void)pushNotificationRegisterSucceeded:(Push *)push;
- (void)pushNotificationRegisterFailed:(NSError *)error;
@optional
- (void)tagRegisterSucceeded:(Push *)push;
- (void)tagRegisterFailed:(NSError *)error;
- (void)tagUnregisterSucceeded:(Push *)push;
- (void)tagUnregisterFailed:(NSError *)error;
@end
