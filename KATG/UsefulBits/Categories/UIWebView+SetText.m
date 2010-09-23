//
//  UIWebView+SetText.m
//	
//  Created by Doug Russell on 8/15/10.
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

#import "UIWebView+SetText.h"

@implementation UIWebView (SetText)
- (void)setText:(NSString *)text
{
	NSString	*	_htmlStart	=	nil;
	_htmlStart	=	[NSString stringWithFormat:@"<html>\n<head>\n<style>\nbody {\n\tbackground-color: transparent;\n\tcolor: %@;\n\tpadding: 0px;\n\tfont-family: Helvetica; \n\tfont-size: %@;\n\tmargin: 10px;\n}\na {\n\tcolor: %@;\n\tfont-family: Helvetica; \n\tfont-size: %@;\n}\n</style>\n<meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0; maximum-scale=1.0;\">\n</head>\n<body>\n\t<p>", [self textColor], [self fontSize], [self linkColor], [self linkSize]];
	NSString	*	_htmlEnd	=	nil;
	_htmlEnd	=	@"\n</body>\n</html>";
	[self loadHTMLString:[NSString stringWithFormat:@"%@%@%@", _htmlStart, text, _htmlEnd] 
				 baseURL:nil];
	[self loadHTMLString:[NSString stringWithFormat:@"%@%@%@", _htmlStart, text, _htmlEnd] 
				 baseURL:nil];
}
- (NSString *)textColor
{
	return @"#000";
}
- (NSString *)fontSize
{
	return @"14pt";
}
- (NSString *)linkColor
{
	return @"#438a23";
}
- (NSString *)linkSize
{
	return @"14pt";
}
@end
