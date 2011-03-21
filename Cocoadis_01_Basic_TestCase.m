//
//  Cocoadis_01_Basic_TestCase.m
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
#endif

#ifndef IOS
#import "Cocoadis/Cocoadis.h"
#endif

@interface Cocoadis_01_Basic_TestCase : SenTestCase {
	
}

@end

@implementation Cocoadis_01_Basic_TestCase

- (void)setUp {
	[[Cocoadis persistence] setBasePath:NSTemporaryDirectory()];
}

- (void)tearDown {
	[[Cocoadis persistence] flushCache];
	[[Cocoadis persistence] clearPersistence];
}

- (void) test_01_Math {
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );    
}

- (void)test_02_init_array {
	NSMutableArray * array = [[NSMutableArray alloc] initWithPersistence:@"mArray"];
	STAssertNotNil(array, @"array: returned nil");
	STAssertTrue([array isKindOfClass:[NSMutableArray class]],
				 @"initialized array is not of NSMutableArray class, it is: %@",
				 [[array class] description]);
	[array release];
}

- (void)test_03_init_dictionary {
	id dict = [[NSMutableDictionary alloc] initWithPersistence:@"mDict"];
	STAssertNotNil(dict, @"dictionary returned nil");
	STAssertTrue([dict isKindOfClass:[NSMutableDictionary class]],
				 @"initialized dictionary is not of NSMutableDictionary class, it is: %@",
				 [[dict class] description]);
	[dict release];
}

- (void)test_04_init_string {
	id string = [[NSMutableString alloc] initWithPersistence:@"mString"];
	STAssertNotNil(string, @"string returned nil");
	STAssertTrue([string isKindOfClass:[NSMutableString class]],
				 @"initialized string is not of NSMutableString class, it is: %@",
				 [[string class] description]);
	[string release];
}

- (void)test_05_init_set {
	id set = [[NSMutableSet alloc] initWithPersistence:@"mSet"];
	STAssertNotNil(set, @"string returned nil");
	STAssertTrue([set isKindOfClass:[NSMutableSet class]],
				 @"initialized set is not of NSMutableSet class, it is: %@",
				 [[set class] description]);
	[set release];
}

@end
