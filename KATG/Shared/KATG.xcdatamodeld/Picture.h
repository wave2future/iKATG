//
//  Picture.h
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Show;

@interface Picture :  NSManagedObject  
{
}

@property (nonatomic, retain) NSData * Data;
@property (nonatomic, retain) NSString * URL;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * ShowID;
@property (nonatomic, retain) Show * newRelationship;

@end



