//
//  COHelper_OSX.m
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


#import "COHelper_OSX.h"

@implementation COHelper

+(id)dbCache
{
	if ([[NSGarbageCollector defaultCollector] isEnabled]) {
		return [[NSMapTable alloc] initWithKeyOptions:NSMapTableZeroingWeakMemory
										valueOptions:NSMapTableZeroingWeakMemory
											capacity:100];
	} else {
		return [[NSMutableDictionary alloc] init];
	}
}

+(BOOL)gc
{
	return [[NSGarbageCollector defaultCollector] isEnabled];
}

+(void)runGC
{
	[[NSGarbageCollector defaultCollector] collectExhaustively];
}

@end

@implementation NSMapTable (Cocoadis)
-(NSString*)keyForObject:(id)obj
{	
	NSDictionary * dictRep = [self dictionaryRepresentation];
	return [[dictRep allKeys] objectAtIndex:[[dictRep allValues] indexOfObject:obj]];
}

@end
