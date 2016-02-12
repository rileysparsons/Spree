//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "UIColor+SpreeColor.h"
#import "MeetUpViewController.h"
#import "ChatPostHeader.h"
#import "SpreeUtility.h"
#import "RatingViewController.h"
#import "PostPaymentViewController.h"
#import "common.h"
#import "push.h"
#import "recent.h"

#import "ChatView.h"

typedef enum : NSUInteger {
    kVerifySaleAlert
} AlertType;

@interface ChatView() <PostPaymentViewControllerDelegate>
{
	NSTimer *timer;
    NSTimer *refreshOfferTimer;
    
	BOOL isLoading;
	BOOL initialized;
    
    BOOL userVerifiedToSendMessages;

	NSString *groupId;
    NSString *title;
    PFObject *post;

    PFObject *currentOffer;
    
	NSMutableArray *users;
	NSMutableArray *messages;

	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;
    
    ChatPostHeader *postHeader;
}

@property (retain, nonatomic) UIBarButtonItem *meetUp;

@property (retain, nonatomic) UIButton *claimButton;
@property (retain, nonatomic) UIButton *buyButton;
@property (retain, nonatomic) UIButton *reviewButton;
@property (retain, nonatomic) UIButton *payForTaskButton;
@property (retain, nonatomic) UIButton *acceptOfferButton;

@end



@implementation ChatView

-(UIBarButtonItem *)meetUp {
    if (!_meetUp) {
        _meetUp = [[UIBarButtonItem alloc] initWithTitle:@"Meet Up" style:UIBarButtonItemStylePlain target:self action:@selector(showMeetUp)];
        [_meetUp setTintColor:[UIColor spreeDarkBlue]];
    }
    return _meetUp;
}

-(UIButton *)acceptOfferButton {
    if (!_acceptOfferButton) {
        _acceptOfferButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _acceptOfferButton.backgroundColor = [UIColor spreeDarkBlue];
        [_acceptOfferButton setTitle:@"Respond to Offer" forState:UIControlStateNormal];
        _acceptOfferButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
        _acceptOfferButton.titleLabel.textColor = [UIColor spreeOffWhite];
        [_acceptOfferButton addTarget:self action:@selector(acceptOffer) forControlEvents:UIControlEventTouchUpInside];
    }
    return _acceptOfferButton;
}

-(UIButton *)claimButton {
    if (!_claimButton) {
        _claimButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _claimButton.backgroundColor = [UIColor spreeDarkBlue];
        _claimButton.titleLabel.text = @"Claim Task";
        [_claimButton setTitle:@"Claim Task" forState:UIControlStateNormal];
        _claimButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
        _claimButton.titleLabel.textColor = [UIColor spreeOffWhite];
        [_claimButton addTarget:self action:@selector(claimPost) forControlEvents:UIControlEventTouchUpInside];
    }
    return _claimButton;
}

-(UIButton *)buyButton {
    if (!_buyButton) {
        _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _buyButton.backgroundColor = [UIColor spreeDarkBlue];
        [_buyButton setTitle:@"Buy Post" forState:UIControlStateNormal];
        _buyButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
        _buyButton.titleLabel.textColor = [UIColor spreeOffWhite];
        [_buyButton addTarget:self action:@selector(buyPost) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buyButton;
}

-(UIButton *)reviewButton {
    if (!_reviewButton) {
        _reviewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _reviewButton.backgroundColor = [UIColor spreeDarkBlue];
        [_reviewButton setTitle:@"Review" forState:UIControlStateNormal];
        _reviewButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
        _reviewButton.titleLabel.textColor = [UIColor spreeOffWhite];
        [_reviewButton addTarget:self action:@selector(reviewUser) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reviewButton;
}

-(UIButton *)payForTaskButton {
    if (!_payForTaskButton) {
        _payForTaskButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        _payForTaskButton.backgroundColor = [UIColor spreeDarkBlue];
        [_payForTaskButton setTitle:@"Pay For Task" forState:UIControlStateNormal];
        _payForTaskButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:18];
        _payForTaskButton.titleLabel.textColor = [UIColor spreeOffWhite];
        [_payForTaskButton addTarget:self action:@selector(payForTask) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payForTaskButton;
}

- (id)initWith:(NSString *)groupId_ post:(PFObject *)post_ title:(NSString *)title_
{
    self = [super init];
    groupId = groupId_;
    post = post_;
    title = title_;
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshInputAccessoryView];
    
}

- (void)viewDidLoad
{
    //add button here - quote you 
	[super viewDidLoad];

    self.title = title;
    
    UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(0,0, 150, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor=[UIColor spreeOffBlack];
    titleLabel.font = [UIFont fontWithName:@"Lato-Regular" size: 18.0];
    titleLabel.backgroundColor =[UIColor clearColor];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    titleLabel.text = self.title;
    self.navigationItem.titleView=titleLabel;

	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    back.backgroundColor = [UIColor clearColor];
    back.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [back setImage:[UIImage imageNamed:@"backNormal_Dark"] forState:UIControlStateNormal];
    [back setImage:[UIImage imageNamed:@"backHighlight_Dark"] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
	PFUser *user = [PFUser currentUser];
    [user fetchInBackground];
	self.senderId = user.objectId;
    self.senderDisplayName = user[@"username"];
    
    if ([[user objectForKey:@"emailVerified"] boolValue]){
        userVerifiedToSendMessages = YES;
    } else {
        userVerifiedToSendMessages = NO;
    }
    
    [self refreshInputAccessoryView];
    
    self.keyboardController.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.navigationItem.rightBarButtonItem = self.meetUp;
    
	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor spreeDarkBlue]];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:COLOR_INCOMING];

    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    // Appearance
    
    self.view.backgroundColor = [UIColor spreeOffWhite];
    self.collectionView.backgroundColor = [UIColor spreeOffWhite];
    
    // Disable the attachments
    self.inputToolbar.contentView.leftBarButtonItem = nil;

	isLoading = NO;
	initialized = NO;

	[self loadMessages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:@"MeetUp" object:nil];
}

-(void)refreshInputAccessoryView{

    // This is not the user's own post (i.e. they are the buyer, not the seller)
    if (![[[post objectForKey:@"user"] objectId]
          isEqualToString:[PFUser currentUser].objectId]){
        if ([post[@"typePointer"][@"type"] isEqualToString:@"Tasks & Services"]){
            if (post[@"sold"] == [NSNumber numberWithBool:NO]){
                if (post[@"taskClaimed"] == [NSNumber numberWithBool:YES]){
                    self.keyboardController.textView.inputAccessoryView = nil;
                } else {
                    self.keyboardController.textView.inputAccessoryView = [self claimButton];
                }
            } else {
                self.keyboardController.textView.inputAccessoryView = nil;
            }
            [self.keyboardController.textView reloadInputViews];
        } else {
            if (post[@"sold"] == [NSNumber numberWithBool:NO]){
                
                PFQuery *query = [PFQuery queryWithClassName:@"PaymentQueue"];
                [query whereKey:@"post" equalTo:post];
                [query whereKey:@"buyer" equalTo:[PFUser currentUser]];
                [query whereKey:@"seller" equalTo:self.toUser];
                
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                    if (object){
                        self.keyboardController.textView.inputAccessoryView = nil;
                    } else {
                         self.keyboardController.textView.inputAccessoryView = [self buyButton];
                    }
                    [self.keyboardController.textView reloadInputViews];
                }];
                
            } else {
                self.keyboardController.textView.inputAccessoryView = nil;
                [self.keyboardController.textView reloadInputViews];
                // In the future implement the review button
            }
        }
        [self.keyboardController.textView.inputAccessoryView setNeedsDisplay];
    } else {
        
        // This post is the user's own post (i.e. they are the seller)
        PFQuery *query = [PFQuery queryWithClassName:@"PaymentQueue"];
        [query whereKey:@"post" equalTo:post];
        [query whereKey:@"buyer" equalTo:self.toUser];
        [query whereKey:@"seller" equalTo:[PFUser currentUser]];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (object){
                NSLog(@"Offer exists");
                currentOffer = object;
                self.keyboardController.textView.inputAccessoryView = [self acceptOfferButton];
            } else {
                if ([post[@"typePointer"][@"type"] isEqualToString:@"Tasks & Services"]){
                    if (post[@"taskClaimed"] == [NSNumber numberWithBool:YES]){
                        if (post[@"sold"] == [NSNumber numberWithBool:NO])
                            self.keyboardController.textView.inputAccessoryView = [self payForTaskButton];
                        else
                            self.keyboardController.textView.inputAccessoryView = nil;
                    } else {
                        self.keyboardController.textView.inputAccessoryView = nil;
                    }
                } else {
                    self.keyboardController.textView.inputAccessoryView = nil;
                } 
            }
            [self.keyboardController.textView reloadInputViews];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    self.topContentAdditionalInset = 75.0f;
    [self addCustomPostHeader];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
    [self.keyboardController.textView becomeFirstResponder];
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    refreshOfferTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refreshInputAccessoryView) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [postHeader removeFromSuperview];
	ClearRecentCounter(groupId);
	[timer invalidate];
    [refreshOfferTimer invalidate];
}

#pragma mark - Backend methods
- (void)loadMessages
{
	if (isLoading == NO)
	{
		isLoading = YES;
		JSQMessage *message_last = [messages lastObject];

		PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
		[query whereKey:PF_MESSAGE_GROUPID equalTo:groupId];
        [query whereKey:PF_MESSAGE_POST equalTo:post];
		if (message_last != nil) [query whereKey:PF_MESSAGE_CREATEDAT greaterThan:message_last.date];
		[query includeKey:PF_MESSAGE_USER];
		[query orderByDescending:PF_MESSAGE_CREATEDAT];
		[query setLimit:50];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				BOOL incoming = NO;
				self.automaticallyScrollsToMostRecentMessage = NO;
				for (PFObject *object in [objects reverseObjectEnumerator])
				{
					JSQMessage *message = [self addMessage:object];
					if ([self incoming:message]) incoming = YES;
				}
				if ([objects count] != 0)
				{
					if (initialized && incoming)
						[JSQSystemSoundPlayer jsq_playMessageReceivedSound];
					[self finishReceivingMessage];
					[self scrollToBottomAnimated:NO];
				}
				self.automaticallyScrollsToMostRecentMessage = YES;
				initialized = YES;
			}
			isLoading = NO;
		}];
	}
}

- (JSQMessage *)addMessage:(PFObject *)object
{
	JSQMessage *message;
	PFUser *user = object[PF_MESSAGE_USER];
	NSString *name = self.title;

    message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_MESSAGE_TEXT]];

    [users addObject:user];
	[messages addObject:message];

	return message;
}

- (void)sendMessage:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture
{
    /*Phone number REGEX:
     (XXX)XXX-XXXX
     (XXX)XXXXXXX
     XXX-XXX-XXXX
     XXX XXX XXXX
     XXX.XXX.XXXX
     XXXXXXXXXX
     */
    //Email REGEX: name@host.ext
    //List of keywords to be filtered
//    NSArray *keywords = @[@"yahoo", @"gmail", @"com", @"atyahoo", @"at yahoo", @"at yahoo.com", @"at gmail com", @"atgmail", @"at gmail", @"at gmail.com", @"at gmail com",];
//    NSString *blockMessage = @"***";
//    
//
    PFObject *object = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    object[PF_MESSAGE_POST] = post;
    object[PF_MESSAGE_USER] = [PFUser currentUser];
    object[PF_MESSAGE_GROUPID] = groupId;
//
//    
//    NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"1?\\s*\\W?\\s*([0-9][0-8][0-9])\\s*\\W?\\s*([0-9][0-9]{2})\\s*\\W?\\s*([0-9]{4})(\\se?x?t?(\\d*))?" options:0 error:nil];
//    
//    NSString *modifiedString = [phoneRegex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:blockMessage];
    
    // Taken out so messages go through
//    NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:@"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?" options:0 error:nil];
    
//    NSString *outString = [emailRegex stringByReplacingMatchesInString:modifiedString options:0 range:NSMakeRange(0, [modifiedString length]) withTemplate:blockMessage];
    
//    for(NSString *key in keywords){
//        modifiedString = [modifiedString stringByReplacingOccurrencesOfString:key withString:blockMessage];
//    }
    
    object[PF_MESSAGE_TEXT] = text;
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [self loadMessages];
         }
     }];
    
    //Set users for message by current user and post assosiated name
    PFUser *user1= [PFUser currentUser];
    PFUser *user2= [post objectForKey:@"user"];

    PFQuery *lookUp = [PFUser query];
    
    [lookUp whereKey:@"objectId" equalTo:[[post objectForKey:@"user"] objectId]];
    [lookUp getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            CreateRecentItem(user1, groupId, object[@"username"], user2, post, text);
        }
    }];

    [self performSelector:@selector(updateRecentAndPushForMessage:) withObject:text afterDelay:0.5f];
    CreateRecentItem(user2, groupId, user1[PF_USER_FULLNAME], user1, post, text);
    [self finishSendingMessage];
}

-(void) updateRecentAndPushForMessage:(NSString*)message{
    SendPushNotification(groupId, message, [post objectId], title);
    UpdateRecentCounter(groupId, 1, message, post);
}

#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [self sendMessage:text Video:nil Picture:nil];
    [PFAnalytics trackEvent:@"sentMessage"];
    
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return messages[indexPath.item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		return bubbleImageOutgoing;
	}
	else return bubbleImageIncoming;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = messages[indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return nil;
			}
		}
		return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

	if ([self outgoing:messages[indexPath.item]])
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	else
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return 0;
			}
		}
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapAvatarImageView");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    // Not supporting media
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)incoming:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == NO);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)outgoing:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == YES);
}

-(void)showMeetUp{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MeetUpViewController *meetUpView = [storyboard instantiateViewControllerWithIdentifier:@"meetUp"];
    meetUpView.groupId = groupId;
    meetUpView.chatTitle = title;
    meetUpView.post = post;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:meetUpView];
    [self presentViewController:navigationController animated:YES completion:NULL];
    [PFAnalytics trackEvent:@"openMeetUp"];
    
}

-(void)addCustomPostHeader{

    postHeader = [[ChatPostHeader alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 75)];
    
    NSLog(@"POST WIDTH %f", postHeader.frame.size.width);
    [postHeader setupForPost:(SpreePost *)post];
    
    [postHeader setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:postHeader];
    NSLayoutConstraint *makeWidthTheSameAsSuper =[NSLayoutConstraint
                                                       constraintWithItem:postHeader
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:0
                                                       toItem:self.view
                                                       attribute:NSLayoutAttributeWidth
                                                       multiplier:1.0
                                                       constant:0];
    NSLayoutConstraint *topConstraint =[NSLayoutConstraint
                                                  constraintWithItem:postHeader
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:0
                                                  toItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                  multiplier:1.0
                                                  constant:64];
    
    
    [self.view addConstraint:makeWidthTheSameAsSuper];
    [self.view addConstraint:topConstraint];
    [self.view bringSubviewToFront:postHeader];
    
    [self.view layoutIfNeeded];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kVerifySaleAlert){
        if (buttonIndex == 0){
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            [self sendMessage:@"Offer has been declined." Video:nil Picture:nil];
        } else {
            if (currentOffer){
                [self sendMessage:@"Offer has been accepted." Video:nil Picture:nil];
                [post setObject:[NSNumber numberWithBool:YES] forKey:@"sold"];
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (!error){
                        [self reviewUser];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTable" object:nil];
                    }
                }];
            }
        }
        [self refreshInputAccessoryView];
        [currentOffer deleteInBackgroundWithTarget:self selector:@selector(refreshInputAccessoryView)];
    }
}

#pragma mark - Post Actions

-(void)buyPost{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PostPaymentViewController *pay = [storyboard instantiateViewControllerWithIdentifier:@"PostPaymentViewController"];
    pay.delegate = self;
    [pay initializeWithPost:(SpreePost *)post];
    [self presentViewController:pay animated:YES completion:nil];
    [self refreshInputAccessoryView];
}

-(void)reviewUser{
    NSLog(@"Review the user");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    RatingViewController *rating = [storyboard instantiateViewControllerWithIdentifier:@"rating"];
    rating.post = post;
    rating.user = self.toUser;

    rating.ratingType = @"seller";

    [self presentViewController:rating animated:YES completion:nil];
    
    [self refreshInputAccessoryView];
}

-(void)claimPost{
    NSLog(@"I'll take care of this");
    NSString *claimerName = [PFUser currentUser][@"displayName"] ? [SpreeUtility firstNameForDisplayName:[PFUser currentUser][@"displayName"]] : [PFUser currentUser][@"username"];
    [self sendMessage:[NSString stringWithFormat:@"%@ claimed this task!", claimerName] Video:nil Picture:nil];
    [(SpreePost *)post setTaskClaimed:YES];
    [(SpreePost *)post setTaskClaimedBy:[PFUser currentUser]];
    [post saveInBackground];
    NSLog(@"claimed ? %@", post[@"taskClaimed"]);
    [self refreshInputAccessoryView];
}

-(void)userOffered:(PFObject *)offer{
    currentOffer = offer;
    NSString *purchaserName = [PFUser currentUser][@"displayName"] ? [SpreeUtility firstNameForDisplayName:[PFUser currentUser][@"displayName"]] : [PFUser currentUser][@"username"];

    NSString *paymentConfirmation;

    paymentConfirmation = [NSString stringWithFormat:@"%@ offered $%@", purchaserName, (NSString *)[offer[@"offer"] stringValue]];
    
    [self sendMessage:paymentConfirmation Video:nil Picture:nil];
    [self refreshInputAccessoryView];
}

-(void)userFailedToCompletePurchase{
    
}

-(void)userPaidForService:(SpreePost*)service{
    post = service;
    
    NSString *purchaserName = [PFUser currentUser][@"displayName"] ? [SpreeUtility firstNameForDisplayName:[PFUser currentUser][@"displayName"]] : [PFUser currentUser][@"username"];
    
    NSString *paymentConfirmation;
    
    paymentConfirmation = [NSString stringWithFormat:@"%@ paid for the completed service.", purchaserName];
    
    [self sendMessage:paymentConfirmation Video:nil Picture:nil];
    
    [self reviewUser];
    
    [self refreshInputAccessoryView];
}

-(void)backButtonTouched{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)payForTask{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PostPaymentViewController *pay = [storyboard instantiateViewControllerWithIdentifier:@"PostPaymentViewController"];
    pay.delegate = self;
    [pay initializeWithPost:(SpreePost *)post];
    [self presentViewController:pay animated:YES completion:nil];
    [self refreshInputAccessoryView];
}

-(void)acceptOffer{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Accept Offer?" message:@"Selecting yes will remove your item from sale and completes the transaction. It is your responsibility to deliver the item to the buyer." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = kVerifySaleAlert;
    [alertView show];
}


@end
