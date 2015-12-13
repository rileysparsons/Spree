//
//  SpreeParseConnectionImpl.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreeParseConnectionImpl.h"

@implementation SpreeParseConnectionImpl

-(RACSignal *)checkIfUserWithEmailExists:(NSString *)email{
    return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        PFQuery *query = [PFUser query];
        NSLog(@"%@",email);
        [query whereKey:@"email" equalTo:email];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (error){
                NSLog(@"ERROR %@", error);
                [subscriber sendError:error];
            } else if (object){
                
                NSLog(@"OBJECT %@", error);
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

@end
