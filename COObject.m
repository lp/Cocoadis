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
	[persistence release];
	[super dealloc];
}

-(id)initAsKey:(NSString *)key
{
	return [self initAsKey:key persistence:nil];
}

-(id)initAsKey:(NSString *)key persistence:(id)pers
{
	self = [super init];
	if (self) {
		name = key;
		[name retain];
		if (pers) {
			persistence = pers;
			[persistence retain];
		} else {
			persistence = [Cocoadis persistence];
			[persistence retain];
		}

		if ([self isMemberOfClass:[COArray class]]) {
			obj = [persistence persist:[[NSMutableArray alloc] init] key:key];
		} else if ([self isMemberOfClass:[CODictionary class]]) {
			obj = [persistence persist:[[NSMutableDictionary alloc] init] key:key];
		} else if ([self isMemberOfClass:[COString class]]) {
			obj = [persistence persist:[[NSMutableString alloc] init] key:key];
		} else if ([self isMemberOfClass:[COSet class]]) {
			obj = [persistence persist:[[NSMutableSet alloc] init] key:key];
		} else {
			[self doesNotRecognizeSelector:@selector(initAsKey:persistence:)];
			return nil;
		}
	}
	return self;
}

-(void)persist
{
	[persistence saveMember:obj];
}

// forwarding to obj

- (void)forwardInvocation:(NSInvocation *)invocation {
	[invocation invokeWithTarget:obj];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	if (aSelector == @selector(persist) ||
		aSelector == @selector(initAsKey:)
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
+(id)arrayAsKey:(NSString*)key { return [self objectAsKey:key]; }
@end
@implementation CODictionary
+(id)dictionaryAsKey:(NSString*)key { return [self objectAsKey:key]; }
@end
@implementation COString
+(id)stringAsKey:(NSString*)key { return [self objectAsKey:key]; }
@end
@implementation COSet
+(id)setAsKey:(NSString*)key { return [self objectAsKey:key]; }
@end