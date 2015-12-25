//
//  SpreeParseConnection.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

@import Foundation;
#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NS_ENUM(NSUInteger, SpreePostType) {
    kSpreePostTypeNone,
    kSpreePostTypeKitchen,
    kSpreePostTypeWheels,
    kSpreePostTypeSports,
    kSpreePostTypeOutdoors,
    kSpreePostTypeAccessories,
    kSpreePostTypeTasks,
    kSpreePostTypeTickets,
    kSpreePostTypeFurniture,
    kSpreePostTypeBooks,
    kSpreePostTypeClothing,
    kSpreePostTypeElectronics
};

@protocol SpreeParseConnection <NSObject>


-(RACSignal *)loginWithFacebook;

-(RACSignal *)findPostsSignalWithLocation:(CLLocation *)location params:(NSDictionary *)params;

-(RACSignal *)findPostsSignalWithLocation:(CLLocation *)location params:(NSDictionary *)params keywords:(NSArray *)keywords;

@end
