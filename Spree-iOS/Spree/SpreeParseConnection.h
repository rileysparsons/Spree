//
//  SpreeParseConnection.h
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

@import Foundation;
#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol SpreeParseConnection <NSObject>


-(RACSignal *)checkIfUserWithEmailExists:(NSString *)email;

@end
