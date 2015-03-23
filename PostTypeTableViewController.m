//
//  PostTypeTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/20/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTypeTableViewController.h"

@interface PostTypeTableViewController ()

@end

@implementation PostTypeTableViewController

-  (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithClassName:@"Post"];
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Post";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"title";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"spreeTitleStylized.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"PostDeleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"PostMade" object:nil];// Do any additional setup after loading the view.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"type" equalTo:self.postType];
    [query orderByDescending:@"updatedAt"];
    
    return query;
}
@end
