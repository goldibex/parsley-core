//
//  PSAnalyzerTest.m
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import "PSAnalyzerTest.h"
#import <Foundation/Foundation.h>
@implementation PSAnalyzerTest

-(void) testSanity {
    NSURL* rsrcURL = [[NSBundle bundleForClass:[PSAnalyzer class]] resourceURL];
    PSAnalyzer* analyzer = [[PSAnalyzer alloc] initWithLemmatizerURL:rsrcURL
                                     morphURL:rsrcURL
                                definitionURL:[rsrcURL URLByAppendingPathComponent:@"grammar.plist"]
     ];
    STAssertNotNil(analyzer, @"Analyzer should exist after instantiation");
    [analyzer analyze:@"malum"];
}

@end
