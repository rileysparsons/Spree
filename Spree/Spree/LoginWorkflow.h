//
//  LoginWorkflow.h
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import <Foundation/Foundation.h>

@interface LoginWorkflow : NSObject

-(id)nextViewController;
-(id)previousViewController;
-(id)firstViewController;
-(void)cancelWorkflow;

@property PFUser *user;
@property UINavigationController *loginNavigationController;

@end
