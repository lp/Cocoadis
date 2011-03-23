//
//  COHelper_OSX.m
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-23.
//  Copyright 2011 Modul. All rights reserved.
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
