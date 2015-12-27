//
//  SelectPostViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostTypeViewController.h"
#import "PostTypeSelectionTableViewCell.h"
#import "SelectPostSubTypeViewController.h"
#import "SpreePost.h"
#import "PostingWorkflow.h"
#import "SpreeUtility.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MSCellAccessory/MSCellAccessory.h>

typedef enum : NSUInteger {
    kVerifyEmailAlert,
    kAuthorizeLocationServicesAlert
} AlertViewTag;

@interface SelectPostTypeViewController () <UIAlertViewDelegate>

@end

@implementation SelectPostTypeViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || kCLAuthorizationStatusRestricted){
        UIAlertView *locationAlert =  [[UIAlertView alloc] initWithTitle:@"Location Unavailable" message:@"To post something to Spree you must authorize the use of your location through your phone's settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
       locationAlert.tag = kAuthorizeLocationServicesAlert;
        [locationAlert show];
        
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor spreeOffWhite];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = [self titleLabel];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    cancel.backgroundColor = [UIColor clearColor];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(dismissViewControllerAnimated:completion:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancel]];
    
    NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"SelectPostTypeHeaderView" owner:self options:nil];
    for(id currentObject in nibFiles){
        if ([currentObject isKindOfClass:[UIView class]]){
            self.header = currentObject;
            break;
        }
    }
    [self.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [self.header layoutSubviews];
    self.tableView.tableHeaderView = self.header;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    static NSString *CellIdentifier = @"Cell";
    PostTypeSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostTypeSelectionTableViewCell" owner:self options:nil];
        for(id currentObject in nibFiles){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (PostTypeSelectionTableViewCell*)currentObject;
                break;
            }
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeOffBlack]];
    [cell initWithPostType:object];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([SpreeUtility checkForEmailVerification]){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        SpreePost *post = [[SpreePost alloc] init];
        post.typePointer = [self objectAtIndexPath:indexPath];
        post.user = [PFUser currentUser];
        PFQuery *subtype = [PFQuery queryWithClassName:@"PostSubtype"];
        [subtype getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            PostingWorkflow *postingWorkflow = [[PostingWorkflow alloc] initWithPost:post];
            if (object){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
                SelectPostSubTypeViewController *selectPostSubTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostSubTypeViewController"];
                selectPostSubTypeViewController.workflow = postingWorkflow;
                selectPostSubTypeViewController.post = post;
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationController pushViewController:selectPostSubTypeViewController animated:YES];
            } else {
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationController pushViewController:[postingWorkflow nextViewController] animated:YES];
            }
        }];
    } else {
        UIAlertView *userNotVerified = [[UIAlertView alloc] initWithTitle:@"Unverified Student" message:VERIFY_EMAIL_PROMPT delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Resend email", nil];
        userNotVerified.tag = kVerifyEmailAlert;
        [userNotVerified show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [super dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

-(UIView *)titleLabel{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"CREATE NEW POST";
    titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor spreeOffBlack];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    return titleLabel;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kVerifyEmailAlert){
        int resendButtonIndex = 1;
        if (resendButtonIndex == buttonIndex){
            //updating the email will force Parse to resend the verification email
            NSString *email = [[PFUser currentUser] objectForKey:@"email"];
            NSLog(@"email: %@",email);
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error ){
                
                if( succeeded ) {
                    
                    [[PFUser currentUser] setObject:email forKey:@"email"];
                    [[PFUser currentUser] saveInBackground];
                    
                }
                
            }];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAuthorizeLocationServicesAlert){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
