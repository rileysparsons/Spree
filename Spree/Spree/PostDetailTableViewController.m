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
#import "PostMessageTableViewCell.h"
#import "ProfileViewController.h"
#import "DoublePhotoPostShareView.h"
#import "SinglePhotoPostShareView.h"
#import "TriplePhotoPostShareView.h"
#import "ChatView.h"
#import "common.h"
#import "ChatView.h"
#import "recent.h"
#import <YHRoundBorderedButton.h>



@interface PostDetailTableViewController ()

@property BOOL currentUserPost;

@end

@implementation PostDetailTableViewController

-(void)initWithPost:(SpreePost *)post{
    self.post = post;
    self.existingFieldsForTable = [[NSMutableArray alloc] init]; // Existing Fields Will Hold Dictionaries Representing Cell Data Once Filtered.
    
    if (self.post[@"completedFields"]){ // This check ensures that posts made before August 2015 will still be able to be opened
        self.existingFields = self.post[@"completedFields"];
        self.hasCompletedFields = YES;
        [self organizeTableForFields]; // This removes fields from completed fields that will not be shown as cells in the table view
    } else {
        [self.post.typePointer fetchIfNeededInBackgroundWithBlock:^(PFObject *type, NSError *error){
            self.existingFields = self.post.typePointer[@"fields"];
            [self organizeTableForFields];
            [self.tableView reloadData];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    NSLog(@"Post %@", self.post);
    
    // Table View Set up
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.backgroundColor = [UIColor spreeOffWhite];
    
    // View Set Up
    self.view.backgroundColor = [UIColor spreeOffWhite];

    [self.post.typePointer fetchIfNeededInBackgroundWithTarget:self selector:@selector(setupTitle)]; // Sets up the custom title view based on the type of the post
    
    [self getUserForPost];
    
    // Navigation bar UI
    [self addCustomBackButton];

    
    [self updatePostStatus];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.existingFieldsForTable.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *selectedField = [self.existingFieldsForTable objectAtIndex:indexPath.row];
    if ([selectedField[@"field"]isEqualToString:@"profile"]){
        ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
        profileViewController.detailUser = self.poster;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasCompletedFields == YES){
        if (indexPath.section == 0)
            return [self cellForField:[self.existingFieldsForTable objectAtIndex:indexPath.row]];
        return 0;
    } else {
        if (indexPath.section == 0)
            return [self cellForOldField:[self.existingFieldsForTable objectAtIndex:indexPath.row][@"field"]]; // This method takes a string value for the field and returns cells.
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:self.post.createdAt];
    NSString *fullDateString = [NSString stringWithFormat:@"Posted on %@", dateString];
    label.font = [UIFont fontWithName:@"Lato-Regular" size:16];
    label.textColor = [UIColor spreeOffBlack];
    label.text = fullDateString;
    [label setFrame:CGRectMake(8, 8, footerView.frame.size.width, 30)];
    
    [footerView addSubview:label];
    
    return footerView;
}

# pragma mark - Cell Producing Methods

-(UITableViewCell *)cellForOldField:(NSString *)field {
    
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
        [cell setupPriceLabelForPost:self.post];
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
    } else if ([field isEqualToString:@"profile"]){
        NSString *className = NSStringFromClass([PostUserTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:className];
        PostUserTableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:className];
        [userCell setUserLabelForPost:self.post];
        return userCell;
    } else if ([field isEqualToString:@"message"]){
        NSString *className = NSStringFromClass([PostMessageTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:className];
        PostMessageTableViewCell *messageCell = [self.tableView dequeueReusableCellWithIdentifier:className];
        [messageCell.messageButton addTarget:self action:@selector(messageButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [messageCell setMessageButtonForPost:self.post];
        return messageCell;
    }
    
    static NSString *CellIdentifier = @"DefaultCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    return cell;
}

-(UITableViewCell *)cellForField:(NSDictionary *)field {
    if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
        NSString *className = NSStringFromClass([PostMapTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"PostMapTableViewCell"];
        PostMapTableViewCell *mapCell = [self.tableView dequeueReusableCellWithIdentifier:@"PostMapTableViewCell"];
        [mapCell setLocationsFromPost:self.post];
        return mapCell;
    } else if ([field[@"dataType"] isEqualToString:@"string"]){
        if ([field[@"field"] isEqualToString:@"userDescription"]){
            NSString *className = NSStringFromClass([PostDescriptionTableViewCell class]);
            UINib *nib = [UINib nibWithNibName:className bundle:nil];
            [self.tableView registerNib:nib forCellReuseIdentifier:className];
            PostDescriptionTableViewCell *descriptionCell = [self.tableView dequeueReusableCellWithIdentifier:className];
            [descriptionCell setDescriptionTextViewForPost:self.post];
            return descriptionCell;
        } else{
            UITableViewCell *otherCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"other"];
            [otherCell setBackgroundColor:[UIColor spreeOffWhite]];
            otherCell.textLabel.textColor = [UIColor spreeOffBlack];
            otherCell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:18];
            [otherCell.textLabel setText:self.post[field[@"field"]]];
            return otherCell;
        }
    } else if ([field[@"dataType"] isEqualToString:@"image"]){
        NSString *className = NSStringFromClass([PhotoGalleryTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:className];
        PhotoGalleryTableViewCell *photoCell = [self.tableView dequeueReusableCellWithIdentifier:className];
        [photoCell setDateLabelForPost:self.post];
        [photoCell setupPriceLabelForPost:self.post];
        
        [self loadPostImagesForCell:photoCell];
        return photoCell;
    } else if ([field[@"dataType"] isEqualToString:@"date"]){
        UITableViewCell *dateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"other"];
        [dateCell setBackgroundColor:[UIColor spreeOffWhite]];
        dateCell.textLabel.textColor = [UIColor spreeOffBlack];
        dateCell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:18];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mma"];
        NSString *dateString = [dateFormatter stringFromDate:self.post[field[@"field"]]];
        [dateCell.textLabel setText:dateString];
        return dateCell;
    } else if ([field[@"field"] isEqualToString:@"profile"]){
        NSString *className = NSStringFromClass([PostUserTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:className];
        PostUserTableViewCell *userCell = [self.tableView dequeueReusableCellWithIdentifier:className];
        [userCell setUserLabelForPost:self.post];
        return userCell;
    }else if ([field[@"field"] isEqualToString:@"message"]){
        NSString *className = NSStringFromClass([PostMessageTableViewCell class]);
        UINib *nib = [UINib nibWithNibName:className bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:className];
        PostMessageTableViewCell *messageCell = [self.tableView dequeueReusableCellWithIdentifier:className];
        [messageCell.messageButton addTarget:self action:@selector(messageButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        [messageCell setMessageButtonForPost:self.post];
        return messageCell;
    }
    return 0;
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

#pragma mark - Opening Chat

-(void)messageButtonTouched{
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
            UIBarButtonItem *userControlButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(userControlButtonTouched)];
            UIFont *f1 = [UIFont fontWithName:@"Lato-Regular" size:18];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:f1, NSFontAttributeName, nil]; [userControlButton setTitleTextAttributes:dict forState:UIControlStateNormal];
            
            UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTouched)];
            self.navigationItem.rightBarButtonItem = shareButton;
            self.navigationItem.rightBarButtonItems = @[shareButton, userControlButton];
        }
    } else {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTouched)];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
}

#pragma mark - Organizing Data

-(void)organizeTableForFields{
    for (id field in self.existingFields){
        if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
            [self.existingFieldsForTable addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"string"] && ![field[@"field"] isEqualToString:@"title"]){
            [self.existingFieldsForTable addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"image"]){
            [self.existingFieldsForTable addObject:field];
        }
    }
    [self.existingFieldsForTable sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]]; // Most field dictionaries stored on the backend hold a priority key value pair that indicates where they should appear in a table view.
    [self addOtherRowsForTable]; // This call inserts other placeholder cells not present in the "existingFields" property.
}

// This adds a placeholder dictionary for cells that will be displayed, but were not present in the completed fields dictionary

-(void)addOtherRowsForTable{
    NSDictionary *profileField = @{
                                   @"field" : @"profile" // This holds a place for the profile cell
                                   };
    NSDictionary *messageField = @{
                                   @"field" : @"message" // This holds a place for the cell that will contain the message button
                                   };
    [self.existingFieldsForTable insertObject:profileField atIndex:1];
    [self.existingFieldsForTable insertObject:messageField atIndex:2];
}



-(void)setupTitle{

    CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, 200, 44);
    UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    _headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    _headerTitleSubtitleView.autoresizesSubviews = YES;
    
    CGRect titleFrame = CGRectMake(0, 2, 200, 24);
    UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont fontWithName:@"Lato-Regular" size:17];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor spreeOffBlack];
    titleView.text = self.post.title;
    titleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:titleView];
    
    CGRect subtitleFrame = CGRectMake(0, 24, 200, 44-24);
    UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    subtitleView.backgroundColor = [UIColor clearColor];
    subtitleView.font = [UIFont fontWithName:@"Lato-Regular" size:12];
    subtitleView.textAlignment = NSTextAlignmentCenter;
    subtitleView.textColor = [UIColor spreeOffBlack];
    subtitleView.text = self.post.typePointer[@"type"];
    subtitleView.text = [subtitleView.text uppercaseString];
    subtitleView.adjustsFontSizeToFitWidth = YES;
    [_headerTitleSubtitleView addSubview:subtitleView];
    
    _headerTitleSubtitleView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                 UIViewAutoresizingFlexibleRightMargin |
                                                 UIViewAutoresizingFlexibleTopMargin |
                                                 UIViewAutoresizingFlexibleBottomMargin);
    
    self.navigationItem.titleView = _headerTitleSubtitleView;
}


-(void)addCustomBackButton{
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    back.backgroundColor = [UIColor clearColor];
    back.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [back setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [back setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [back addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
}

-(void)getUserForPost{
    
    if (([[(PFUser *)self.post.user objectId] isEqualToString: [[PFUser currentUser] objectId]])){
        self.poster = [PFUser currentUser];
        self.currentUserPost = YES;
        [self updatePostStatus];
    } else {
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:self.post.user.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            self.poster = (PFUser *)object;
        }];
    }
}

#pragma mark - Share Function

-(void)shareButtonTouched{
    if (self.post.photoArray.count > 0){
        if (self.post.photoArray.count == 1){
            SinglePhotoPostShareView *shareView = [[SinglePhotoPostShareView alloc] initWithFrame:CGRectMake(0, 0, 504, 504)];
            shareView.delegate = self;
            [shareView initWithPost:self.post];
        } else if (self.post.photoArray.count == 2){
            DoublePhotoPostShareView *shareView = [[DoublePhotoPostShareView alloc] initWithFrame:CGRectMake(0, 0, 504, 504)];
            shareView.delegate = self;
            [shareView initWithPost:self.post];
        } else if (self.post.photoArray.count == 3){
            TriplePhotoPostShareView *shareView = [[TriplePhotoPostShareView alloc] initWithFrame:CGRectMake(0, 0, 504, 504)];
            shareView.delegate = self;
            [shareView initWithPost:self.post];
        }
    }else if (self.post[@"location"]){
        SinglePhotoPostShareView *shareView = [[SinglePhotoPostShareView alloc] initWithFrame:CGRectMake(0, 0, 504, 504)];
        shareView.delegate = self;
        [shareView initWithPost:self.post];
    }
}

-(void)viewInitializedForPost:(PostShareView *)view{
    UIImage *image = [view captureView];
    [self presentActivityViewWithImage:image];
}

-(void)presentActivityViewWithImage:(UIImage *)image{
    
    NSString *shareString = [NSString stringWithFormat:@"Check out this post on Spree!"];
    // This will contain the link to the post via branch.
    
    NSArray *excludedTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFlickr, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypePostToTencentWeibo];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareString, image]
                                      applicationActivities:nil];
    activityViewController.excludedActivityTypes = excludedTypes;
    [self.navigationController presentViewController:activityViewController
                                    animated:YES
                                     completion:^{
                                         
                                     }];
}



@end
