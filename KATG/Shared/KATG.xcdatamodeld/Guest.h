//
//  Guest.h
//  KATG
//
//  Created by Doug Russell on 9/16/10.
//  Copyright 2010 Everything Solution. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Show;

@interface Guest :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * Guest;
@property (nonatomic, retain) NSSet* Show;

@end


@interface Guest (CoreDataGeneratedAccessors)
- (void)addShowObject:(Show *)value;
- (void)removeShowObject:(Show *)value;
- (void)addShow:(NSSet *)value;
- (void)removeShow:(NSSet *)value;

@end

