//
//  LoginWorkflow.m
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import "LoginWorkflow.h"
#import "LoginEmailViewController.h"
#import "LoginCampusTableViewController.h"
#import "LoginAuthorizationViewController.h"
#import "LoginPasswordViewController.h"
#import "BrowseViewController.h"

@interface LoginWorkflow ()

@property NSMutableArray *remainingFields;
@property NSString *password;
@property NSString *username;
@property NSString *email;
@property PFUser *user;

@end

@implementation LoginWorkflow

-(id)init{
    self = [super init];
    if( !self ) return nil;

    [self prepareWorkflow];
    
    return self;
}

-(void)prepareWorkflow{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    LoginPasswordViewController *passwordInputViewController =  [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginPasswordViewController class])];
    LoginEmailViewController *emailInputViewController = [stb instantiateViewControllerWithIdentifier:@"EmailInput"];
    LoginCampusTableViewController *campusInputViewController =
    [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginCampusTableViewController class])];
    
    emailInputViewController.loginWorkflow = self;
    passwordInputViewController.loginWorkflow = self;
    campusInputViewController.loginWorkflow = self;
    
    
    
    self.delegate = passwordInputViewController;
    
    self.user = [PFUser user];
    self.campus = [[PFObject alloc] initWithClassName:@"Campus"];
    
    self.loginNavigationController = [[UINavigationController alloc] init];
    self.viewControllersForFields = [[NSMutableArray alloc] initWithObjects:campusInputViewController,emailInputViewController, passwordInputViewController, nil];
    self.remainingFields = [[NSMutableArray alloc] initWithObjects: @"campus", @"email", @"password",nil];
}

-(void)setEmailForUser:(NSString *)email{
    self.username = email;
    self.email = email;
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"email" equalTo:email];
    [userQuery getFirstObjectInBackgroundWithBlock: ^(PFObject *result, NSError *error){
        if (result){
            self.newUser = NO;
        } else {
            self.newUser = YES;
            [self userIsNew];
        }
        [self.delegate didCheckForNewUser:email];
    }];
}

-(void)setPasswordForUser:(NSString*)password{
    self.password = password;
}

-(void)setCampusForUser:(PFObject *)campus{
    self.campus = campus;
}

-(void)userIsNew{
    NSLog(@"NEW");
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    LoginAuthorizationViewController *authorizationViewController = [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginAuthorizationViewController class])];
    authorizationViewController.loginWorkflow = self;
    self.delegate = authorizationViewController;
    [self.viewControllersForFields addObject:authorizationViewController];
    [self.remainingFields addObject:@"facebook"];
}

-(id)firstViewController{
    NSLog(@"Count %@, index %d", self.viewControllersForFields, self.step);
    return [self.viewControllersForFields objectAtIndex:0];
}

-(id)nextViewController{
    self.step++;
    NSLog(@"Count %@, index %d", self.viewControllersForFields, self.step);
    return [self.viewControllersForFields objectAtIndex:self.step];
}

-(id)previousViewController{
    self.step--;
    return [self.viewControllersForFields objectAtIndex:self.step];
}

-(void)cancelWorkflow {
    self.user = nil;
    self.viewControllersForFields = nil;
    self.remainingFields = nil;
}

-(void)completeWorkflow{
    NSLog(@"User:%@ username %@ password %@", self.user, self.username, self.password);
    self.user.username = self.username;
    self.user.password = self.password;
    self.user.email = self.email;
    
    if (self.newUser) {
         NSLog(@"signup");
        [self.user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self.delegate didCompleteWorkflow:self];
            } else  {
                [self.delegate didFailToCompleteWorkflow:self withError:error];
            }
        }];
    } else {
        [PFUser logInWithUsernameInBackground:self.username password:self.password block:^(PFUser *user, NSError *error)
        {
            if (!error){
                NSLog(@"login");
                [self.delegate didCompleteWorkflow:self];
            } else  {
                [self.delegate didFailToCompleteWorkflow:self withError:error];
            }
        }];
    }
}


@end
