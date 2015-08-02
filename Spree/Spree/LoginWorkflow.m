//
//  LoginWorkflow.m
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import "LoginWorkflow.h"
#import "LoginInputViewController.h"
#import "LoginCampusTableViewController.h"
#import "LoginAuthorizationViewController.h"

@interface LoginWorkflow ()

@property NSMutableArray *viewControllersForFields;
@property NSMutableArray *remainingFields;


@end

int step = 0;

@implementation LoginWorkflow

-(id)init{
    self = [super init];
    if( !self ) return nil;

    [self prepareWorkflow];
    
    return self;
}

-(void)prepareWorkflow{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    LoginInputViewController *passwordInputViewController = [stb instantiateViewControllerWithIdentifier:@"PasswordInput"];
    LoginInputViewController *emailInputViewController = [stb instantiateViewControllerWithIdentifier:@"EmailInput"];
    LoginCampusTableViewController *campusInputViewController =
    [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginCampusTableViewController class])];
    emailInputViewController.loginWorkflow = self;
    passwordInputViewController.loginWorkflow = self;
    campusInputViewController.loginWorkflow = self;
    
    self.loginNavigationController = [[UINavigationController alloc] init];
    self.viewControllersForFields = [[NSMutableArray alloc] initWithObjects:campusInputViewController,emailInputViewController, passwordInputViewController, nil];
    self.remainingFields = [[NSMutableArray alloc] initWithObjects: @"campus", @"email", @"password",nil];
}

-(void)userIsNew{
    UIStoryboard *stb = [UIStoryboard storyboardWithName:@"Walkthrough" bundle:nil];
    LoginAuthorizationViewController *authorizationViewController = [stb instantiateViewControllerWithIdentifier:NSStringFromClass([LoginAuthorizationViewController class])];
    authorizationViewController.loginWorkflow = self;

    [self.viewControllersForFields addObject:authorizationViewController];
    
    [self.remainingFields addObject:@"facebook"];
}

-(id)firstViewController{
    return [self.viewControllersForFields objectAtIndex:0];
}

-(id)nextViewController{
    step++;
    return [self.viewControllersForFields objectAtIndex:step];
}

-(id)previousViewController{
    step--;
    return [self.viewControllersForFields objectAtIndex:step];
}

-(void)cancelWorkflow {
    self.user = nil;
    self.viewControllersForFields = nil;
    self.remainingFields = nil;
}




@end
