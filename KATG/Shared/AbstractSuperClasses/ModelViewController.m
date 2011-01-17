//
//  ModelViewController.m
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

#import "ModelViewController.h"

@implementation ModelViewController

/******************************************************************************/
#pragma mark -
#pragma mark Memory Management
#pragma mark -
/******************************************************************************/
- (id)init
{
	if ((self = [super initWithNibName:nil bundle:nil]))
	{
		
	}
	return self;
}
- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}
- (void)dealloc 
{
	[model removeDelegate:self];
	model	=	nil;
	[super dealloc];
}
/******************************************************************************/
#pragma mark -
#pragma mark View Life Cycle
#pragma mark -
/******************************************************************************/
- (void)viewDidLoad 
{
	[super viewDidLoad];
	//	
	//	Default Background Color
	//	
	self.view.backgroundColor = [DefaultValues defaultBackgroundColor];
	//	
	//	Instantiate Model and add self as delegate
	//	
	model	=	[DataModel sharedDataModel];
	[model addDelegate:self];
}
- (void)viewDidUnload 
{
	[super viewDidUnload];
}
/******************************************************************************/
#pragma mark -
#pragma mark Data Model Delegates
#pragma mark -
/******************************************************************************/
- (void)error:(NSError *)error display:(BOOL)display
{
	
}

@end
