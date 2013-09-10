//
//  PSAnalyzer.m
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import "PSAnalyzer.h"

#import <stdio.h>
#define PS_ANALYZER_MAX_RESULT_LEN 512

@implementation PSAnalyzer {
    fst_t morph_fst;
    fst_t lemma_fst;
}

bool
loadFST(fst_t* fst, NSURL* sourceURL, NSString* name) {
    if (![sourceURL isFileURL]) {
        return false;
    }
    NSURL* edgesURL = [sourceURL URLByAppendingPathComponent:
                       [name stringByAppendingPathExtension:@"ate"]
                       ];
    NSURL *symbolsURL = [sourceURL URLByAppendingPathComponent:
                         [name stringByAppendingPathExtension:@"ats"]
                         ];

    const char* edges_path = [edgesURL.path cStringUsingEncoding:NSUTF8StringEncoding];
    const char* symbols_path = [symbolsURL.path cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE* ats_file = fopen(symbols_path, "r");
    FILE* ate_file = fopen(edges_path, "r");
    
    if (ats_file == NULL || ate_file == NULL) {
        return false;
    }
    
    int result = fst_load_att(ats_file, ate_file, fst);
    
    fclose(ats_file);
    fclose(ate_file);
    
    return (result == 0);
}

-(PSAnalyzer *)initWithLemmatizerURL:(NSURL *)lemmaURL
                            morphURL:(NSURL *)morphURL
                       definitionURL:(NSURL *)definitionURL {
    self = [super init];
    
    // all 3 URLs must be file URLs
    if (![lemmaURL isFileURL] || ![morphURL isFileURL] || ![definitionURL isFileURL]) {
        self = nil;
        return self;
    }

    if (!loadFST(&lemma_fst, lemmaURL, @"lemmas") || !loadFST(&morph_fst, morphURL, @"morphology")) {
        self = nil;
        return self;
    }
    
    _definition = [NSDictionary dictionaryWithContentsOfURL:definitionURL]; if (_definition == nil) {
        self = nil;
    }
    
    return self;
}

- (NSDictionary *)analyze:(NSString *)form {
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    NSMutableArray* arr;
    char output[PS_ANALYZER_MAX_RESULT_LEN],
    stem_part[PS_ANALYZER_MAX_RESULT_LEN],
    lemma[PS_ANALYZER_MAX_RESULT_LEN];
    memset(output, 0, PS_ANALYZER_MAX_RESULT_LEN);
    memset(stem_part, 0, PS_ANALYZER_MAX_RESULT_LEN);
    memset(lemma, 0, PS_ANALYZER_MAX_RESULT_LEN);
    
    fst_iterator_t morph_iter, lemma_iter;
    fst_new_iterator(&morph_fst, &morph_iter);
    fst_new_iterator(&lemma_fst, &lemma_iter);
    fst_iterator_reset(&morph_iter, [form cStringUsingEncoding:NSASCIIStringEncoding]);
    while (fst_iterate(&morph_iter)) {
        fst_iterator_out(&morph_iter, output, PS_ANALYZER_MAX_RESULT_LEN);
        // get the lemma from the stem part
        strcpy(stem_part, output);
        *strstr(stem_part, "::") = '\0';
        fst_iterator_reset(&lemma_iter, stem_part);
        fst_iterate(&lemma_iter);
        fst_iterator_out(&lemma_iter, lemma, PS_ANALYZER_MAX_RESULT_LEN);
        if (strstr(lemma, "<") != NULL) {
            *strstr(lemma, "<") = '\0';
        }
        // now we have both the lemma and the analysis. instantiate and set
        NSString* lemmaS = [NSString stringWithCString:lemma encoding:NSASCIIStringEncoding];
        NSString* analysisOutput = [NSString stringWithCString:output
                                                      encoding:NSASCIIStringEncoding];
        PSAnalysis* analysis = [[PSAnalysis alloc] initWithDefinition:_definition
                                                       transducerData:analysisOutput];
        arr = [result objectForKey: lemmaS];
        if (arr == nil) {
            arr = [NSMutableArray arrayWithObject:analysis];
            [result setObject:arr forKey:lemmaS];
        } else {
            [arr addObject:analysis];
        }
    }
    fst_iterator_destroy(&morph_iter);
    fst_iterator_destroy(&lemma_iter);
    return result;
}

- (void)dealloc {
    fst_destroy(&morph_fst);
    fst_destroy(&lemma_fst);
}

@end
