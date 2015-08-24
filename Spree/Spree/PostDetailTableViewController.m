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
#import "PostMapTableViewCell.h"
#import "ProfileViewController.h"
#import "ChatView.h"
#import "common.h"
#import "ChatView.h"
#import "recent.h"
#import <YHRoundBorderedButton.h>



@interface PostDetailTableViewController ()

@property YHRoundBorderedButton* getButton;
@property BOOL currentUserPost;
@property BOOL hasCompletedFields;
@end

@implementation PostDetailTableViewController

-(void)initWithPost:(SpreePost *)post{
    self.post = post;
    self.existingFieldsForTable = [[NSMutableArray alloc] init];
    if (self.post[@"completedFields"]){
        self.existingFields = self.post[@"completedFields"];
        self.detailCells = [[NSMutableArray alloc] init];
        self.hasCompletedFields = YES;
        [self organizeTableForFields];
    } else {
        [self.post.typePointer fetchIfNeededInBackgroundWithBlock:^(PFObject *type, NSError *error){
            self.existingFields = self.post.typePointer[@"fields"];
            [self organizeTableForFields];
        }];
    }
}

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
    [self setupPriceButton];
    [self updatePostStatus];
    // Navigation bar UI
    
    // Setting the poster property
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.hasCompletedFields == YES){
        if (section == 0)
            return self.detailCells.count;
        return 0;
    }else {
        if (section == 0)
            return self.existingFieldsForTable.count;
        return 0;
    }
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
    if (self.hasCompletedFields == YES){
        if (indexPath.section == 0)
            return [self.detailCells objectAtIndex:indexPath.row][@"cell"];
        return 0;
    } else {
        if (indexPath.section == 0)
            return [self cellForField:[self.existingFieldsForTable objectAtIndex:indexPath.row][@"field"]];
        return 0;
    }
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
    }else if ([field isEqualToString:@"pickupLocation"] || [field isEqualToString:@"destinationLocation"]){
        static NSString *CellIdentifier = @"MapCell";
        
        PostMapTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell setLocationsFromPost:self.post];
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
    [self.getButton setTintColor:[UIColor spreeOffWhite]];
    [self.getButton setTitleColor:[UIColor spreeDarkBlue] forState:UIControlStateHighlighted];
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
    NSLog(@"%@", self.post.user);
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

-(void)organizeTableForFields{
    if (self.hasCompletedFields) {
        for (id field in self.existingFields){
            if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
                NSDictionary *mapCellDictionary;
                for (id dictionary in self.detailCells){
                    if ([dictionary[@"name"] isEqualToString:@"map"]){
                        mapCellDictionary = dictionary;
                    }
                }
                if (!mapCellDictionary){
                    NSString *className = NSStringFromClass([PostMapTableViewCell class]);
                    UINib *nib = [UINib nibWithNibName:className bundle:nil];
                    [self.tableView registerNib:nib forCellReuseIdentifier:@"PostMapTableViewCell"];
                    PostMapTableViewCell *mapCell = [self.tableView dequeueReusableCellWithIdentifier:@"PostMapTableViewCell"];
                    [mapCell setLocationsFromPost:self.post];
                    NSDictionary *dictionary;
                    if (field[@"priority"])
                        dictionary = @{@"name" : @"map", @"cell" : mapCell, @"priority" : field[@"priority"]};
                    else
                        dictionary = @{@"name" : @"map", @"cell" : mapCell, @"priority" : @100};
                    [self.detailCells addObject:dictionary];
                }
            } else if ([field[@"dataType"] isEqualToString:@"string"]){
                if ([field[@"field"] isEqualToString:@"userDescription"]){
                    NSString *className = NSStringFromClass([PostDescriptionTableViewCell class]);
                    UINib *nib = [UINib nibWithNibName:className bundle:nil];
                    [self.tableView registerNib:nib forCellReuseIdentifier:className];
                    PostDescriptionTableViewCell *descriptionCell = [self.tableView dequeueReusableCellWithIdentifier:className];
                    [descriptionCell setDescriptionTextViewForPost:self.post];
                    NSDictionary *dictionary;
                    if (field[@"priority"])
                        dictionary = @{@"name" : @"description", @"cell" : descriptionCell, @"priority" : field[@"priority"]};
                    else
                        dictionary = @{@"name" : @"description", @"cell" : descriptionCell, @"priority" : @100};
                    [self.detailCells addObject:dictionary];
                } else if ([field[@"field"] isEqualToString:@"title"]){
                    NSString *className = NSStringFromClass([PostTitleTableViewCell class]);
                    UINib *nib = [UINib nibWithNibName:className bundle:nil];
                    [self.tableView registerNib:nib forCellReuseIdentifier:className];
                    PostTitleTableViewCell *titleCell = [self.tableView dequeueReusableCellWithIdentifier:className];
                    [titleCell setTitleforPost:self.post];
                    NSDictionary *dictionary;
                    if (field[@"priority"])
                        dictionary = @{@"name" : @"title", @"cell" : titleCell, @"priority" : field[@"priority"]};
                    else
                        dictionary = @{@"name" : @"title", @"cell" : titleCell, @"priority" : @100};
                    [self.detailCells addObject:dictionary];
                } else {
                    UITableViewCell *otherCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"other"];
                    [otherCell.textLabel setText:self.post[field[@"field"]]];
                    NSDictionary *dictionary;
                    if (field[@"priority"])
                        dictionary = @{@"name" : @"other", @"cell" : otherCell, @"priority" : field[@"priority"]};
                    else
                        dictionary = @{@"name" : @"other", @"cell" : otherCell, @"priority" : @100};
                    [self.detailCells addObject:dictionary];
                }
            } else if ([field[@"dataType"] isEqualToString:@"photos"]){
                NSString *className = NSStringFromClass([PhotoGalleryTableViewCell class]);
                UINib *nib = [UINib nibWithNibName:className bundle:nil];
                [self.tableView registerNib:nib forCellReuseIdentifier:className];
                PhotoGalleryTableViewCell *photoCell = [self.tableView dequeueReusableCellWithIdentifier:className];
                [self loadPostImagesForCell:photoCell];
                [photoCell setDateLabelForPost:self.post];
                NSDictionary *dictionary;
                if (field[@"priority"])
                    dictionary = @{@"name" : @"photo", @"cell" : photoCell, @"priority" : field[@"priority"]};
                else
                    dictionary = @{@"name" : @"photo", @"cell" : photoCell, @"priority" : @100};
                [self.detailCells addObject:dictionary];
            }
        }
        [self.detailCells sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    } else {
        for (id field in self.existingFields){
            if (self.post[field[@"field"]]){
                [self.existingFieldsForTable addObject:field];
            }
        }
    }
    [self.tableView reloadData];
}



@end
