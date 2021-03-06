//
//  SpreePost.h
//  Spree
//
//  Created by Riley Steele Parsons on 2/10/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

@interface SpreePost : PFObject <PFSubclassing>

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *userDescription;
@property (nonatomic) PFGeoPoint *location;
@property (nonatomic) NSNumber *price;
@property (nonatomic) NSString *type;
@property (nonatomic) PFUser *user;
@property (nonatomic) PFFile *imageFile;
@property (nonatomic) NSArray *photoArray;
@property (nonatomic) NSString *bookForClass;
@property (nonatomic) NSString *eventDate;
@property (nonatomic) NSString *network;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) PFUser *taskClaimedBy;
@property (nonatomic) PFObject *typePointer;
@property (nonatomic) NSDate *dateForEvent;
@property BOOL removed;
@property BOOL sold;
@property BOOL taskClaimed;
@property BOOL expired;



@end
