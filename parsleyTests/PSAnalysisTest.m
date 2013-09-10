//
//  PSAnalysisTest.m
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import "PSAnalysisTest.h"

@implementation PSAnalysisTest {
    NSDictionary *definition;
    NSString *sampleTransducerOutput, *sampleOtherTransducerOutput;
    PSAnalysis* it;
}

- (void) setUp {
    NSURL *dictionaryURL = [[NSBundle bundleForClass:[PSAnalysisTest class]] URLForResource:@"grammar"
                                                                              withExtension:@"plist"];
    definition = [NSDictionary dictionaryWithContentsOfURL:dictionaryURL];
    STAssertNotNil(definition, @"Definition dictionary from test bundle plist should exist");
    sampleTransducerOutput = @"laud<are_vb>::<conj1>::a^t<pres><ind><act><3rd><sg><conj1>";
    sampleOtherTransducerOutput = @"fi_l<masc><ius_i>::io_rum<gen><pl><ius_i>";
    
    it = [[PSAnalysis alloc] initWithDefinition:definition
                                 transducerData:sampleTransducerOutput];
}

- (void) testCanonicalForm {
    STAssertEqualObjects(it.canonicalForm,
                         @"lauda^t",
                         @"Canonical form is assembled from parse components");
}

- (void) testSummary {
    STAssertEqualObjects(it.summary,
                         @"3rd sg pres ind act",
                         @"Short parse comes directly from analysis string");
}

- (void) testStemType {
    STAssertEqualObjects(it.stemType,
                         @"conj1",
                         @"Stem type comes directly from analysis string");
}

- (void) testStemGroup {
    STAssertEqualObjects(it.stemGroup,
                         @"1st conj. verb",
                         @"Stem group is retrieved from definition dictionary");
}

- (void) testComponents {
    STAssertTrue(it.components.count == 3,
                 @"There are three components in the sample output");
    
    for (NSObject* obj in it.components) {
        STAssertTrue([obj isKindOfClass:[PSAnalysisComponent class]],
                     @"components are all PSAnalysisComponents");
    }
}

@end
