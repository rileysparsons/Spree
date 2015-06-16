//
//  PostDetailTableViewController.m
//  
//
//  Created by Riley Steele Parsons on 6/9/15.
//
//

#import "PostDetailTableViewController.h"
#import "PostTitleTableViewCell.h"
#import "PhotoGalleryTableViewCell.h"
#import "PostUserTableViewCell.h"
#import "ProfileViewController.h"
#import "ChatView.h"
#import "common.h"
#import "ChatView.h"
#import "recent.h"
#import <YHRoundBorderedButton.h>

@interface PostDetailTableViewController ()

@property YHRoundBorderedButton* getButton;
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
    
    self.navigationItem.backBarButtonItem.title = @"";
    [self getUserForPost];
    [self setupNavigationBarImage];
    [self setupPriceButton];
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
        profileViewController.detailUser = self.poster;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [self cellForField:self.fields[indexPath.row]];
    return 0;
}

-(UITableViewCell *)cellForField:(NSString *)field {
    if ([field isEqualToString:PF_POST_TITLE]){
        static NSString *CellIdentifier = @"TitleCell";
        PostTitleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nibFiles = [[NSBundle mainBundle] loadNibNamed:@"PostTitleTableViewCell" owner:self options:nil];
            for(id currentObject in nibFiles){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (PostTitleTableViewCell*)currentObject;
                    break;
                }
            }
        }
        [cell setTitleforPost:self.post];
        [cell setDescriptionTextViewForPost:self.post];
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
                    break;
                }
            }
        }
        [cell setTag:2];
        [cell setUserLabelForPost:self.post];
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

-(void)setupPriceButton{
    self.getButton = [[YHRoundBorderedButton alloc] init];
    [self.getButton addTarget:self action:@selector(priceButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.getButton sizeToFit];
    [self.getButton setTintColor:[UIColor whiteColor]];
    [self.getButton setTitleColor:[UIColor spreeBabyBlue] forState:UIControlStateHighlighted];
    UIBarButtonItem *getBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.getButton];
    self.navigationItem.rightBarButtonItem = getBarButton;
    if ([self.post.type isEqualToString:POST_TYPE_TASK]){
        [self.getButton setTitle:@"CLAIM" forState:UIControlStateNormal];
    } else {
        [self.getButton setTitle:[NSString stringWithFormat:@"$%@", self.post.price.stringValue] forState:UIControlStateNormal];
    }
}

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
        self.currentUserPost = YES;
        [self updatePostStatus];
    } else {
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:self.post.user.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"%@", object);
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
