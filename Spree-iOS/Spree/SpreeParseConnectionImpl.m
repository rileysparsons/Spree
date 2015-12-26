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

-(RACSignal *)findAllPostsForLocation:(CLLocation *)location{
    return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
        
        double latitude = location.coordinate.latitude;
        double longitude = location.coordinate.longitude;
        
        PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
        
        [postQuery whereKey:@"location" nearGeoPoint:geopoint withinMiles:200];
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error){
                NSLog(@"no error here (all). %lu", (long unsigned)objects.count);
                [subscriber sendNext:objects];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];
}

-(RACSignal *)findPostsSignalWithLocation:(CLLocation *)location params:(NSDictionary *)params{
    if (params){
        if ([params objectForKey:@"type"]){
            return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
                NSLog(@" this is the type %@", params[@"type"]);
                    [[self typeObjectForString:params[@"type"]] subscribeNext:^(PFObject *postType) {
                        
                        PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
                        
                        double latitude = location.coordinate.latitude;
                        double longitude = location.coordinate.longitude;
                        
                        PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
                        
                        [postQuery whereKey:@"location" nearGeoPoint:geopoint withinMiles:200];
                        
                        NSLog(@"type in final query %@", postType[@"type"]);
                        [postQuery whereKey:@"typePointer" equalTo:postType];
                        
                        [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                            if (!error){
                                NSLog(@"no error here (params). %lu", (long unsigned)objects.count);
                                [subscriber sendNext:objects];
                                [subscriber sendCompleted];
                            } else {
                                [subscriber sendError:error];
                            }
                        }];
                    }];
                
                return nil;
            }];
        }
    } else {
        // If no other parameters were provided send back all posts that match that location
        return [self findAllPostsForLocation:location];
    }
    return nil;
}

-(RACSignal *)findPostsSignalWithLocation:(CLLocation *)location params:(NSDictionary *)params keywords:(NSArray *)keywords{
    if (params && keywords.count > 0){
        if ([params objectForKey:@"type"]){
            return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
                NSLog(@" this is the type %@", params[@"type"]);
                [[self typeObjectForString:params[@"type"]] subscribeNext:^(PFObject *postType) {
                    
                    PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
                    
                    double latitude = location.coordinate.latitude;
                    double longitude = location.coordinate.longitude;
                    
                    PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
                    
                    [postQuery whereKey:@"location" nearGeoPoint:geopoint withinMiles:200];
                    
                    [postQuery whereKey:@"keywords" containsAllObjectsInArray:keywords];
                    
                    NSLog(@"type in final query %@", postType[@"type"]);
                    [postQuery whereKey:@"typePointer" equalTo:postType];
                    
                    [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        if (!error){
                            NSLog(@"no error here (keyword). %lu", (long unsigned)objects.count);
                            [subscriber sendNext:objects];
                            [subscriber sendCompleted];
                        } else {
                            [subscriber sendError:error];
                        }
                    }];
                }];
                
                return nil;
            }];
        }
    } else if (params){
        return [self findPostsSignalWithLocation:location params:params];
    } else {
        // If no other parameters or keywords were provided send back all posts that match that location
        return [self findAllPostsForLocation:location];
    }
    return nil;
}


#pragma mark - Parse Database Helper Methods


// For Parse Database. Types belong to their own class and have a string key which describes them.
-(RACSignal *)typeObjectForString:(NSString *)string{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PFQuery *typeQuery = [PFQuery queryWithClassName:@"PostType"];
        [typeQuery whereKey:@"type" equalTo:string];
        [typeQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (!error){
                NSLog(@"retrieved object: %@", object);
                [subscriber sendNext:object];
                [subscriber sendCompleted];
            } else {
                NSLog(@"error retrieving object: %@", error);
                [subscriber sendError:error];
            }
        }];
        return nil;
    }];
}

@end
