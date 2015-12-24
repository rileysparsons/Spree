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

-(RACSignal *)findPostsForLocation:(CLLocation *)location type:(SpreePostType)type{
    return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        NSLog(@" this is the type %lu", (unsigned long)type);
        [[self typeObjectForPostType:type] subscribeNext:^(PFObject *postType) {
            
            PFQuery *postQuery = [PFQuery queryWithClassName:@"Post"];
            
            double latitude = location.coordinate.latitude;
            double longitude = location.coordinate.longitude;
            
            PFGeoPoint *geopoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
            
            [postQuery whereKey:@"location" nearGeoPoint:geopoint withinMiles:200];
        
            NSLog(@"type in final query %@", postType[@"type"]);
            [postQuery whereKey:@"typePointer" equalTo:postType];
            
            [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (!error){
                    NSLog(@"no error here. %lu", (long unsigned)objects.count);
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

#pragma mark - Parse Database Helper Methods

-(RACSignal *)typeObjectForPostType:(SpreePostType)postType{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        PFQuery *typeQuery = [PFQuery queryWithClassName:@"PostType"];
        if (postType == kSpreePostTypeKitchen){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_KITCHEN];
        } else if (postType == kSpreePostTypeElectronics){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_ELECTRONICS];
        } else if (postType == kSpreePostTypeFurniture){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_FURNITURE];
        } else  if (postType == kSpreePostTypeOutdoors){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_OUTDOORS];
        } else if (postType == kSpreePostTypeSports){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_SPORTS];
        } else if (postType == kSpreePostTypeTasks){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_TASKSANDSERVICES];
        } else if (postType == kSpreePostTypeTickets){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_TICKETS];
        } else if (postType == kSpreePostTypeWheels){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_WHEELS];
        } else if (postType == kSpreePostTypeClothing){
            [typeQuery whereKey:@"type" equalTo:POST_TYPE_CLOTHING];
        }
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
