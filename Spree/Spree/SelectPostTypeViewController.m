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
#import <MSCellAccessory.h>

@interface SelectPostTypeViewController ()

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
         return 150;
    } else {
        return 40;
    }

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0){
        UIView *header = [tableView headerViewForSection:0];
        if (header == nil){
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"SelectPostTypeHeaderView" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UIView class]]){
                    header = currentObject;
                    break;
                }
            }
        }
        return header;
    }
    return 0;
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
    NSLog(@"%@", object[@"subType"]);
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor spreeOffBlack]];
    [cell initWithObject:object];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    SpreePost *post = [[SpreePost alloc] init];
    post.typePointer = [self objectAtIndexPath:indexPath];
    post.user = [PFUser currentUser];
    if ([[self objectAtIndexPath:indexPath] objectForKey:@"subType"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewPost" bundle:nil];
        SelectPostSubTypeViewController *selectPostSubTypeViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectPostSubTypeViewController"];
        selectPostSubTypeViewController.post = post;
        selectPostSubTypeViewController.subTypes = [[self objectAtIndexPath:indexPath] objectForKey:@"subType"];
        selectPostSubTypeViewController.type = [self objectAtIndexPath:indexPath][@"type"];
        [self.navigationController pushViewController:selectPostSubTypeViewController animated:YES];
    } else {
        PostingWorkflow *postingWorkflow = [[PostingWorkflow alloc] initWithType:post.typePointer];
        postingWorkflow.post = post;
        [self.navigationController pushViewController:[postingWorkflow nextViewController] animated:YES];
    }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
