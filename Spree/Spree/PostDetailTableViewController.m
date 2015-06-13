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
#import "PostDescriptionTableViewCell.h"
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
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    self.navigationItem.backBarButtonItem.title = @"";
    
    [self setupNavigationBarImage];
    [self setupPriceButton];
    // Navigation bar UI
    
    // Setting the poster property
    [self getUserForPost];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    if (self.currentUserPost)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0)
        return self.fields.count;
    else if (section == 1)
        return 1;
    else
        return 0;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return @"Admin";
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1){
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35)];
        header.backgroundColor = [UIColor spreeBabyBlue];
        UILabel *adminLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, header.frame.size.width, header.frame.size.height)];
        adminLabel.text = @"Update Post";
        adminLabel.textColor = [UIColor whiteColor];
        [header addSubview:adminLabel];
        return header;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return 35;
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [self cellForField:self.fields[indexPath.row]];
    else if (indexPath.section == 1){
        static NSString *CellIdentifier = @"DefaultCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        return cell;
    } else {
        return 0;
    }
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
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
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
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        [self loadPostImagesForCell:cell];
        [cell setDateLabelForPost:self.post];
        return cell;
    } else if ([field isEqualToString:PF_POST_DESCRIPTION]){
        static NSString *CellIdentifier = @"PostDescriptionCell";
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
        [cell setUserLabelForPost:self.post];
        return cell;
    } else if ([field isEqualToString:PF_POST_BOOKFORCLASS]){
        static NSString *CellIdentifier = @"PostClassCell";
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.text = self.post.bookForClass;
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
        self.navigationItem.rightBarButtonItem = nil;
        self.currentUserPost = YES;
        [self.tableView reloadData];
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
