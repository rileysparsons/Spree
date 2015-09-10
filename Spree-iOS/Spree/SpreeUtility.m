//
//  SpreeUtility.m
//  Spree
//
//  Created by Riley Steele Parsons on 9/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SpreeUtility.h"
#import "UIImage+ResizeAdditions.h"
#import <Parse/PFAnonymousUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation SpreeUtility

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    // Check that PFUser has valid fbid that matches current FBSessions userId
    NSString *facebookId = [user objectForKey:PF_USER_FACEBOOK_ID];
    return (facebookId && facebookId.length > 0 && [facebookId isEqualToString:[[FBSDKAccessToken currentAccessToken] userID]]);
}

+ (UIImage *)defaultProfilePicture {
    return [UIImage imageNamed:@"AvatarPlaceholderBig.png"];
}

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}

+ (BOOL)userInDemoMode{
    return [PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]];
}

@end
