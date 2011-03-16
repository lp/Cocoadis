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

@end

@implementation Cocoadis
@synthesize basePath;

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
		return persisted;
	}
	
	NSString * filePath = [self filePathWithName:key];
	if ([fm fileExistsAtPath:filePath]) {
		NSArray * loadArray = [[NSArray alloc] initWithContentsOfFile:filePath];
		if (loadArray) {
			if ([[loadArray objectAtIndex:0] isEqualToString:@"NSCFArray"]) {
				NSArray * persisted = [[NSArray alloc] initWithArray:[loadArray objectAtIndex:1]];
				if ([obj isKindOfClass:[persisted class]]) {
					[obj addObjectsFromArray:persisted];
				}
				[persisted release];
			} else if ([[loadArray objectAtIndex:0] isEqualToString:@"NSCFDictionary"]) {
				NSDictionary * persisted = [[NSDictionary alloc] initWithDictionary:[loadArray objectAtIndex:1]];
				if ([obj isKindOfClass:[persisted class]]) {
					[obj addEntriesFromDictionary:persisted];
				}
				[persisted release];
			} else if ([[loadArray objectAtIndex:0] isEqualToString:@"NSCFString"]) {
				NSString * persisted = [[NSString alloc] initWithString:[loadArray objectAtIndex:1]];
				if ([obj isKindOfClass:[persisted class]]) {
					[obj setString:persisted];
				}
				[persisted release];
			} else if ([[loadArray objectAtIndex:0] isEqualToString:@"NSCFSet"]) {
				NSSet * persisted = [[NSSet alloc] initWithSet:[loadArray objectAtIndex:1]];
				if ([obj isKindOfClass:[persisted class]]) {
					[obj unionSet:persisted];
				}
				[persisted release];
			}
		}
		[loadArray release];
		
		// needs to add conditionals for other classes
	}
	
	if (obj) { [dbCache setObject:obj forKey:key]; return obj; }
	return nil;
}

- (void)saveAll
{
	[self mkPersistPath];
	
	NSEnumerator * dbNames = [dbCache keyEnumerator];
	NSString * name;
	while (name = [dbNames nextObject]) {
		id saveObj = [dbCache objectForKey:name];
		NSArray * saveArray = [[NSArray alloc] initWithObjects:
							   [[saveObj class] description],
							   saveObj, nil];
		NSString * filePath = [self filePathWithName:name];
		if ([fm fileExistsAtPath:filePath]) {
			[fm removeItemAtPath:filePath error:NULL];
		}
		[saveArray writeToFile:filePath atomically:YES];
		[saveArray release];
	}
}

- (void)flushCache
{
	[dbCache release];
	dbCache = [[NSMutableDictionary alloc] init];
}

- (void)clearPersistence
{
	[fm removeItemAtPath:[self persistencePath] error:NULL];
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

@end
