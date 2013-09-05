//
//  PSAnalysis.h
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSAnalysisProperty : NSObject

@property (readonly) NSString* name;
@property (readonly) NSString* value;
@property (readonly) NSString* longValue;

@end


@interface PSAnalysisComponent : NSObject

@property (readonly) NSString* stemPart;
@property (readonly) NSDictionary* properties;

@end


@interface PSAnalysis : NSObject

@property (readonly) NSString* canonicalForm;
@property (readonly) NSString* lemma;
@property (readonly) NSString* analyzedForm;

@property (readonly) NSArray* components;

- (PSAnalysis *) initWithDefinition:(NSDictionary *)definition transducerData:(NSString *)tData;
- (NSString *) summary;
- (NSString *) longSummary;

@end

PSAnalysis* PSNotFoundAnalysis;