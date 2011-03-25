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

@end
