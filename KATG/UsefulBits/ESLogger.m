//
//  ESLogger.m
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

#define ESLOGDEBUG

#import "ESLogger.h"
#import "SynthesizeSingleton.h"

void _ESLog(const char *file, int lineNumber, NSString *logStatementFormat, ... )ESLOGDEBUG
{
	va_list ap;
	va_start (ap, logStatementFormat);
	
	NSString *logStatement = nil;
	if (logStatementFormat != nil)
	{
		logStatement = [[NSString alloc] initWithFormat:logStatementFormat arguments:ap];
	}
	else
	{
		logStatement = [[NSString alloc] initWithString:@"Attempted to log nil statement"];
	}
	
	va_end (ap);
	
	NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
	
	[ESLogger log:[NSString stringWithFormat:@"%f - %@:%d, %@", 
				   CFAbsoluteTimeGetCurrent(),
				   fileName, 
				   lineNumber, 
				   logStatement]];
	
	[logStatement release];
}

@implementation ESLogger
@synthesize logPath = _logPath;

SYNTHESIZE_SINGLETON_FOR_CLASS(ESLogger);

+ (void)log:(NSString *)string
{
	[[ESLogger sharedESLogger] log:string];
}
- (id)init
{
	self = [super init];
	if (self)
	{
		NSString *path = AppDirectoryDocumentsPathAppended(@"Debug.log");
		if (path)
			self.logPath = path;
	}
	return self;
}
- (void)dealloc
{
	[_logPath release];
	[super dealloc];
}
- (void)log:(NSString *)string
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.logPath])
		[[NSFileManager defaultManager] createFileAtPath:self.logPath contents:[NSData data] attributes:nil];
	
	NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:self.logPath];
	NSInteger size = [output seekToEndOfFile];
	if (size > 400000)
	{
		[output truncateFileAtOffset:0];
		[output seekToFileOffset:0];
	}
	NSString *newLogStatement = [NSString stringWithFormat:@"%@ %@", [[NSDate date] description], string];
	if (![newLogStatement hasSuffix: @"\n"])
		newLogStatement = [newLogStatement stringByAppendingString:@"\n"];
#ifdef ESLOGDEBUG
	if (newLogStatement.length > 1000)
	{
		fprintf(stderr,"%s",[[newLogStatement substringToIndex:1000] UTF8String]);
	}
	else 
	{
		fprintf(stderr,"%s",[newLogStatement UTF8String]);
	}
#endif
	[output writeData:[newLogStatement dataUsingEncoding:NSUTF8StringEncoding]];
	[output closeFile];
}

@end
