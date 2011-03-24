//
//  COHelper_OSX.h
//  Cocoadis
//
//  Created by Louis-Philippe on 11-03-23.
//  Copyright 2011 Modul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COHelper : NSObject {

}

+(id)dbCache;
+(BOOL)gc;
+(void)runGC;

@end

@interface NSMapTable (Cocoadis)

-(NSString*)keyForObject:(id)obj;

@end
