//
//  Cocoadis.h
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

#import <Foundation/Foundation.h>
#import "NSObject+Cocoadis.h"

@interface Cocoadis : NSObject {
	NSString * basePath;
	
	NSMutableDictionary * dbCache;
	
	NSNotification * cleanNotif;
	NSUInteger cleanIter;
}

@property(retain, readwrite) NSString * basePath;
@property(retain, readonly) NSMutableDictionary * dbCache;
@property(assign, readonly) NSUInteger cleanIter;

+ (id)persistence;

// db management methods
- (id)persist:(id)obj key:(NSString*)key;
- (void)saveAll;
- (void)saveMember:(id)member;
- (void)flushCache;
- (void)cleanCache;
- (void)clearPersistence;

// auto management
- (void)startAutoClean;
- (void)stopAutoClean;
- (void)cleanNotif:(NSNotification*)nc;

@end
