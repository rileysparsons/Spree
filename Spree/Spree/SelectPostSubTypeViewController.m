//
//  SelectPostSubTypeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/11/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "SelectPostSubTypeViewController.h"
#import "PostingWorkflow.h"
#import "PostTypeSelectionTableViewCell.h"
#import "SelectPostTypeHeaderView.h"
#import <MSCellAccessory/MSCellAccessory.h>

@interface SelectPostSubTypeViewController ()
    
@end

@implementation SelectPostSubTypeViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = @"PostSubtype";
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        self.loadingViewEnabled = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.post.typePointer fetchIfNeededInBackground];
    NSLog(@"This viewcontroller: %@", self.post);
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    cancel.backgroundColor = [UIColor clearColor];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelOffBlack"] forState:UIControlStateNormal];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancelHighlight"] forState:UIControlStateHighlighted];
    [cancel addTarget:self action:@selector(cancelWorkflow) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:cancel]];
    
    self.header.titleLabel.text =  [NSString stringWithFormat:@"Great! What type of %@ is it?", [self.type lowercaseString]];
    // Do any additional setup after loading the view.
}

-(PFQuery *)queryForTable{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"parentType" equalTo:self.post.typePointer];
    return query;
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{ 
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
    cell.typeLabel.text = [self.objects objectAtIndex:indexPath.row][@"subtype"];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"POST: %@", self.post);
    PostingWorkflow *postingWorkflow = [[PostingWorkflow alloc] initWithType:self.post.typePointer];
    postingWorkflow.post = self.post;
    [self.navigationController pushViewController:[postingWorkflow nextViewController] animated:YES];
}

-(void)cancelWorkflow{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
