//
//  NSObject+Cocoadis.m
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-21.
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

#import "NSObject+Cocoadis.h"
#import "Cocoadis.h"
#import "COObject.h"

@implementation NSObject (Cocoadis)

-(id)initAsKey:(NSString*)key
{
	self = [self init];
	if (self) {
		if ([self isKindOfClass:[NSMutableArray class]] ||
			[self isKindOfClass:[NSMutableDictionary class]] ||
			[self isKindOfClass:[NSMutableString class]] ||
			[self isKindOfClass:[NSMutableSet class]]
			) {
			return [[Cocoadis persistence] persist:self key:key];
		} else {
			[self doesNotRecognizeSelector:@selector(persist)];
		}
	}
	return nil;
}

+(id)objectAsKey:(NSString*)key
{
	id obj = [[self alloc] initAsKey:key];
	[obj autorelease];
	return obj;
}

-(void)persist
{
	if (([self isKindOfClass:[NSMutableArray class]] ||
		[self isKindOfClass:[NSMutableDictionary class]] ||
		[self isKindOfClass:[NSMutableString class]] ||
		[self isKindOfClass:[NSMutableSet class]])
		) {
		[[Cocoadis persistence] saveMember:self];
	} else {
		[self doesNotRecognizeSelector:@selector(persist)];
	}
}

-(id)persistence:(NSString*)key
{
	if (([self isKindOfClass:[NSMutableArray class]] ||
		 [self isKindOfClass:[NSMutableDictionary class]] ||
		 [self isKindOfClass:[NSMutableString class]] ||
		 [self isKindOfClass:[NSMutableSet class]])
		) {
		return [[Cocoadis persistence] persist:self key:key];
	} else {
		[self doesNotRecognizeSelector:@selector(persistence:)];
	}
	return nil;
}

-(BOOL)isEmpty
{
	if ([self isKindOfClass:[NSString class]]) {
		if ([self performSelector:@selector(length)] == 0) {
			return YES;
		}
	} else if ([self respondsToSelector:@selector(count)]) {
		if ([self performSelector:@selector(count)] == 0) {
			return YES;
		}
	} else {
		[self doesNotRecognizeSelector:@selector(isEmpty)];
	}
	return NO;
}

@end

@implementation NSMutableDictionary (Cocoadis)

-(NSString*)keyForObject:(id)obj
{	
	return [[self allKeys] objectAtIndex:[[self allValues] indexOfObject:obj]];
}

-(BOOL)containsObject:(id)obj
{
	if ([[self allValues] indexOfObject:obj]) {
		return YES;
	} else {
		return NO;
	}
}

@end



