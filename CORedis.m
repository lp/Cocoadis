//
//  CORedis.m
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-24.
//  Copyright (c) 2010 Louis-Philippe Perron.
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 

#import "CORedis.h"
#import "COObject.h"

// Private Methods Interface

@interface CORedis ()

-(NSString*)serialize:(id)obj;
-(id)deserialize:(NSString*)plistString;

@end

// Public Methods implementation

@implementation CORedis
@synthesize name;

- (void)dealloc {
	[name release];
	[redis release];
	[super dealloc];
}

-(id)initAsKey:(NSString*)key redis:(id)red
{
	self = [super init];
	if (self) {
		name = key;
		[name retain];
		redis = red;
		[redis retain];
	}
	return self;
}

// Private methods implementation

-(NSString*)serialize:(id)obj
{
	NSString * className = [[obj class] description];
	if ([obj isKindOfClass:[NSMutableSet class]]) {
		obj = [obj allObjects];
	}
	NSDictionary * plist = [[NSDictionary alloc] initWithObjectsAndKeys:
							className,		@"class",
							obj,			@"object",
							nil];
	NSString * plistString = [plist descriptionInStringsFileFormat];
	[plist release];
	return plistString;
}

-(id)deserialize:(NSString*)plistString
{
	id plist = [plistString propertyListFromStringsFileFormat];
	if ([plist isKindOfClass:[NSDictionary class]]) {
		NSString * className = [plist objectForKey:@"class"];
		if ([className isEqualToString:@"__NSCFSet"] ||
				   [className isEqualToString:@"NSCFSet"]
				   ) {
			return [NSSet setWithArray:[plist objectForKey:@"object"]];
		} else {
			return [plist objectForKey:@"object"];
		}

	}
	return nil;
}

@end

@implementation CORedisArray

- (void)addObject:(id)anObject
{
	[redis commandArgv:[NSArray arrayWithObjects:
						@"RPUSH", self.name, [self serialize:anObject],
						nil]];
}

- (BOOL)containsObject:(id)obj
{
	NSUInteger result = [self indexOfObject:obj];
	if (result == NSNotFound) {
		return NO;
	}
	return YES;
}

- (NSUInteger)count
{
	id result = [redis command:[NSString stringWithFormat:@"LLEN %@", self.name]];
	if ([result isKindOfClass:[NSNumber class]]) {
		return [result unsignedIntegerValue];
	}
	return 0;
}

- (void)getObjects:(id*)aBuffer range:(NSRange)range
{
	for (NSUInteger i = 0; i < range.length; i++) {
		NSUInteger idx = i + range.location;
		aBuffer[i] = [self objectAtIndex:idx];
	}
}

- (id)lastObject
{
	return [self objectAtIndex:-1];
}

- (id)objectAtIndex:(NSUInteger)index
{
	id result = [redis command:[NSString stringWithFormat:@"LINDEX %@ %d", self.name, index]];
	if ([result isKindOfClass:[NSString class]]) {
		return [self deserialize:result];
	}
	return nil;
}

- (NSArray*)objectsAtIndexes:(NSIndexSet*)indexes
{
	NSMutableArray * resultArray = [[NSMutableArray alloc] initWithCapacity:[indexes count]];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * stop) {
		id result = [self objectAtIndex:idx];
		if (result) {
			[resultArray addObject:result];
		}
	}];
	NSArray * returnArray = [NSArray arrayWithArray:resultArray];
	[resultArray release];
	return returnArray;
}

- (NSEnumerator*)objectEnumerator
{
	NSArray * resultArray = [self objectsAtIndexes:
							 [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])]];
	return [resultArray objectEnumerator];
}

- (NSEnumerator*)reverseObjectEnumerator
{
	NSArray * resultArray = [self objectsAtIndexes:
							 [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])]];
	return [resultArray reverseObjectEnumerator];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
	NSEnumerator * arrayEnum = [self objectEnumerator];
	id obj; NSUInteger count = 0; BOOL stop = NO;
	while (obj = [arrayEnum nextObject]) {
		block(obj,count,&stop);
		count++;
		if (stop) {
			break;
		}
	}
}

- (NSUInteger)indexOfObject:(id)anObject
{
	NSUInteger index = 0;
	while (YES) {
		id result = [self objectAtIndex:index];
		if (result) {
			if ([result isEqual:anObject]) {
				return index;
			} else {
				index++;
			}
		} else {
			return NSNotFound;
		}
	}
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range
{	
	for (NSInteger i = 0; i < range.length; i++) {
		NSInteger idx = i+range.location;
		id result = [self objectAtIndex:idx];
		if ([result isEqual:anObject]) {
			return idx;
		}
	}
	return NSNotFound;
}

// accepts both NSArray and COArray
- (id)firstObjectCommonWithArray:(id)array
{
	NSEnumerator * arrayEnum = [self objectEnumerator];
	id obj;
	while (obj = [arrayEnum nextObject]) {
		if ([array containsObject:obj]) {
			return obj;
		}
	}
	return nil;
}

- (BOOL)isEqualToArray:(id)otherArray
{
	if ([self count] == [otherArray count]) {
		for (NSUInteger i = 0; i < [self count]; i++) {
			if (![[self objectAtIndex:i] isEqual:[otherArray objectAtIndex:i]]) {
				return NO;
			}
		}
		return YES;
	}
	return NO;
}

- (NSArray*)arrayByAddingObject:(id)anObj
{
	NSMutableArray * reArray = [[NSMutableArray alloc] init];
	NSEnumerator * selfEnum = [self objectEnumerator];
	id arrObj;
	while (arrObj = [selfEnum nextObject]) {
		[reArray addObject:arrObj];
	}
	[reArray addObject:anObj];
	
	[reArray autorelease];
	return [NSArray arrayWithArray:reArray];
}

- (NSArray*)arrayByAddingObjectsFromArray:(id)otherArray
{
	NSMutableArray * reArray = [[NSMutableArray alloc] init];
	NSEnumerator * selfEnum = [self objectEnumerator];
	id arrObj;
	while (arrObj = [selfEnum nextObject]) {
		[reArray addObject:arrObj];
	}
	
	NSEnumerator * arrEnum = [otherArray objectEnumerator];
	while (arrObj = [arrEnum nextObject]) {
		[reArray addObject:arrObj];
	}
	[reArray autorelease];
	return [NSArray arrayWithArray:reArray];
}

- (NSArray*)filteredArrayUsingPredicate:(NSPredicate*)predicate
{
	NSMutableArray * retArray = [[NSMutableArray alloc] init];
	NSEnumerator * selfEnum = [self objectEnumerator];
	id arrObj;
	while (arrObj = [selfEnum nextObject]) {
		if ([predicate evaluateWithObject:arrObj]) {
			[retArray addObject:arrObj];
		}
	}
	[retArray autorelease];
	return [NSArray arrayWithArray:retArray];
}

- (NSArray*)subarrayWithRange:(NSRange)range
{
	NSMutableArray * newArray = [[NSMutableArray alloc] initWithCapacity:range.length];
	for (NSUInteger i = 0; i < range.length; i++) {
		NSUInteger idx = i + range.location;
		id anObj = [self objectAtIndex:idx];
		if (anObj) {
			[newArray addObject:anObj];
		} else {
			[newArray addObject:[NSNull null]];
		}

	}
	NSArray * retArray = [NSArray arrayWithArray:newArray];
	[newArray release];
	return retArray;
}

- (void)addObjectsFromArray:(NSArray*)otherArray
{
	id arrObj;
	for (arrObj in otherArray) {
		[self addObject:arrObj];
	}
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{	
	id curObj = [redis command:[NSString stringWithFormat:@"LINDEX %@ %d", self.name, index]];
	if ([curObj isKindOfClass:[NSString class]]) {
		NSArray * command = [[NSArray alloc] initWithObjects:
							 @"LINSERT", self.name,
							 @"BEFORE", curObj, [self serialize:anObject],
							 nil];
		[redis commandArgv:command];
		[command release];
	}
}

- (void)removeObjectAtIndex:(NSUInteger)index
{	
	NSUInteger arrCount = [self count];
	if (index > arrCount-1) {
		NSException *e = [NSException
						  exceptionWithName:NSRangeException
						  reason:@"Index out of range"
						  userInfo:nil];
		@throw e;
	} else if (index == arrCount-1) {
		[redis command:[NSString stringWithFormat:@"RPOP %@", self.name]];
	} else if (index > 0) {
		NSLog(@"single remove: %d", index);
		NSArray * endList = [self subarrayWithRange:NSMakeRange((index+1), (arrCount-index-1))];
		NSLog(@"got the end list: %@", [endList description]);
		[redis command:[NSString stringWithFormat:@"LTRIM %@ %d %d",
						self.name, 0, index-1]];
		NSLog(@"array trimmed!");
		if ([endList isKindOfClass:[NSArray class]]) {
			[self addObjectsFromArray:endList];
			NSLog(@"array re put!: %@", [self description]);
		}
	} else {
		[redis command:[NSString stringWithFormat:@"LPOP %@", self.name]];
	}
}

- (void)removeLastObject
{
	[redis command:[NSString stringWithFormat:@"LTRIM %@ 0 -2", self.name]];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
	NSArray * command = [[NSArray alloc] initWithObjects:@"LSET", self.name,
						 [NSNumber numberWithUnsignedInteger:index],
						 [self serialize:anObject],
						 nil];
	[redis commandArgv:command];
	[command release];
}

- (void)insertObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes
{
	NSUInteger currentIndex = [indexes firstIndex];
	NSUInteger i, count = [indexes count];
	
	for (i = 0; i < count; i++) {
		[self insertObject:[objects objectAtIndex:i] atIndex:currentIndex];
		currentIndex = [indexes indexGreaterThanIndex:currentIndex];
	}
}

- (void)removeAllObjects
{
	NSArray * command = [[NSArray alloc] initWithObjects:
						 @"DEL", self.name,
						 nil];
	[redis commandArgv:command];
	[command release];
}

- (void)removeObject:(id)anObject
{
	NSArray * command = [[NSArray alloc] initWithObjects:
						 @"LREM", self.name,
						 [NSNumber numberWithUnsignedInteger:0],
						 [self serialize:anObject],
						 nil];
	[redis commandArgv:command];
	[command release];
}

- (void)removeObject:(id)anObject inRange:(NSRange)aRange
{	
	NSInteger idx;
	idx = [self indexOfObject:anObject inRange:aRange];
	while (idx < NSIntegerMax) {
		NSLog(@"idx: %d", idx);
		[self removeObjectAtIndex:idx];
		aRange = NSMakeRange(aRange.location, aRange.length-1);
		idx = [self indexOfObject:anObject inRange:aRange];
	}
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes
{
	[indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * stop) {
		NSLog(@"removing idx: %d", idx);
		[self removeObjectAtIndex:idx];
		NSLog(@"array became: %@", [self description]);
	}];
}

- (NSString*)description
{
	return [[self subarrayWithRange:NSMakeRange(0, [self count])] description];
}

@end

@implementation CORedisDictionary



@end

