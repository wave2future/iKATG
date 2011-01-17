//
//  Picture.h
//  KATG
//
//  Created by Doug Russell on 1/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Show;

@interface Picture : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * ShowID;
@property (nonatomic, retain) NSString * ThumbURL;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * URL;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) Show * Show;

@end
