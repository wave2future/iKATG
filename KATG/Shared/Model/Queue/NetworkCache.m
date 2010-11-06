//
//  NetworkCache.m
//	
//	Created by Doug Russell on 9/9/10.
//	Copyright Doug Russell 2010. All rights reserved.
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

#import "NetworkCache.h"
#import "SynthesizeSingleton.h"

@implementation NetworkCache
SYNTHESIZE_SINGLETON_FOR_CLASS(NetworkCache);

- (id)init 
{
	self = [super initWithMemoryCapacity: 1024 * 1024 * 2 
							diskCapacity: 0 
								diskPath: nil];
	if (self != nil)
	{
		
	}
	return self;
}
- (void)superRelease
{
	[super release];
}

@end
