//
//  ESLogger.h
//
//  Created by Doug Russell on 7/17/10.
//  Copyright 2010 Doug Russell. All rights reserved.
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

#define ESLog(args...) _ESLog(__FILE__,__LINE__,args);

void _ESLog(const char *file, int lineNumber, NSString *logStatementFormat, ... );

@interface ESLogger : NSObject 
{
	NSString *_logPath;
}

@property (nonatomic, retain) NSString *logPath;

+ (ESLogger *)sharedESLogger;
+ (void)log:(NSString *)string;
- (void)log:(NSString *)string;

@end
