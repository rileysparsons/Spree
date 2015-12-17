//
//  SpreeParseConnectionImpl.m
//  Spree
//
//  Created by Riley Steele Parsons on 12/12/15.
//  Copyright © 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreeParseConnectionImpl.h"
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>

@implementation SpreeParseConnectionImpl

-(RACSignal *)loginWithFacebook{
    NSLog(@"This was called");
    
    return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        // Set permissions required from the facebook user account
        NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
        
        // Login PFUser using Facebook
        [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            if (!user) {
                [subscriber sendError:nil];
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                [subscriber sendNext:user];
                [subscriber sendCompleted];
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                [subscriber sendNext:user];
                [subscriber sendCompleted];
                NSLog(@"User logged in through Facebook!");
            }
        }];
        return nil;
    }];
}

-(RACSignal *)refreshPostsForCurrentLocation:(CLLocation *)location{
    return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
        
        double latitude = location.coordinate.latitude;
        double longitude = location.coordinate.longitude;
        
        PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
        
        [postQuery whereKey:@"location" nearGeoPoint:geopoint withinMiles:100];
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error){
                NSLog(@"no error here. %lu", (long unsigned)objects.count);
                [subscriber sendNext:objects];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];
}

@end
