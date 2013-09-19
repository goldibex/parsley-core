//
//  PSAnalyzer.h
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSAnalysis.h"
#import "fst.h"

@interface PSAnalyzer : NSObject

@property (readonly) NSDictionary* definition;

-(PSAnalyzer *)initWithLemmatizerURL:(NSURL *)lemmaURL
                            morphURL:(NSURL *)morphURL
                       definitionURL:(NSURL *)definitionURL;

- (NSDictionary *) analyze: (NSString *)form;


@end
