//
//  CORedis.h
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

#import <Foundation/Foundation.h>

@interface CORedis : NSObject {
	NSString * name;
	id redis;
}
@property(retain, readonly) NSString * name;
-(id)initAsKey:(NSString*)key redis:(id)red;

@end

@interface CORedisArray : CORedis {
	
}

- (void)addObject:(id)anObject;

- (BOOL)containsObject:(id)obj;
- (NSUInteger)count;
- (void)getObjects:(id*)aBuffer range:(NSRange)range;
- (id)lastObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSArray*)objectsAtIndexes:(NSIndexSet*)indexes;
- (NSEnumerator*)objectEnumerator;
- (NSEnumerator*)reverseObjectEnumerator;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

- (NSUInteger)indexOfObject:(id)anObject;
- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range;
- (id)firstObjectCommonWithArray:(NSArray*)array;
- (BOOL)isEqualToArray:(NSArray*)otherArray;

- (NSArray*)arrayByAddingObject:(id)anObj;
- (NSArray*)arrayByAddingObjectsFromArray:(id)otherArray;
- (NSArray*)filteredArrayUsingPredicate:(NSPredicate*)predicate;
- (NSArray*)subarrayWithRange:(NSRange)range;

- (void)addObjectsFromArray:(NSArray*)otherArray;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeLastObject;

@end

@interface CORedisDictionary : CORedis {
	
}

@end

