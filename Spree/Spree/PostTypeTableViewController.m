//
//  PostTypeTableViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 3/20/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PostTypeTableViewController.h"
#import "UIColor+SpreeColor.h"
#import "WSCoachMarksView.h"

@interface PostTypeTableViewController (){
    WSCoachMarksView *coachMarksView;
}

@end

@implementation PostTypeTableViewController

-  (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
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
    self.title = self.postType;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"ReloadTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"PostMade" object:nil];

    [self addCoachMarks];
}
-(void)viewWillAppear:(BOOL)animated{
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShownForPostType"];
    if (coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShownForPostType"];
        [[NSUserDefaults standardUserDefaults] synchronize];\
        // Or show coach marks after a second delay
        [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:1.0f];
    }
}

-(void)addCoachMarks{
    NSArray *coachMarks = @[
                            @{
                                @"rect": [NSValue valueWithCGRect:(CGRect){{self.view.frame.size.width -45, 25},{35, 35}}],
                                @"caption": @"Post something on Spree!"
                                }
                            ];
    coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
    [self.tabBarController.view addSubview:coachMarksView];
    coachMarksView.maskColor = [UIColor colorWithWhite:1 alpha:.95];
    coachMarksView.lblCaption.textColor = [UIColor spreeBabyBlue];
    coachMarksView.lblCaption.font = [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:24];
}


- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"type" equalTo:self.postType];
    [query whereKey:@"expired" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"sold" equalTo:[NSNumber numberWithBool:NO]];
    [query whereKey:@"network" equalTo:[[PFUser currentUser] objectForKey:@"network"]];
    [query orderByDescending:@"updatedAt"];
    
    return query;
}
@end
