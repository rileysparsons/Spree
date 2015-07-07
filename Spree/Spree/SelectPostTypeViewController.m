//
//  SelectPostViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 6/28/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostTypeViewController.h"
#import "PostTypeSelectionTableViewCell.h"
#import "PostFieldViewController.h"

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = [self titleLabel];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    
    [super viewDidLoad];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewControllerAnimated:completion:)]];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor spreeOffBlack];
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
    [cell initWithObject:object];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PostingWorkflow *postingWorkflow = [[PostingWorkflow alloc] initWithType:[self.objects objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:[postingWorkflow nextViewController] animated:YES];
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion{
    [super dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(UILabel *)titleLabel{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"Select post type";
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
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
