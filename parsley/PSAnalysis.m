//
//  PSAnalysis.m
//  parsley
//
//  Created by Harry Schmidt on 9/5/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#import "PSAnalysis.h"

static NSString* const PSComponentSeparator = @"::";
static NSCharacterSet* PSPropertySeparators;

@implementation PSAnalysisProperty

- (PSAnalysisProperty *)initWithName:(NSString *)name
                               value:(NSString *)value {
  self = [super init];
  _name = name;
  _value = value;
  return self;
}

@end


@implementation PSAnalysisComponent

- (PSAnalysisComponent*) initWithStemPart:(NSString*)stemPart properties:(NSDictionary*)properties {
  self = [super init];
  
  _stemPart = stemPart;
  _properties = properties;
  
  return self;
}
@end


@implementation PSAnalysis {
  NSDictionary *definitionDict;
}

+ (void)initialize {
  PSPropertySeparators = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
}

+ (NSDictionary*) parseLookupFromDefinition:(NSDictionary *)definition {
  if ([definition objectForKey:@"lookup"]) {
    return [definition objectForKey:@"lookup"];
  }
  
  NSMutableDictionary *parseLookup = [[NSMutableDictionary alloc] init];
  NSDictionary* tokenDictionary = [definition objectForKey:@"dictionary"];
  for (NSString *key in tokenDictionary) {
    for (NSString* value in (NSArray *)[tokenDictionary objectForKey:key]) {
      [parseLookup setValue:key forKey:value];
    }
  }
  
  return parseLookup;
}

+ (NSDictionary*) stemGroupLookupFromDefinition:(NSDictionary *)definition {
  if ([definition objectForKey:@"stemGroupLookup"]) {
    return [definition objectForKey:@"stemGroupLookup"];
  }
  
  NSMutableDictionary *stemGroupLookup = [[NSMutableDictionary alloc] init];
  NSDictionary* typeDictionary = [definition objectForKey:@"stem_groups"];
  for (NSString *shortName in typeDictionary) {
    NSDictionary *type = [typeDictionary objectForKey: shortName];
    NSString* longName = [type objectForKey: @"key"];
    NSArray* stems = [type objectForKey: @"stems"];
    NSArray* derivTypes = [type objectForKey: @"deriv_types"];
  
    NSString* val = longName ? longName : shortName;
    
    for (NSString* stem in stems) {
      [stemGroupLookup setObject:val forKey:stem];
    }
  
    for (NSString* derivType in derivTypes) {
      [stemGroupLookup setObject:val forKey:derivType];
    }
  }
  return stemGroupLookup;
}



- (PSAnalysis *) initWithDefinition:(NSDictionary *)definition
                              lemma:(NSString *)lemma
                     transducerData:(NSString *)tData {
  self = [super init];
  definitionDict = definition;
  NSDictionary* parseLookup = [PSAnalysis parseLookupFromDefinition:definition];

  NSMutableString* mStem = [[NSMutableString alloc] init];
  NSMutableDictionary* mProperties = [[NSMutableDictionary alloc] init];
  NSMutableArray* mComponents = [[NSMutableArray alloc] init];
  NSMutableArray *mSummary = [[NSMutableArray alloc] init];
  
  // break out the string into its consituent parts
  NSArray* componentTokens = [tData componentsSeparatedByString:@"::"];
  for (NSString* component in componentTokens) {
    // break up the parse components
    NSMutableDictionary *mPropsThisComponent = [[NSMutableDictionary alloc] init];
    NSString* modifiedComponent = [component stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSArray* elements = [modifiedComponent componentsSeparatedByString:@"<"];
    NSString* stemPart = [elements objectAtIndex:0];
    [mStem appendString:stemPart];
    
    for (NSString* parseToken in [elements subarrayWithRange:NSMakeRange(1, [elements count] - 1)]) {
      NSString *tokenName = [parseLookup objectForKey:parseToken];
      PSAnalysisProperty *parseProperty = [[PSAnalysisProperty alloc] initWithName:tokenName
                                                                             value:parseToken];
      [mPropsThisComponent setObject:parseProperty
                              forKey:tokenName];
    }
    [mProperties setValuesForKeysWithDictionary:mPropsThisComponent];
    
    [mComponents addObject:
     [[PSAnalysisComponent alloc] initWithStemPart:stemPart
                                        properties:mPropsThisComponent]];
    
  }
  
  // now go through the order list and generate the summary string
  for (NSString *key in (NSArray*)[definition objectForKey:@"order"]) {
    if ([mProperties objectForKey:key]) {
      PSAnalysisProperty *parseProperty = [mProperties objectForKey:key];
      [mSummary addObject:parseProperty.value];
    }
  }
  PSAnalysisProperty* stemTypeProp = [mProperties objectForKey:@"stemtype"];
  PSAnalysisProperty* derivTypeProp = [mProperties objectForKey:@"deriv_type"];
  
  NSDictionary* stemGroupLookup = [PSAnalysis stemGroupLookupFromDefinition:definition];
  NSString* stemGroupLookupKey = derivTypeProp ? derivTypeProp.value : stemTypeProp.value;
  
  _stemGroup = [stemGroupLookup objectForKey:stemGroupLookupKey];
  
  _stemType = stemTypeProp.value;
  _summary = [mSummary componentsJoinedByString:@" "];
  _components = mComponents;
  _properties = mProperties;
  _canonicalForm = mStem;
  _lemma = lemma;
  return self;
}

@end
