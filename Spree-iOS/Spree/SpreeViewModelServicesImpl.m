//
//  SpreeViewModelServicesImpl.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreeViewModelServicesImpl.h"
#import "SpreeParseConnectionImpl.h"

@interface SpreeViewModelServicesImpl ()

@property SpreeParseConnectionImpl *parseConnection;

@end

@implementation SpreeViewModelServicesImpl

-(instancetype)init{
    if (self = [super init]){
        _parseConnection = [SpreeParseConnectionImpl new];
    }
    return self;
}

-(id<SpreeParseConnection>)getParseConnection{
    return self.parseConnection;
}

@end
