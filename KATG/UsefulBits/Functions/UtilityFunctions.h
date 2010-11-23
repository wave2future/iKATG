//
//  UtilityFunctions.h
//  PartyCamera
//
//  Created by Doug Russell on 6/18/10.
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

#import <Foundation/Foundation.h>

double			ToRadians(double degrees);
NSString	*	AppDirectoryCachePath();
NSString	*	AppDirectoryCachePathAppended(NSString * pathToAppend);
NSString	*	TempFileName();
NSString	*	TempFolderName();
NSString	*	AppDirectoryDocumentsPath();
NSString	*	AppDirectoryDocumentsPathAppended(NSString * pathToAppend);
NSString	*	AppDirectoryLibraryPath();
NSString	*	AppDirectoryLibraryPathAppended(NSString * pathToAppend);

#define CleanRelease(arg) [arg release];arg = nil;

NSString	*	EncodeHTMLEntities(NSString * source);
NSString	*	DecodeHTMLEntities(NSString * source);

NSString * ReplaceString(NSString *stringToOperateOn, NSString *stringToReplace, NSString *replacementString);

//NSString * platform();

#define LogCmd(cmd) _LogCmd(__FILE__,__LINE__, cmd)
void _LogCmd(const char *file, int lineNumber, SEL cmd);