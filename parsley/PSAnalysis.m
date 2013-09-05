//
//  PSAnalysis.m
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import "PSAnalysis.h"

static NSString* const PSComponentSeparator = @"::";
static NSCharacterSet *PSPropertySeparators;

@implementation PSAnalysisProperty

@end


@implementation PSAnalysisComponent

@end


@implementation PSAnalysis {
    NSDictionary *definitionDict;
}

+ (void)initialize {
    PSPropertySeparators = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
}

- (PSAnalysis *) initWithDefinition:(NSDictionary *)definition transducerData:(NSString *)tData {
    self = [super init];
    definitionDict = definition;
    
    // break out the string into its consituent parts
    NSArray *componentTokens = [tData componentsSeparatedByString:@"::"];
    for (NSString *component in componentTokens) {
        NSLog(@"%@\n", [component componentsSeparatedByCharactersInSet: PSPropertySeparators]);
    }
    return self;
}

@end
