//
//  SpreeUtility.h
//  Spree
//
//  Created by Riley Steele Parsons on 9/8/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpreeUtility : NSObject <UIAlertViewDelegate>

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (UIImage *)defaultProfilePicture;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;

+ (BOOL)userInDemoMode;

//+ (void) saveCurrentCreditBalance;

@end
