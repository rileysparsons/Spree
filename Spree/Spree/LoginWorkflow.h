//
//  LoginWorkflow.h
//  
//
//  Created by Riley Steele Parsons on 8/2/15.
//
//

#import <Foundation/Foundation.h>

@protocol LoginWorkflowDelegate;

@interface LoginWorkflow : NSObject 

-(id)nextViewController;
-(id)previousViewController;
-(id)firstViewController;
-(void)cancelWorkflow;
-(void)completeWorkflow;
-(void)setPasswordForUser:(NSString*)password;
-(void)setEmailForUser:(NSString *)email;
-(void)setCampusForUser:(PFObject *)campus;

@property UINavigationController *loginNavigationController;
@property NSMutableArray *viewControllersForFields;
@property int step;
@property id<LoginWorkflowDelegate> delegate;
@property PFObject *campus;

@end

@protocol LoginWorkflowDelegate <NSObject>

@optional

- (BOOL)shouldBeginToCompleteWorkflow:(LoginWorkflow *)loginWorkflow;

- (BOOL)didCompleteWorkflow:(LoginWorkflow *)loginWorkflow;

- (BOOL)didFailToCompleteWorkflow:(LoginWorkflow *)loginWorkflow withError:(NSError*)error;


@end
