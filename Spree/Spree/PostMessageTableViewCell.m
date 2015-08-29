//
//  PostMessageTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 8/25/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostMessageTableViewCell.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation PostMessageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setMessageButtonForPost:(SpreePost*)post{
    [post.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (object[@"fbId"]){
            NSString *graphPath = [NSString stringWithFormat:@"%@?fields=first_name", object[@"fbId"]];
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:graphPath parameters:nil];
            //                         Send request to Facebook
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    [self.messageButton setTitle:[NSString stringWithFormat:@"Message %@", result[@"first_name"]
                                                  ] forState:UIControlStateNormal];
                } else {
                    NSLog(@"3, %@",error);
                }
            }];
        } else {
            [self.messageButton setTitle:[NSString stringWithFormat:@"Message %@", object[@"username"]] forState:UIControlStateNormal];
        }
    }];
}

@end
