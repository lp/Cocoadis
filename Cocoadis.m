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

#ifdef IOS
#import "COHelper_iOS.h"
#endif

#ifndef IOS
#import "COHelper_OSX.h"
#endif

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
@synthesize cleanIter;

+ (id)persistence
{
	return CDISPersistence ?: [[[self alloc] initGlobal] autorelease];
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		dbCache = [COHelper dbCache];
		cleanNotif = [NSNotification notificationWithName:@"cleanNotif" object:nil];
		[cleanNotif retain];
		cleanIter = 0;
	}	
	return self;
}

- (id)initWithPath:(NSString*)path
{
	self = [self init];
	if (self) {
		basePath = path;
		[basePath retain];
	}
	return self;
}

- (id)initGlobal
{
	if(CDISPersistence)
	{
		[self release];
	}
	else if(self = CDISPersistence = [[self init] retain])
	{
		basePath = @"/tmp";
		[basePath retain];
	}
	return CDISPersistence;
}

- (void)dealloc {
	[self saveAll];
	[dbCache release];
	[basePath release];
	[super dealloc];
}

-(NSDictionary*)dbCache
{
	if ([dbCache isKindOfClass:[NSMutableDictionary class]]) {
		return dbCache;
	} else {
		return [dbCache dictionaryRepresentation];
	}
}

- (id)persist:(id)obj key:(NSString*)key
{
	id persisted = [dbCache objectForKey:key];
	if (persisted && [persisted isKindOfClass:[obj class]]) {
		[obj release];
		return [persisted retain];
	} else {
		NSString * filePath = [self filePathWithName:key];
		if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
			NSArray * loadArray = [[NSArray alloc] initWithContentsOfFile:filePath];
			if (loadArray) {
				if ([[loadArray objectAtIndex:0] isEqualToString:@"__NSArrayM"] ||
					[[loadArray objectAtIndex:0] isEqualToString:@"NSCFArray"] ||
					[[loadArray objectAtIndex:0] isEqualToString:@"__NSArrayI"]) {
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
	return [self persistExisting:obj key:key];
}

- (id)persistExisting:(id)obj key:(NSString*)key
{
	if (obj) {
		[dbCache setObject:obj forKey:key];
		return obj;
	}
	return nil;
}

- (void)saveAll
{	
	NSEnumerator * dbObjs = [dbCache objectEnumerator];
	id obj;
	while (obj = [dbObjs nextObject]) {
		[self saveMember:obj];
	}
}

- (void)saveMember:(id)obj
{
	NSString * name = [dbCache keyForObject:obj];
	NSString * filePath = [self filePathWithName:name];
	[NSThread detachNewThreadSelector:@selector(persistMember:) toTarget:self withObject:
	 [NSArray arrayWithObjects:filePath,[obj copy],nil]];
}

- (void)flushCache
{
	[dbCache release];
	dbCache = [COHelper dbCache];
}

- (void)cleanCache {
	if ([COHelper gc]) {
		[COHelper runGC];
	} else {
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
	}
	cleanIter++;
}

- (void)clearPersistence
{
	[[NSFileManager defaultManager] removeItemAtPath:[self persistencePath] error:NULL];
}

- (void)startAutoClean
{	
	if (! [COHelper gc]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanNotif:) name:@"cleanNotif" object:nil];
		[[NSNotificationQueue defaultQueue] enqueueNotification:cleanNotif postingStyle:NSPostNow];
	}
}

- (void)stopAutoClean
{
	if (! [COHelper gc]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"cleanNotif" object:nil];
	}
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
	if ((! [[NSFileManager defaultManager] fileExistsAtPath:[self persistencePath] isDirectory:&dir]) || (! dir) ) {
		[[NSFileManager defaultManager] createDirectoryAtPath:[self persistencePath] withIntermediateDirectories:YES attributes:nil error:NULL];
	}
}

- (void)persistMember:(id)member
{
	NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
	
	[self mkPersistPath];
	
	NSString * filePath = [member objectAtIndex:0];
	id saveObj = [member objectAtIndex:1];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
	}
	
	NSString * className = [[saveObj class] description];
	if ([saveObj isKindOfClass:[NSMutableSet class]]) {
		saveObj = [saveObj allObjects];
	}
	NSArray * saveArray = [[NSArray alloc] initWithObjects:
						   className,
						   saveObj, nil];
	
	[saveArray writeToFile:filePath atomically:YES];
	[saveArray release];
	[pool drain];
}

@end
