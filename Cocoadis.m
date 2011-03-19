//
//  Cocoadis.m
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

#import "Cocoadis.h"
#import "NSMutableArray+Cocoadis.h"

static Cocoadis * CDISPersistence;

// Private methods declaration
@interface Cocoadis ()

- (NSString*)filePathWithName:(NSString*)name;
- (NSString*)persistencePath;
- (void)mkPersistPath;
- (void)persistMember:(id)member;

@end

@implementation Cocoadis
@synthesize basePath;
@synthesize dbCache;
@synthesize cleanIter;

+ (id)persistence
{
	return CDISPersistence ?: [[self new] autorelease];
}

- (id)init
{
	if(CDISPersistence)
	{
		[self release];
	}
	else if(self = CDISPersistence = [[super init] retain])
	{
		fm = [[NSFileManager alloc] init];
		dbCache = [[NSMutableDictionary alloc] init];
		basePath = @"/tmp";
		[basePath retain];
		cleanNotif = [NSNotification notificationWithName:@"cleanNotif" object:nil];
		[cleanNotif retain];
		cleanIter = 0;
	}
	return CDISPersistence;
}

- (void)dealloc {
	[self saveAll];
	[fm release];
	[dbCache release];
	[basePath release];
	[super dealloc];
}

- (id)persist:(id)obj key:(NSString*)key
{
	id persisted = [dbCache objectForKey:key];
	if (persisted && [persisted isKindOfClass:[obj class]]) {
		if ([obj isKindOfClass:[NSMutableArray class]]) {
			[obj addObjectsFromArray:persisted];
		} else if ([obj isKindOfClass:[NSMutableDictionary class]]) {
			[obj addEntriesFromDictionary:persisted];
		} else if ([obj isKindOfClass:[NSMutableString class]]) {
			[obj setString:persisted];
		} else if ([obj isKindOfClass:[NSMutableSet class]]) {
			[obj unionSet:persisted];
		}
	} else {
		NSString * filePath = [self filePathWithName:key];
		if ([fm fileExistsAtPath:filePath]) {
			NSArray * loadArray = [[NSArray alloc] initWithContentsOfFile:filePath];
			if (loadArray) {
				if ([[loadArray objectAtIndex:0] isEqualToString:@"__NSArrayM"] ||
					[[loadArray objectAtIndex:0] isEqualToString:@"NSCFArray"]) {
					persisted = [[NSArray alloc] initWithArray:[loadArray objectAtIndex:1]];
					if ([obj isKindOfClass:[NSMutableArray class]]) {
						[obj addObjectsFromArray:persisted];
					}
					[persisted release];
				} else if ([[loadArray objectAtIndex:0] isEqualToString:@"__NSCFDictionary"] ||
						   [[loadArray objectAtIndex:0] isEqualToString:@"NSCFDictionary"]) {
					persisted = [[NSDictionary alloc] initWithDictionary:[loadArray objectAtIndex:1]];
					if ([obj isKindOfClass:[NSMutableDictionary class]]) {
						[obj addEntriesFromDictionary:persisted];
					}
					[persisted release];
				} else if ([[loadArray objectAtIndex:0] isEqualToString:@"NSCFString"]) {
					persisted = [[NSString alloc] initWithString:[loadArray objectAtIndex:1]];
					if ([obj isKindOfClass:[NSMutableString class]]) {
						[obj setString:persisted];
					}
					[persisted release];
				} else if ([[loadArray objectAtIndex:0] isEqualToString:@"__NSCFSet"] ||
						   [[loadArray objectAtIndex:0] isEqualToString:@"NSCFSet"]
						   ) {
					persisted = [[NSSet alloc] initWithArray:[loadArray objectAtIndex:1]];
					if ([obj isKindOfClass:[NSMutableSet class]]) {
						[obj unionSet:persisted];
					}
					[persisted release];
				}
			}
			[loadArray release];
		}
	}
	
	if (obj) {
		[dbCache setObject:obj forKey:key];
		return obj;
	}
	return nil;
}

- (void)saveAll
{
	[self mkPersistPath];
	
	NSEnumerator * dbNames = [dbCache keyEnumerator];
	NSString * name;
	while (name = [dbNames nextObject]) {
		id saveObj = [dbCache objectForKey:name];
		
		NSString * className = [[saveObj class] description];
		if ([saveObj isKindOfClass:[NSMutableSet class]]) {
			saveObj = [saveObj allObjects];
		}
		NSArray * saveArray = [[NSArray alloc] initWithObjects:
							   className,
							   [saveObj copy], nil];
		NSString * filePath = [self filePathWithName:name];
		if ([fm fileExistsAtPath:filePath]) {
			[fm removeItemAtPath:filePath error:NULL];
		}
		[NSThread detachNewThreadSelector:@selector(persistMember:) toTarget:self withObject:[NSArray arrayWithObjects:filePath,saveArray,nil]];
		[saveArray release];
	}
}

- (void)flushCache
{
	[dbCache release];
	dbCache = [[NSMutableDictionary alloc] init];
}

- (void)cleanCache {
	if ([dbCache count] > 0) {
		NSMutableArray * dirtyKeys = [[NSMutableArray alloc] init];
		for (NSString * name in dbCache) {
			id cacheObj = [dbCache objectForKey:name];
			if ([cacheObj retainCount] == 1) {
				[dirtyKeys addObject:name];
			}
		}
		
		if ([dirtyKeys count] > 0) {
			for (NSString * name in dirtyKeys) {
				[dbCache removeObjectForKey:name];
			}
		}
		[dirtyKeys release];
	}
	cleanIter++;
}

- (void)clearPersistence
{
	[fm removeItemAtPath:[self persistencePath] error:NULL];
}

- (void)startAutoClean
{	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanNotif:) name:@"cleanNotif" object:nil];
	[[NSNotificationQueue defaultQueue] enqueueNotification:cleanNotif postingStyle:NSPostNow];
}

- (void)stopAutoClean
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"cleanNotif" object:nil];
}

- (void)cleanNotif:(NSNotification *)nc
{
	[self cleanCache];
	[[NSNotificationQueue defaultQueue] enqueueNotification:cleanNotif postingStyle:NSPostWhenIdle];
}

// Private methods implementations

- (NSString*)filePathWithName:(NSString*)name
{
	return [[[self persistencePath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"cdis"];
}

- (NSString*)persistencePath
{
	return [basePath stringByAppendingPathComponent:@"cocoadis_db"];
}

- (void)mkPersistPath
{
	BOOL dir = NO;
	if ((! [fm fileExistsAtPath:[self persistencePath] isDirectory:&dir]) || (! dir) ) {
		[fm createDirectoryAtPath:[self persistencePath] withIntermediateDirectories:YES attributes:nil error:NULL];
	}
}

- (void)persistMember:(id)member
{
	NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
	[[member objectAtIndex:1] writeToFile:[member objectAtIndex:0] atomically:YES];
	[pool drain];
}

@end
