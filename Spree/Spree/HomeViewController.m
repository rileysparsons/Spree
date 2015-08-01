//
//  HomeViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/30/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeHeaderView.h"
#import "HeaderSlideView.h"

@interface HomeViewController ()

@property HomeHeaderView *header;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.header = [[HomeHeaderView alloc] init];
    NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"HomeHeaderView" owner:self options:nil];
    for(id currentObject in nibFiles){
        if ([currentObject isKindOfClass:[UIView class]]){
            self.header = currentObject;
            break;
        }
    }
    [self.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    self.tableView.tableHeaderView = self.header;
}

-(NSArray *)headerSlides{
    HeaderSlideView *view1 = [[HeaderSlideView alloc] init];
    HeaderSlideView *view2 = [[HeaderSlideView alloc] init];
    HeaderSlideView *view3 = [[HeaderSlideView alloc] init];
    
    NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"HeaderSlideView" owner:self options:nil];
    for(id currentObject in nibFiles){
        if ([currentObject isKindOfClass:[UIView class]]){
            view1 = currentObject;
            break;
        }
    }

    for(id currentObject in nibFiles){
        if ([currentObject isKindOfClass:[UIView class]]){
            view2 = currentObject;
            break;
        }
    }

    for(id currentObject in nibFiles){
        if ([currentObject isKindOfClass:[UIView class]]){
            view3 = currentObject;
            break;
        }
    }

    [view1 setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [view2 setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [view3 setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [view1 setTitleWithString:@"View 1"];
    [view2 setTitleWithString:@"View 2"];
    [view3 setTitleWithString:@"View 3"];
    return [[NSArray alloc] initWithObjects:view1,view2,view3, nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self.header setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    [self sizeHeaderToFit];
}

- (void) sizeHeaderToFit {
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
     NSLog(@"header :%f", height);
    headerView.frame = ({
        CGRect headerFrame = headerView.frame;
        headerFrame.size.height = height;
        headerFrame;
    });
    
    self.tableView.tableHeaderView = headerView;
}




@end
