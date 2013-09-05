//
//  PSAnalysisTest.m
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import "PSAnalysisTest.h"

@implementation PSAnalysisTest {
    PSAnalysis* it;
}

- (void) setUp {
    NSDictionary* dictionary = 
    NSString* sampleTransducerOutput = @"laud<are_vb>::<conj1>::at<pres><ind><act><3rd><sg><conj1>";
    it = [[PSAnalysis alloc] initWithDefinition:[NSDictionary dictionary]
                                            transducerData:sampleTransducerOutput];
}

- (void) tearDown {
    
}

@end
