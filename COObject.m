//
//  COObject.m
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


#import "COObject.h"
#import "Cocoadis.h"

@implementation COObject
@synthesize obj;
@synthesize name;

- (void)dealloc {
	[obj release];
	[name release];
	[super dealloc];
}


+(id)objectWithPersistence:(NSString*)key
{
	id array = [[self alloc] initWithPersistence:key];
	[array autorelease];
	return array;
}

-(id)initWithPersistence:(NSString *)key
{
	self = [super init];
	if (self) {
		self.name = key;
		if ([self isMemberOfClass:[COArray class]]) {
			obj = [[Cocoadis persistence] persist:[[NSMutableArray alloc] init] key:key];
		} else if ([self isMemberOfClass:[CODictionary class]]) {
			obj = [[Cocoadis persistence] persist:[[NSMutableDictionary alloc] init] key:key];
		} else if ([self isMemberOfClass:[COString class]]) {
			obj = [[Cocoadis persistence] persist:[[NSMutableString alloc] init] key:key];
		} else if ([self isMemberOfClass:[COSet class]]) {
			obj = [[Cocoadis persistence] persist:[[NSMutableSet alloc] init] key:key];
		}
	}
	return self;
}

-(void)persist
{
	[[Cocoadis persistence] saveMember:name];
}

// forwarding to obj

- (void)forwardInvocation:(NSInvocation *)invocation {
	[invocation invokeWithTarget:obj];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	if (aSelector == @selector(persist) ||
		aSelector == @selector(initWithPersistence:)
		) {
		return YES;
	}
    return [obj respondsToSelector:aSelector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
		signature = [obj methodSignatureForSelector:selector];
    }
    return signature;
}


@end

@implementation COArray
@end
@implementation CODictionary
@end
@implementation COString
@end
@implementation COSet
@end