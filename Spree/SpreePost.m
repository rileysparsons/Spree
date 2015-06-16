//
//  SpreePost.m
//  Spree
//
//  Created by Riley Steele Parsons on 2/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreePost.h"
#import <Parse/PFObject+Subclass.h>

@implementation SpreePost

@dynamic title, price, userDescription, expired, sold, type, location, photoArray, user, imageFile,  bookForClass, eventDate, network, subtitle, taskClaimed, taskClaimedBy, dateForEvent, removed;

+(NSString *)parseClassName{
    return @"Post";
}

@end
