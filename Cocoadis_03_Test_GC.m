//
//  Cocoadis_03_Test_GC.m
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-23.
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

@interface Cocoadis_03_Test_GC : SenTestCase {
	
}

@end

@implementation Cocoadis_03_Test_GC

- (void)setUp {
	[[Cocoadis persistence] setBasePath:NSTemporaryDirectory()];
}

- (void)tearDown {
	
}

- (void)test_01_buildBase {
	if ([COHelper gc]) {
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 0, @"the db cache doesn't start clean");
		
		id mArray = [[COArray alloc] initAsKey:@"mArrayGC"];
		id mDict = [[CODictionary alloc] initAsKey:@"mDict"];
		id mString = [[COString alloc] initAsKey:@"mString"];
		id mSet = [[COSet alloc] initAsKey:@"mSet"];
		
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 4, @"the db cache didn't keep the objects");
		
		[mArray addObject:@"gc"];
		[mDict setObject:@"letter a" forKey:@"a"];
		[mString setString:@"a string"];
		[mSet addObject:@"a"];
	}
}

- (void)test_02_bad_persist {
	if ([COHelper gc]) {
		[[Cocoadis persistence] cleanCache];
		[NSThread sleepForTimeInterval:5];
		id mArray2 = [[COArray alloc] initAsKey:@"mArrayGC"];
		STAssertFalse([mArray2 containsObject:@"gc"], @"cache was not clean object");
	}
}

- (void)test_03_buildBase {
	if ([COHelper gc]) {
		[[Cocoadis persistence] flushCache];
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 0, @"the db cache doesn't start clean");
		
		id mArray = [[COArray alloc] initAsKey:@"mArrayGC"];
		id mDict = [[CODictionary alloc] initAsKey:@"mDict"];
		id mString = [[COString alloc] initAsKey:@"mString"];
		id mSet = [[COSet alloc] initAsKey:@"mSet"];
		
		STAssertTrue([[[Cocoadis persistence] dbCache] count] == 4, @"the db cache didn't keep the objects");
		
		[mArray addObject:@"gc"];
		[mDict setObject:@"letter a" forKey:@"a"];
		[mString setString:@"a string"];
		[mSet addObject:@"a"];
		[[Cocoadis persistence] saveAll];
		[NSThread sleepForTimeInterval:1];
	}
}

- (void)test_04_persist {
	if ([COHelper gc]) {
		[[Cocoadis persistence] cleanCache];
		[NSThread sleepForTimeInterval:5];
		id mArray2 = [[COArray alloc] initAsKey:@"mArrayGC"];
		STAssertTrue([mArray2 containsObject:@"gc"], @"saveToPersistence didn't save object");
	}
}

- (void)test_99_close {
	[[Cocoadis persistence] flushCache];
	[[Cocoadis persistence] clearPersistence];
}

@end
