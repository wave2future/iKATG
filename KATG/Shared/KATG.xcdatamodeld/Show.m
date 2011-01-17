//
//  Show.m
//  KATG
//
//  Created by Doug Russell on 1/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Show.h"
#import "Picture.h"


@implementation Show
@dynamic ForumThread;
@dynamic HasNotes;
@dynamic Guests;
@dynamic ID;
@dynamic PDT;
@dynamic URL;
@dynamic Number;
@dynamic TV;
@dynamic Title;
@dynamic Notes;
@dynamic Quote;
@dynamic PictureCount;
@dynamic Pictures;

#if 0
/*
 *
 * Property methods not providing customized implementations should be removed.  
 * Optimized versions will be provided dynamically by the framework at runtime.
 *
 *
*/

- (NSString *)ForumThread {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"ForumThread"];
    tmpValue = [self primitiveForumThread];
    [self didAccessValueForKey:@"ForumThread"];
    
    return tmpValue;
}

- (void)setForumThread:(NSString *)value {
    [self willChangeValueForKey:@"ForumThread"];
    [self setPrimitiveForumThread:value];
    [self didChangeValueForKey:@"ForumThread"];
}

- (BOOL)validateForumThread:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)HasNotes {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"HasNotes"];
    tmpValue = [self primitiveHasNotes];
    [self didAccessValueForKey:@"HasNotes"];
    
    return tmpValue;
}

- (void)setHasNotes:(NSNumber *)value {
    [self willChangeValueForKey:@"HasNotes"];
    [self setPrimitiveHasNotes:value];
    [self didChangeValueForKey:@"HasNotes"];
}

- (BOOL)validateHasNotes:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)Guests {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"Guests"];
    tmpValue = [self primitiveGuests];
    [self didAccessValueForKey:@"Guests"];
    
    return tmpValue;
}

- (void)setGuests:(NSString *)value {
    [self willChangeValueForKey:@"Guests"];
    [self setPrimitiveGuests:value];
    [self didChangeValueForKey:@"Guests"];
}

- (BOOL)validateGuests:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)ID {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"ID"];
    tmpValue = [self primitiveID];
    [self didAccessValueForKey:@"ID"];
    
    return tmpValue;
}

- (void)setID:(NSNumber *)value {
    [self willChangeValueForKey:@"ID"];
    [self setPrimitiveID:value];
    [self didChangeValueForKey:@"ID"];
}

- (BOOL)validateID:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)PDT {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"PDT"];
    tmpValue = [self primitivePDT];
    [self didAccessValueForKey:@"PDT"];
    
    return tmpValue;
}

- (void)setPDT:(NSNumber *)value {
    [self willChangeValueForKey:@"PDT"];
    [self setPrimitivePDT:value];
    [self didChangeValueForKey:@"PDT"];
}

- (BOOL)validatePDT:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)URL {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"URL"];
    tmpValue = [self primitiveURL];
    [self didAccessValueForKey:@"URL"];
    
    return tmpValue;
}

- (void)setURL:(NSString *)value {
    [self willChangeValueForKey:@"URL"];
    [self setPrimitiveURL:value];
    [self didChangeValueForKey:@"URL"];
}

- (BOOL)validateURL:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)Number {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"Number"];
    tmpValue = [self primitiveNumber];
    [self didAccessValueForKey:@"Number"];
    
    return tmpValue;
}

- (void)setNumber:(NSNumber *)value {
    [self willChangeValueForKey:@"Number"];
    [self setPrimitiveNumber:value];
    [self didChangeValueForKey:@"Number"];
}

- (BOOL)validateNumber:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)TV {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"TV"];
    tmpValue = [self primitiveTV];
    [self didAccessValueForKey:@"TV"];
    
    return tmpValue;
}

- (void)setTV:(NSNumber *)value {
    [self willChangeValueForKey:@"TV"];
    [self setPrimitiveTV:value];
    [self didChangeValueForKey:@"TV"];
}

- (BOOL)validateTV:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)Title {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"Title"];
    tmpValue = [self primitiveTitle];
    [self didAccessValueForKey:@"Title"];
    
    return tmpValue;
}

- (void)setTitle:(NSString *)value {
    [self willChangeValueForKey:@"Title"];
    [self setPrimitiveTitle:value];
    [self didChangeValueForKey:@"Title"];
}

- (BOOL)validateTitle:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)Notes {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"Notes"];
    tmpValue = [self primitiveNotes];
    [self didAccessValueForKey:@"Notes"];
    
    return tmpValue;
}

- (void)setNotes:(NSString *)value {
    [self willChangeValueForKey:@"Notes"];
    [self setPrimitiveNotes:value];
    [self didChangeValueForKey:@"Notes"];
}

- (BOOL)validateNotes:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSString *)Quote {
    NSString * tmpValue;
    
    [self willAccessValueForKey:@"Quote"];
    tmpValue = [self primitiveQuote];
    [self didAccessValueForKey:@"Quote"];
    
    return tmpValue;
}

- (void)setQuote:(NSString *)value {
    [self willChangeValueForKey:@"Quote"];
    [self setPrimitiveQuote:value];
    [self didChangeValueForKey:@"Quote"];
}

- (BOOL)validateQuote:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (NSNumber *)PictureCount {
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"PictureCount"];
    tmpValue = [self primitivePictureCount];
    [self didAccessValueForKey:@"PictureCount"];
    
    return tmpValue;
}

- (void)setPictureCount:(NSNumber *)value {
    [self willChangeValueForKey:@"PictureCount"];
    [self setPrimitivePictureCount:value];
    [self didChangeValueForKey:@"PictureCount"];
}

- (BOOL)validatePictureCount:(id *)valueRef error:(NSError **)outError {
    // Insert custom validation logic here.
    return YES;
}

- (void)addPicturesObject:(Picture *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitivePictures] addObject:value];
    [self didChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removePicturesObject:(Picture *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitivePictures] removeObject:value];
    [self didChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addPictures:(NSSet *)value {    
    [self willChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitivePictures] unionSet:value];
    [self didChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removePictures:(NSSet *)value {
    [self willChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitivePictures] minusSet:value];
    [self didChangeValueForKey:@"Pictures" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#endif

@end
