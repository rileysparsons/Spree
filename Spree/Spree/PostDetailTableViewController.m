//
//  PostDetailTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/9/15.
//
//

#import "PostDetailTableViewController.h"
#import "PostDescriptionTableViewCell.h"
#import "PostTitleTableViewCell.h"
#import "PhotoGalleryTableViewCell.h"
#import "PostUserTableViewCell.h"
#import "ProfileViewController.h"
#import "ChatView.h"
#import "common.h"
#import "ChatView.h"
#import "recent.h"
#import <YHRoundBorderedButton.h>
#import "Branch.h"
#import "MessageUI/MessageUI.h"

@interface PostDetailTableViewController ()

@property YHRoundBorderedButton* getButton;
@property YHRoundBorderedButton* shareButton;
@property BOOL currentUserPost;

@end

@implementation PostDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Table View Set up
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.estimatedRowHeight = 100.0f;
    
    self.tableView.backgroundColor = [UIColor spreeOffWhite];
    self.view.backgroundColor = [UIColor spreeOffWhite];
    
    self.navigationItem.backBarButtonItem.title = @"";
    [self getUserForPost];
    [self setupNavigationBarImage];
    [self setupBarButtons];
    [self updatePostStatus];
    // Navigation bar UI
    
    // Setting the poster property
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0)
        return self.fields.count;
    return 0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([tableView cellForRowAtIndexPath:indexPath].tag == 2){
        ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"
         ];
        NSLog(@"Poster in %@", self.poster);
        profileViewController.detailUser = self.poster;
        NSLog(@"USER: %@", profileViewController.detailUser);
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [self cellForField:self.fields[indexPath.row]];
    return 0;
}

-(UITableViewCell *)cellForField:(NSString *)field {
    
    if ([field isEqualToString:PF_POST_DESCRIPTION]){
        static NSString *CellIdentifier = @"DescriptionCell";
        PostDescriptionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostDescriptionTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PostDescriptionTableViewCell*)currentObject;
                    break;
                }
            }
        }
        
        [cell setDescriptionTextViewForPost:self.post];
        CGSize sysSize = [cell.contentView systemLayoutSizeFittingSize:CGSizeMake(self.tableView.bounds.size.width, CGFLOAT_MAX)];
        cell.contentView.bounds = CGRectMake(0,0, sysSize.width, sysSize.height);
        [cell.contentView layoutIfNeeded];
        return cell;
    } else if ([field isEqualToString:PF_POST_TITLE]){
        static NSString *CellIdentifier = @"TitleCell";
        PostTitleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostTitleTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PostTitleTableViewCell*)currentObject;
                    [cell setTitleforPost:self.post];
                    break;
                }
            }
        }
        [cell setTitleforPost:self.post];
        return cell;
    } else if ([field isEqualToString:PF_POST_PHOTOARRAY]){
        static NSString *CellIdentifier = @"PhotoGalleryCell";
        PhotoGalleryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PhotoGalleryTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PhotoGalleryTableViewCell*)currentObject;
                    break;
                }
            }
        }
        [self loadPostImagesForCell:cell];
        [cell setDateLabelForPost:self.post];
        return cell;
    } else if ([field isEqualToString:PF_POST_USER]){
        static NSString *CellIdentifier = @"PostUserCell";
        PostUserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostUserTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PostUserTableViewCell*)currentObject;
                    [cell setTag:2];
                    [cell setUserLabelForPost:self.post];
                    break;
                }
            }
        }
        return cell;
    } else if ([field isEqualToString:PF_POST_BOOKFORCLASS]){
        static NSString *CellIdentifier = @"PostClassCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = self.post.bookForClass;
        return cell;
    } else if ([field isEqualToString:PF_POST_DATEFOREVENT]){
        static NSString *CellIdentifier = @"PostEventDateCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = self.post.eventDate;
        return cell;
    }
    
    static NSString *CellIdentifier = @"DefaultCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    return cell;
}

#pragma mark - UI Setup

-(void)setupBarButtons{
    self.getButton = [[YHRoundBorderedButton alloc] init];
    [self.getButton addTarget:self action:@selector(priceButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.getButton sizeToFit];
    [self.getButton setTintColor:[UIColor spreeDarkBlue]];
    [self.getButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateHighlighted];
    UIBarButtonItem *getBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.getButton];
    //self.navigationItem.rightBarButtonItem = getBarButton;
    
    
    
    
    self.shareButton = [[YHRoundBorderedButton alloc] init];
    [self.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton sizeToFit];
    [self.shareButton setTintColor:[UIColor spreeDarkBlue]];
    [self.shareButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateHighlighted];
    UIBarButtonItem *getShareButton = [[UIBarButtonItem alloc] initWithCustomView:self.shareButton];
    NSArray *tempArray2= [[NSArray alloc] initWithObjects:getBarButton, getShareButton, nil];
    self.navigationItem.rightBarButtonItems=tempArray2;

    [self.shareButton setTitle:[NSString stringWithFormat:@"Share"] forState:UIControlStateNormal];
    if ([self.post.type isEqualToString:POST_TYPE_TASK]){
        [self.getButton setTitle:@"CLAIM" forState:UIControlStateNormal];
    } else {
        [self.getButton setTitle:[NSString stringWithFormat:@"$%@", self.post.price.stringValue] forState:UIControlStateNormal];
    }}

-(void)setupNavigationBarImage{
    if ([self.post.type isEqualToString:POST_TYPE_TASK]){
        UIImageView *navBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sprintCellIconWhite"]];
        navBarIcon.frame = CGRectMake(0, 0, 25, 25);
        navBarIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = navBarIcon;
    } else if ([self.post.type isEqualToString:POST_TYPE_TICKETS]){
        UIImageView *navBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookTypeIconSmall"]];
        navBarIcon.frame = CGRectMake(0, 0, 25, 25);
        navBarIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = navBarIcon;
    } else if ([self.post.type isEqualToString:POST_TYPE_CLOTHING]){
        UIImageView *navBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clothingCellIconWhite"]];
        navBarIcon.frame = CGRectMake(0, 0, 25, 25);
        navBarIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = navBarIcon;
    } else if ([self.post.type isEqualToString:POST_TYPE_FURNITURE]){
        UIImageView *navBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"furnitureCellIconWhite"]];
        navBarIcon.frame = CGRectMake(0, 0, 25, 25);
        navBarIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = navBarIcon;
    } else if ([self.post.type isEqualToString:POST_TYPE_BOOKS]){
        UIImageView *navBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookTypeIconSmall"]];
        navBarIcon.frame = CGRectMake(0, 0, 25, 25);
        navBarIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = navBarIcon;
    } else if ([self.post.type isEqualToString:POST_TYPE_ELECTRONICS]){
        UIImageView *navBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ElectronicsTypeIconSmall"]];
        navBarIcon.frame = CGRectMake(0, 0, 25, 25);
        navBarIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = navBarIcon;
    }
}

#pragma mark - Post Images

-(UITableViewCell *)loadPostImagesForCell:(PhotoGalleryTableViewCell *)cell{
    if (self.post.photoArray.count != 0){
        NSMutableArray *tempPhotoArray = [[NSMutableArray alloc] initWithCapacity:3];
        for (PFFile *imageFile in self.post.photoArray){
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [tempPhotoArray addObject:image];
                    [cell setPhotoGalleryForImages:tempPhotoArray];
                    // image can now be set on a UIImageView
                }
            }];
        }
    }
    return 0;
}

#pragma mark - Button Selectors

-(void)priceButtonPressed{
    PFUser *user2 = self.poster;
    PFUser *user1 = [PFUser currentUser];
    
    NSString *groupId = StartPrivateChat(user1, user2);
    
    [self actionChat:groupId post:self.post];
}


-(void)shareButtonPressed{
    
    //dictionary passed into the link that contains the object ID of the post that is being shared
    NSMutableDictionary *objectId = [NSMutableDictionary dictionary];
    [objectId setObject:self.post.objectId forKey:@"object id"];
    
    //creates custom url that contains info put into it using the dictionary
    
    MFMessageComposeViewController *smsViewController = [[MFMessageComposeViewController alloc] init];
    [smsViewController setMessageComposeDelegate:self];
    
    if ([MFMessageComposeViewController canSendText]) {
    
        [[Branch getInstance] getContentUrlWithParams:objectId andChannel:@"sms" andCallback:^(NSString *url, NSError *error) {
            NSLog(@"OBJECT ID: %@", self.post.objectId);
            NSLog(@"URL: %@", url);
            
            if(!error) {
                smsViewController.body = [NSString stringWithFormat:@"Check out this post on Spree! %@", url];
                [self presentViewController:smsViewController animated:true completion:nil];
            }
        }];
    
    }
    
    else {
        UIAlertView * alert_Dialog = [[UIAlertView alloc] initWithTitle:@"No Message Support" message:@"This device does not support messaging" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert_Dialog show];
        alert_Dialog = nil;
    }
    
    
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}




- (void)actionChat:(NSString *)groupId post:(PFObject *)post_
{
    ChatView *chatView = [[ChatView alloc] initWith:groupId post:post_ title:self.poster[@"username"]];
    NSLog(@"%@", self.poster[@"username"]);
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
    // Unhide the tabbar when we go back
    self.hidesBottomBarWhenPushed = NO;
}

-(void)getUserForPost{
    if (([[(PFUser *)self.post.user objectId] isEqualToString: [[PFUser currentUser] objectId]])){
        //        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self actio:@selector(deleteButtonSelected)];
        self.poster = [PFUser currentUser];
        self.currentUserPost = YES;
        [self updatePostStatus];
    } else {
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:self.post.user.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"THIS: %@", object);
            self.poster = (PFUser *)object;
//            NSString *date = [NSDateFormatter localizedStringFromDate:[self.post createdAt] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
//            _postDateUserLabel.text = [NSString stringWithFormat:@"Posted by %@ on %@", (_poster[@"name"]) ? _poster[@"name"] : _poster[@"username"], date];
//            [self _loadData];
        }];
    }
}

-(void)userControlButtonTouched{
    UIAlertController *userControl = [UIAlertController alertControllerWithTitle:@"Post Control" message:@"Decide if your post should stay or go" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              [userControl dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    UIAlertAction* itemSold = [UIAlertAction actionWithTitle:@"This item has been sold" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.post.sold = YES;
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (succeeded){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:nil];
            }
        }];
        [userControl dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction* deletePost = [UIAlertAction actionWithTitle:@"Delete post" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        self.post.removed = YES;
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (succeeded){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:nil];
                
            }
        }];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [userControl addAction:cancel];
    [userControl addAction:deletePost];
    [userControl addAction:itemSold];
    [self presentViewController:userControl animated:YES completion:nil];
}

-(void)updatePostStatus{
    if (self.currentUserPost){
        if (!self.post.sold){
            UIBarButtonItem *userControlButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(userControlButtonTouched)];
            UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:24.0];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:f1, NSFontAttributeName, nil]; [userControlButton setTitleTextAttributes:dict forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = userControlButton;
            self.currentUserPost = YES;
        } else {
            [self.getButton setTitle:@"SOLD" forState:UIControlStateNormal];
            [self.getButton setUserInteractionEnabled:NO];
        }
    }
}

-(void)initializeWithObjectId:(NSString *)string{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query getObjectInBackgroundWithId:string block:^(PFObject *object, NSError *error){
        if (error){
            
        } else {
            self.post = (SpreePost *)object;
        }
    }];
}

@end
