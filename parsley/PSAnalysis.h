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

- (PSAnalysisProperty*) initWithName:(NSString*)name
                               value:(NSString*)value;

@end


@interface PSAnalysisComponent : NSObject

@property (readonly) NSString* stemPart;
@property (readonly) NSDictionary* properties;

- (PSAnalysisComponent*) initWithStemPart:(NSString*)stemPart
                               properties:(NSDictionary*)properties;

@end


@interface PSAnalysis : NSObject

@property (readonly) NSString* canonicalForm;
@property (readonly) NSString* lemma;
@property (readonly) NSString* summary;
@property (readonly) NSString* stemType;
@property (readonly) NSString* stemGroup;

@property (readonly) NSArray* components;
@property (readonly) NSDictionary* properties;

- (PSAnalysis *) initWithDefinition:(NSDictionary *)definition
                              lemma:(NSString *)lemma
                     transducerData:(NSString *)tData;

@end

PSAnalysis* PSNotFoundAnalysis;