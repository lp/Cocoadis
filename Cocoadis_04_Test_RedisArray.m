//
//  Cocoadis_04_Test_Redis
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-25.
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
#import "Cocoadis/Cocoadis.h"
#import "ObjCHiredis/ObjCHiredis.h"

@interface Cocoadis_04_Test_Redis : SenTestCase {
	id redis;
}

@end

@implementation Cocoadis_04_Test_Redis

- (void)setUp {
	redis = [ObjCHiredis redis];
	[redis retain];
}

- (void)tearDown {
	[redis command:@"FLUSHDB"];
	[redis close];
	[redis release];
}

- (void) test_01_ArrayInit {
    id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
    STAssertNotNil(array, @"redis array is nil");
	
	[array addObject:@"aaa"];
	STAssertTrue([array count] == 1, @"array didn't add object");
	
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"a",		@"letter a",
						   @"b",		@"letter b",
						   nil];
	[array addObject:dict];
	STAssertTrue([array count] == 2, @"array didn't add object");
	
	id pDict = [array objectAtIndex:1];
	STAssertTrue([pDict isKindOfClass:[NSDictionary class]], @"returned dict is no dict");
	STAssertTrue([pDict isEqualToDictionary:dict], @"returned dict is not equal to original");
}

- (void)test_02_addObject {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	
	[array addObject:@"aaa"];
	STAssertTrue([array count] == 1, @"array didn't add object");
	
	NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
						   @"a",		@"letter a",
						   @"b",		@"letter b",
						   nil];
	[array addObject:dict];
	STAssertTrue([array count] == 2, @"array didn't add object");
	
	id pDict = [array objectAtIndex:1];
	STAssertTrue([pDict isKindOfClass:[NSDictionary class]], @"returned dict is no dict");
	STAssertTrue([pDict isEqualToDictionary:dict], @"returned dict is not equal to original");
}

- (void)test_03_containsObject {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	
	[array addObject:@"aaa"];
	
	STAssertTrue([array containsObject:@"aaa"], @"array doesn't contain object?");
	STAssertFalse([array containsObject:@"bbb"], @"array contains unknown object?");
}

- (void)test_04_lastObject {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	
	STAssertTrue([[array lastObject] isEqual:@"ccc"], @"array lastObject is not the last");
}

- (void)test_05_objectsAtIndexes {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	
	id result = [array objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
	STAssertTrue([result isKindOfClass:[NSArray class]], @"objectsAtIndex doesn't return an array");
	STAssertTrue([result count] == 2, @"objectsAtIndex didn't return objects for indexes");
	STAssertTrue([[result objectAtIndex:0] isEqual:@"bbb"] && [[result objectAtIndex:1] isEqual:@"ccc"],
				 @"objectsAtIndex didn't return objects for indexes");
}

- (void)test_06_objectEnumerator {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	
	id arrayEnum = [array objectEnumerator];
	id obj; NSUInteger count = 0;
	while (obj = [arrayEnum nextObject]) {
		STAssertTrue([array containsObject:obj], @"objectEnumerator enum the wrong objects");
		count++;
	}
	STAssertTrue(count == 3, @"objectEnumerator didn't enumerate all the arrays items");
	
	arrayEnum = [array reverseObjectEnumerator];
	count = 0;
	while (obj = [arrayEnum nextObject]) {
		STAssertTrue([array containsObject:obj], @"objectEnumerator enum the wrong objects");
		count++;
	}
	STAssertTrue(count == 3, @"objectEnumerator didn't enumerate all the arrays items");
}

- (void)test_07_getObjects {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	
	id *objects;
	NSRange range = NSMakeRange(1, 2);
	objects = malloc(sizeof(id) * range.length);
	
	[array getObjects:objects range:range];
	NSUInteger count = 0;
	for (NSUInteger i = 0; i < range.length; i++) {
		STAssertTrue([objects[i] isEqual:[array objectAtIndex:(i+range.location)]],
					 @"getObjects didn't return the right buffer");
		count++;
	}
	STAssertTrue(count == 2, @"getObject didn't return all the range items");
	free(objects);
}

- (void)test_08_indexOfObject {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	
	STAssertTrue([array indexOfObject:@"bbb"] == 1, @"indexOfObject didn't return the right object");
	STAssertTrue([array indexOfObject:@"ddd"] == NSNotFound, @"indexOfObject didn't return NSNotFound on unfound object");
}

- (void)test_09_indexOfObject {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	[array addObject:@"ddd"];
	
	STAssertTrue([array indexOfObject:@"ccc" inRange:NSMakeRange(1, 2)] == 2,
				 @"indexOfObject:inRange: didn't return the right index");
	STAssertTrue([array indexOfObject:@"ccc" inRange:NSMakeRange(0, 2)] == NSNotFound,
				 @"indexOfObject:inRange: didn't return the right index");
}

- (void)test_10_enumerateObjectsUsingBlock {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	
	NSMutableArray * results = [NSMutableArray arrayWithCapacity:3];
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
		[results addObject:obj];
	}];
	STAssertTrue([array count] == [results count], @"enumerateUsingBlock didn't enumerate through...");
	STAssertTrue([[results objectAtIndex:0] isEqual:[array objectAtIndex:0]] &&
				 [[results objectAtIndex:2] isEqual:[array objectAtIndex:2]],
				 @"enumerated objects are not the ones or in wrong order");
}

- (void)test_11_firstObjectCommonWithArray {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	[array addObject:@"ddd"];
	[array addObject:@"eee"];
	
	id array2 = [[COArray alloc] initAsKey:@"anArray2" persistence:redis];
	[array2 addObject:@"fff"];
	[array2 addObject:@"ggg"];
	[array2 addObject:@"bbb"];
	
	id result = [array firstObjectCommonWithArray:array2];
	STAssertTrue([result isEqual:@"bbb"], @"it should be bbb, it is: %@", [result description]);
	
	id array3 = [NSArray arrayWithObjects:@"fff", @"ggg", @"bbb", nil];
	
	id result2 = [array firstObjectCommonWithArray:array3];
	STAssertTrue([result2 isEqual:@"bbb"], @"it should be bbb, it is: %@", [result2 description]);
	
}

- (void)test_12_isEqualToArray {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	[array addObject:@"ddd"];
	[array addObject:@"eee"];
	
	id array2 = [[COArray alloc] initAsKey:@"anArray2" persistence:redis];
	[array2 addObject:@"aaa"];
	[array2 addObject:@"bbb"];
	[array2 addObject:@"ccc"];
	[array2 addObject:@"ddd"];
	[array2 addObject:@"eee"];
	
	id array3 = [[COArray alloc] initAsKey:@"anArray3" persistence:redis];
	[array3 addObject:@"aaa"];
	[array3 addObject:@"bbb"];
	[array3 addObject:@"zzz"];
	[array3 addObject:@"ddd"];
	[array3 addObject:@"eee"];
	
	id array4 = [NSArray arrayWithObjects:
				  @"aaa", @"bbb", @"ccc", @"ddd", @"eee",nil];
				 
	
	id array5 = [NSArray arrayWithObjects:
				  @"aaa", @"bbb", @"ccc", @"ttt", @"eee",nil];
	
	STAssertTrue([array isEqualToArray:array2], @"arrays should be equal");
	STAssertFalse([array isEqualToArray:array3], @"arrays should not be equal");
	STAssertTrue([array isEqualToArray:array4], @"arrays should be equal");
	STAssertFalse([array isEqualToArray:array5], @"arrays should not be equal");
}

- (void)test_13_initWithArray {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis];
	[array addObject:@"aaa"];
	[array addObject:@"bbb"];
	[array addObject:@"ccc"];
	[array addObject:@"ddd"];
	[array addObject:@"eee"];
	
	id array2 = [NSArray arrayWithObjects:
				 @"aaa", @"bbb", @"ccc", @"ddd",nil];
	
	id array3 = [[COArray alloc] initWithArray:array asKey:@"anArray3" persistence:redis];
	STAssertNotNil(array3, @"array wasn't initialised with array, got nil");
	STAssertTrue([array3 count] == 5, @"new array size is wrong");
	STAssertTrue([array isEqualToArray:array3], @"new array doesn't include all the old array menbers");
	
	id array4 = [COArray arrayWithArray:array2 asKey:@"anArray4" persistence:redis];
	STAssertNotNil(array4, @"array wasn't initialised with array, got nil");
	STAssertTrue([array4 count] == 4, @"new array size is wrong");
	STAssertTrue([array4 isEqualToArray:array2], @"new array doesn't include all the old array menbers");
}

- (void)test_14_initWithObjects {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis withObjects:@"aaa", @"bbb", @"ccc", nil];
	STAssertNotNil(array, @"initWithObjects didin't do...");
	STAssertTrue([array count] == 3, @"created array has wrong length");
	STAssertTrue([array indexOfObject:@"aaa"] == 0 && [array indexOfObject:@"ccc"] == 2,
				 @"array isn't filled with objects in the right order");
	
	
}

- (void)test_15_arrayByAddingObject {
	id array = [[COArray alloc] initAsKey:@"anArray" persistence:redis withObjects:@"aaa", @"bbb", @"ccc", nil];
	id array2 = [array arrayByAddingObject:@"ddd" asKey:@"anArray2"];
	STAssertNotNil(array2, @"newly array is nil");
	STAssertTrue([array2 count] == 4, @"new array is of wrong length");
	STAssertTrue([[array2 objectAtIndex:0] isEqual:@"aaa"] && [[array2 objectAtIndex:3] isEqual:@"ddd"],
				 @"new array does not contain the right objects");
}

@end
