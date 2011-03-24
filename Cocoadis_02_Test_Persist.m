//
//  Cocoadis_02_TestArray.m
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-11.
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


#import <SenTestingKit/SenTestingKit.h>
#import <Foundation/Foundation.h>

#ifdef IOS
#import "Cocoadis.h"
#import "COHelper_iOS.h"
#endif

#ifndef IOS
#import "Cocoadis/Cocoadis.h"
#import "Cocoadis/COHelper_OSX.h"
#endif

@interface Cocoadis_02_TestPersist : SenTestCase {
	
}

@end

@implementation Cocoadis_02_TestPersist

- (void)setUp {
	[[Cocoadis persistence] setBasePath:NSTemporaryDirectory()];
}

- (void)tearDown {
	[[Cocoadis persistence] flushCache];
	[[Cocoadis persistence] clearPersistence];
}

- (void)test_01_path {
	[[Cocoadis persistence] clearPersistence];
	id mArray = [[NSMutableArray alloc] initWithPersistence:@"mArray"];
	STAssertTrue([mArray count] == 0, @"is not an empty array");
}

- (void)test_01_copath {
	[[Cocoadis persistence] clearPersistence];
	id mArray = [[COArray alloc] initWithPersistence:@"mArray"];
	STAssertTrue([mArray count] == 0, @"is not an empty array");
}

- (void) test_02_Array {
	id mArray = [[NSMutableArray alloc] initWithPersistence:@"mArray"];
	[mArray addObject:@"a"];
	STAssertTrue([[mArray objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	id mArray2 = [[NSMutableArray alloc] initWithPersistence:@"mArray"];
	STAssertNotNil(mArray2, @"array: returned nil");
	STAssertTrue([[mArray2 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mArray3 = [[NSMutableArray alloc] initWithPersistence:@"mArray"];
	STAssertNotNil(mArray3, @"array: returned nil");
	STAssertTrue([[mArray3 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
}

- (void) test_02_coArray {
	id mArray = [[COArray alloc] initWithPersistence:@"mArray"];
	[mArray addObject:@"a"];
	STAssertTrue([[mArray objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	id mArray2 = [[COArray alloc] initWithPersistence:@"mArray"];
	STAssertNotNil(mArray2, @"array: returned nil");
	STAssertTrue([[mArray2 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mArray3 = [[COArray alloc] initWithPersistence:@"mArray"];
	STAssertNotNil(mArray3, @"array: returned nil");
	STAssertTrue([[mArray3 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
}

- (void)test_03_Dictionary {
	id mDict = [[NSMutableDictionary alloc] initWithPersistence:@"mDict"];
	[mDict setObject:@"letter a" forKey:@"a"];
	STAssertTrue([[mDict objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	id mDict2 = [[NSMutableDictionary alloc] initWithPersistence:@"mDict"];
	STAssertNotNil(mDict2, @"dict returned nil");
	STAssertTrue([[mDict2 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mDict3 = [[NSMutableDictionary alloc] initWithPersistence:@"mDict"];
	STAssertNotNil(mDict3, @"dict returned nil");
	STAssertTrue([[mDict3 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
}

- (void)test_03_coDictionary {
	id mDict = [[CODictionary alloc] initWithPersistence:@"mDict"];
	[mDict setObject:@"letter a" forKey:@"a"];
	STAssertTrue([[mDict objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	id mDict2 = [[CODictionary alloc] initWithPersistence:@"mDict"];
	STAssertNotNil(mDict2, @"dict returned nil");
	STAssertTrue([[mDict2 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mDict3 = [[CODictionary alloc] initWithPersistence:@"mDict"];
	STAssertNotNil(mDict3, @"dict returned nil");
	STAssertTrue([[mDict3 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
}


- (void)test_04_String {
	id mString = [[NSMutableString alloc] initWithPersistence:@"mString"];
	[mString setString:@"a string"];
	STAssertTrue([mString isEqualToString:@"a string"], @"wrong string: %@", mString);
	
	id mString2 = [[NSMutableString alloc] initWithPersistence:@"mString"];
	STAssertNotNil(mString2, @"string returned nil");
	STAssertTrue([mString2 isEqualToString:@"a string"], @"wrong string: %@", mString2);
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mString3 = [[NSMutableString alloc] initWithPersistence:@"mString"];
	STAssertNotNil(mString3, @"string returned nil");
	STAssertTrue([mString3 isEqualToString:@"a string"], @"wrong string: %@", mString3);
}

- (void)test_04_coString {
	id mString = [[COString alloc] initWithPersistence:@"mString"];
	[mString setString:@"a string"];
	STAssertTrue([mString isEqualToString:@"a string"], @"wrong string: %@", mString);
	
	id mString2 = [[COString alloc] initWithPersistence:@"mString"];
	STAssertNotNil(mString2, @"string returned nil");
	STAssertTrue([mString2 isEqualToString:@"a string"], @"wrong string: %@", mString2);
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mString3 = [[COString alloc] initWithPersistence:@"mString"];
	STAssertNotNil(mString3, @"string returned nil");
	STAssertTrue([mString3 isEqualToString:@"a string"], @"wrong string: %@", mString3);
}


- (void) test_05_Set {
	id mSet = [[NSMutableSet alloc] initWithPersistence:@"mSet"];
	[mSet addObject:@"a"];
	STAssertTrue([[mSet member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	id mSet2 = [[NSMutableSet alloc] initWithPersistence:@"mSet"];
	STAssertNotNil(mSet2, @"set: returned nil");
	STAssertTrue([[mSet2 member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mSet3 = [[NSMutableSet alloc] initWithPersistence:@"mSet"];
	STAssertNotNil(mSet3, @"set: returned nil");
	STAssertTrue([[mSet3 member:@"a"] isEqualToString:@"a"], @"is not a set");
}

- (void) test_05_coSet {
	id mSet = [[COSet alloc] initWithPersistence:@"mSet"];
	[mSet addObject:@"a"];
	STAssertTrue([[mSet member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	id mSet2 = [[COSet alloc] initWithPersistence:@"mSet"];
	STAssertNotNil(mSet2, @"set: returned nil");
	STAssertTrue([[mSet2 member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mSet3 = [[COSet alloc] initWithPersistence:@"mSet"];
	STAssertNotNil(mSet3, @"set: returned nil");
	STAssertTrue([[mSet3 member:@"a"] isEqualToString:@"a"], @"is not a set");
}


- (void)test_06_flushCache {
	id mArray = [[COArray alloc] initWithPersistence:@"mArray"];
	[mArray addObject:@"a"];
	STAssertTrue([mArray count] == 1, @"array of wrong length");
	
	[[Cocoadis persistence] flushCache];
	
	id mArray2 = [[COArray alloc] initWithPersistence:@"mArray"];
	STAssertTrue([mArray2 count] == 0, @"array of wrong length");
}

- (void)test_07_clearPersistence {
	id mArray = [[COArray alloc] initWithPersistence:@"mArray"];
	[mArray addObject:@"a"];
	STAssertTrue([mArray count] == 1, @"array of wrong length");
	
	[[Cocoadis persistence] saveAll];
	[NSThread sleepForTimeInterval:1];
	[[Cocoadis persistence] flushCache];
	[[Cocoadis persistence] clearPersistence];
	
	id mArray2 = [[COArray alloc] initWithPersistence:@"mArray"];
	STAssertTrue([mArray2 count] == 0, @"array of wrong length");
}

- (void)test_08_cleanCache {
	if (! [COHelper gc]) {
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 0, @"the db cache doesn't start clean");
		
		id mArray = [[COArray alloc] initWithPersistence:@"mArray"];
		id mDict = [[CODictionary alloc] initWithPersistence:@"mDict"];
		id mString = [[COString alloc] initWithPersistence:@"mString"];
		id mSet = [[COSet alloc] initWithPersistence:@"mSet"];
		
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 4, @"the db cache didn't keep the objects");
		
		[mArray release];
		[[Cocoadis persistence] cleanCache];
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 3,
					 @"the db cache didn't clean the objects, count should be 3, it is %d",
					 [[[Cocoadis persistence] dbCache] count]);
		
		STAssertTrue([[[Cocoadis persistence] dbCache] objectForKey:@"mDict"] &&
					 [[[Cocoadis persistence] dbCache] objectForKey:@"mString"] &&
					 [[[Cocoadis persistence] dbCache] objectForKey:@"mSet"],
					 @"the db cache cleaned the wrong object");
		
		[mDict release];
		[[Cocoadis persistence] cleanCache];
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 2,
					 @"the db cache didn't clean the objects, count should be 2, it is %d",
					 [[[Cocoadis persistence] dbCache] count]);
		
		STAssertTrue([[[Cocoadis persistence] dbCache] objectForKey:@"mString"] &&
					 [[[Cocoadis persistence] dbCache] objectForKey:@"mSet"],
					 @"the db cache cleaned the wrong object");
		
		[mString release];
		[[Cocoadis persistence] cleanCache];
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 1,
					 @"the db cache didn't clean the objects, count should be 1, it is %d",
					 [[[Cocoadis persistence] dbCache] count]);
		
		STAssertNotNil([[[Cocoadis persistence] dbCache] objectForKey:@"mSet"],
					   @"the db cache cleaned the wrong object");
		
		[mSet release];
		[[Cocoadis persistence] cleanCache];
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 0,
					 @"the db cache didn't clean the objects, count should be 0, it is %d",
					 [[[Cocoadis persistence] dbCache] count]);
	}
}

- (void)test_09_autoClean {
	if (! [COHelper gc]) {
		STAssertTrue([[Cocoadis persistence] cleanIter] == 4,
					 @"the db has clean more than expected, should be 4, got: %d",
					 [[Cocoadis persistence] cleanIter]);
		
		[[Cocoadis persistence] startAutoClean];
		
		id mArray = [[COArray alloc] initWithPersistence:@"mArray"];
		id mDict = [[CODictionary alloc] initWithPersistence:@"mDict"];
		id mString = [[COString alloc] initWithPersistence:@"mString"];
		id mSet = [[COSet alloc] initWithPersistence:@"mSet"];
		
		STAssertTrue([[Cocoadis persistence] cleanIter] > 4,
					 @"the db has clean more than expected, should be more than 4, got: %d",
					 [[Cocoadis persistence] cleanIter]);
		
		[mArray release]; [mDict release]; [mString release]; [mSet release];
	}
}

- (void)test_10_saveToPersistence {
	id mArray = [[COArray alloc] initWithPersistence:@"mArrayAlone"];
	[mArray addObject:@"zzz"];
		
	[mArray persist];
	[NSThread sleepForTimeInterval:1];
	[[Cocoadis persistence] flushCache];
	
	id mArray2 = [[COArray alloc] initWithPersistence:@"mArrayAlone"];
	STAssertTrue([mArray2 containsObject:@"zzz"], @"saveToPersistence didn't save object");
}

- (void) test_11_Array_autorelease {
	id mArray = [NSMutableArray objectWithPersistence:@"mArray"];
	[mArray addObject:@"a"];
	STAssertTrue([[mArray objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	id mArray2 = [NSMutableArray objectWithPersistence:@"mArray"];
	STAssertNotNil(mArray2, @"array: returned nil");
	STAssertTrue([[mArray2 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mArray3 = [NSMutableArray objectWithPersistence:@"mArray"];
	STAssertNotNil(mArray3, @"array: returned nil");
	STAssertTrue([[mArray3 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
}

- (void) test_11_coArray_autorelease {
	id mArray = [COArray objectWithPersistence:@"mArray"];
	[mArray addObject:@"a"];
	STAssertTrue([[mArray objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	id mArray2 = [COArray objectWithPersistence:@"mArray"];
	STAssertNotNil(mArray2, @"array: returned nil");
	STAssertTrue([[mArray2 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mArray3 = [COArray objectWithPersistence:@"mArray"];
	STAssertNotNil(mArray3, @"array: returned nil");
	STAssertTrue([[mArray3 objectAtIndex:0] isEqualToString:@"a"], @"is not an array");
}


- (void)test_12_Dictionary_autorelease {
	id mDict = [NSMutableDictionary objectWithPersistence:@"mDict"];
	[mDict setObject:@"letter a" forKey:@"a"];
	STAssertTrue([[mDict objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	id mDict2 = [NSMutableDictionary objectWithPersistence:@"mDict"];
	STAssertNotNil(mDict2, @"dict returned nil");
	STAssertTrue([[mDict2 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mDict3 = [NSMutableDictionary objectWithPersistence:@"mDict"];
	STAssertNotNil(mDict3, @"dict returned nil");
	STAssertTrue([[mDict3 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
}

- (void)test_12_coDictionary_autorelease {
	id mDict = [CODictionary objectWithPersistence:@"mDict"];
	[mDict setObject:@"letter a" forKey:@"a"];
	STAssertTrue([[mDict objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	id mDict2 = [CODictionary objectWithPersistence:@"mDict"];
	STAssertNotNil(mDict2, @"dict returned nil");
	STAssertTrue([[mDict2 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mDict3 = [CODictionary objectWithPersistence:@"mDict"];
	STAssertNotNil(mDict3, @"dict returned nil");
	STAssertTrue([[mDict3 objectForKey:@"a"] isEqualToString:@"letter a"], @"the dict didn't store well");
}


- (void)test_13_String_autorelease {
	id mString = [NSMutableString objectWithPersistence:@"mString"];
	[mString setString:@"a string"];
	STAssertTrue([mString isEqualToString:@"a string"], @"wrong string: %@", mString);
	
	id mString2 = [NSMutableString objectWithPersistence:@"mString"];
	STAssertNotNil(mString2, @"string returned nil");
	STAssertTrue([mString2 isEqualToString:@"a string"], @"wrong string: %@", mString2);
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mString3 = [NSMutableString objectWithPersistence:@"mString"];
	STAssertNotNil(mString3, @"string returned nil");
	STAssertTrue([mString3 isEqualToString:@"a string"], @"wrong string: %@", mString3);
}

- (void)test_13_coString_autorelease {
	id mString = [COString objectWithPersistence:@"mString"];
	[mString setString:@"a string"];
	STAssertTrue([mString isEqualToString:@"a string"], @"wrong string: %@", mString);
	
	id mString2 = [COString objectWithPersistence:@"mString"];
	STAssertNotNil(mString2, @"string returned nil");
	STAssertTrue([mString2 isEqualToString:@"a string"], @"wrong string: %@", mString2);
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mString3 = [COString objectWithPersistence:@"mString"];
	STAssertNotNil(mString3, @"string returned nil");
	STAssertTrue([mString3 isEqualToString:@"a string"], @"wrong string: %@", mString3);
}

- (void) test_14_Set_autorelease {
	id mSet = [NSMutableSet objectWithPersistence:@"mSet"];
	[mSet addObject:@"a"];
	STAssertTrue([[mSet member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	id mSet2 = [NSMutableSet objectWithPersistence:@"mSet"];
	STAssertNotNil(mSet2, @"set: returned nil");
	STAssertTrue([[mSet2 member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mSet3 = [NSMutableSet objectWithPersistence:@"mSet"];
	STAssertNotNil(mSet3, @"set: returned nil");
	STAssertTrue([[mSet3 member:@"a"] isEqualToString:@"a"], @"is not a set");
}

- (void) test_14_coSet_autorelease {
	id mSet = [COSet objectWithPersistence:@"mSet"];
	[mSet addObject:@"a"];
	STAssertTrue([[mSet member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	id mSet2 = [COSet objectWithPersistence:@"mSet"];
	STAssertNotNil(mSet2, @"set: returned nil");
	STAssertTrue([[mSet2 member:@"a"] isEqualToString:@"a"], @"is not a set");
	
	[[Cocoadis persistence] saveAll];
	[[Cocoadis persistence] flushCache];
	[NSThread sleepForTimeInterval:1];
	
	id mSet3 = [COSet objectWithPersistence:@"mSet"];
	STAssertNotNil(mSet3, @"set: returned nil");
	STAssertTrue([[mSet3 member:@"a"] isEqualToString:@"a"], @"is not a set");
}

- (void)test_15_from_existing {
	NSMutableArray * array = [[NSMutableArray alloc] initWithObjects:
							  @"a", @"b", @"c", nil];
	[array persistence:@"newArray"];
	STAssertTrue([array count] == 3, @"the array has changed? count should be 3, it is: %d", [array count]);
	
	id rearray = [[NSMutableArray alloc] initWithPersistence:@"newArray"];
	STAssertTrue([rearray isEqualToArray:array], @"the new array is not from persistence");
	
	NSMutableArray * array2 = [[NSMutableArray alloc] initWithObjects:
							   @"c", @"d", nil];
	[array2 persistence:@"newArray"];
	STAssertTrue([array2 count] == 2, @"the array has changed? count should be 2, it is: %d", [array2 count]);
	
	id rearray2 = [[NSMutableArray alloc] initWithPersistence:@"newArray"];
	STAssertTrue([rearray2 isEqualToArray:array2], @"the new array is not from persistence");
}

@end
