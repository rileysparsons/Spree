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
#import "MessagingInputAccessoryView.h"
#import "RatingViewController.h"
#import "PostPaymentViewController.h"
#import "AuthorizeVenmoViewController.h"
#import <Venmo-iOS-SDK/Venmo.h>

#import "common.h"
#import "push.h"
#import "recent.h"

#import "ChatView.h"

typedef enum : NSUInteger {
    kVerifyEmailAlert,
} AlertType;

@interface ChatView() <AuthorizeVenmoViewControllerDelegate, PostPaymentViewControllerDelegate>
{
	NSTimer *timer;
    NSTimer *venmoAuthTimer;
	BOOL isLoading;
	BOOL initialized;
    
    BOOL userVerifiedToSendMessages;

	NSString *groupId;
    NSString *title;
    PFObject *post;

	NSMutableArray *users;
	NSMutableArray *messages;

	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;
    
    MessagingInputAccessoryView *inputAccessoryView;
    
    ChatPostHeader *postHeader;
}

@property (retain, nonatomic) UIBarButtonItem *meetUp;

@end



@implementation ChatView

-(UIBarButtonItem *)meetUp {
    if (!_meetUp) {
        _meetUp = [[UIBarButtonItem alloc] initWithTitle:@"Meet Up" style:UIBarButtonItemStylePlain target:self action:@selector(showMeetUp)];
        [_meetUp setTintColor:[UIColor spreeDarkBlue]];
    }
    return _meetUp;
}


- (id)initWith:(NSString *)groupId_ post:(PFObject *)post_ title:(NSString *)title_
{
    self = [super init];
    groupId = groupId_;
    post = post_;
    title = title_;
    return self;
}

- (void)viewDidLoad
{
    //add button here - quote you 
	[super viewDidLoad];

    self.title = title;

	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];

	PFUser *user = [PFUser currentUser];
    [user fetchInBackground];
	self.senderId = user.objectId;
    self.senderDisplayName = user[@"username"];
    
    if ([[user objectForKey:@"emailVerified"] boolValue]){
        userVerifiedToSendMessages = YES;
    } else {
        userVerifiedToSendMessages = NO;
    }
    
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
    
    if (![[Venmo sharedInstance] isSessionValid] && ![[NSUserDefaults standardUserDefaults] boolForKey:@"PromptedVenmoAuth"]){
        [self presentVenmoAuth];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PromptedVenmoAuth"];
    }
    
    [self setInputAccessoryView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:@"MeetUp" object:nil];
}

- (void)setInputAccessoryView
{

            inputAccessoryView = [[MessagingInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40) withPostType:(SpreePost *)post];
            self.keyboardController.textView.inputAccessoryView = inputAccessoryView;
            [inputAccessoryView.claimButton addTarget:self action:@selector(claimPost) forControlEvents:UIControlEventTouchUpInside];
            [inputAccessoryView.reviewButton addTarget:self action:@selector(reviewUser) forControlEvents:UIControlEventTouchUpInside];
            [inputAccessoryView.buyButton addTarget:self action:@selector(postSold) forControlEvents:UIControlEventTouchUpInside];
            [inputAccessoryView.authorizeVenmo addTarget:self action:@selector(presentVenmoAuth) forControlEvents:UIControlEventTouchUpInside];

}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    self.topContentAdditionalInset = 75.0f;
    [self addCustomPostHeader];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
    [self.keyboardController.textView becomeFirstResponder];
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    venmoAuthTimer  = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkForVenmoAuthorization) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [postHeader removeFromSuperview];
	ClearRecentCounter(groupId);
	[timer invalidate];
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
	NSString *name = user[@"username"];

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
    NSArray *keywords = @[@"yahoo", @"gmail", @"com", @"atyahoo", @"at yahoo", @"at yahoo.com", @"at gmail com", @"atgmail", @"at gmail", @"at gmail.com", @"at gmail com",];
    NSString *blockMessage = @"***";
    

    PFObject *object = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    object[PF_MESSAGE_POST] = post;
    object[PF_MESSAGE_USER] = [PFUser currentUser];
    object[PF_MESSAGE_GROUPID] = groupId;
    
    
    NSRegularExpression *phoneRegex = [NSRegularExpression regularExpressionWithPattern:@"1?\\s*\\W?\\s*([0-9][0-8][0-9])\\s*\\W?\\s*([0-9][0-9]{2})\\s*\\W?\\s*([0-9]{4})(\\se?x?t?(\\d*))?" options:0 error:nil];
    
    NSString *modifiedString = [phoneRegex stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, [text length]) withTemplate:blockMessage];
    
    NSRegularExpression *emailRegex = [NSRegularExpression regularExpressionWithPattern:@"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?" options:0 error:nil];
    
    NSString *outString = [emailRegex stringByReplacingMatchesInString:modifiedString options:0 range:NSMakeRange(0, [modifiedString length]) withTemplate:blockMessage];
    
    for(NSString *key in keywords){
        outString = [outString stringByReplacingOccurrencesOfString:key withString:blockMessage];
    }
    
    object[PF_MESSAGE_TEXT] = outString;
    
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
            CreateRecentItem(user1, groupId, object[@"username"], user2, post, outString);
        }
    }];

    [self performSelector:@selector(updateRecentAndPushForMessage:) withObject:outString afterDelay:0.5f];
    CreateRecentItem(user2, groupId, user1[PF_USER_FULLNAME], user1, post, outString);
    [self finishSendingMessage];
}

-(void) updateRecentAndPushForMessage:(NSString*)message{
    SendPushNotification(groupId, message, [post objectId], title);
    UpdateRecentCounter(groupId, 1, message, post);
}

#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    if ([SpreeUtility checkForEmailVerification]){
        [self sendMessage:text Video:nil Picture:nil];
        [PFAnalytics trackEvent:@"sentMessage"];
    } else {
        UIAlertView *userNotVerified = [[UIAlertView alloc] initWithTitle:@"Unverified Student" message:VERIFY_EMAIL_PROMPT delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Resend email", nil];
        userNotVerified.tag = kVerifyEmailAlert;
        [userNotVerified show];
    }
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
    if (alertView.tag == kVerifyEmailAlert){
        int resendButtonIndex = 1;
        if (resendButtonIndex == buttonIndex){
            //updating the email will force Parse to resend the verification email
            NSString *email = [[PFUser currentUser] objectForKey:@"email"];
            NSLog(@"email: %@",email);
            [[PFUser currentUser] setObject:email forKey:@"email"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error ){
                
                if( succeeded ) {
                    
                    [[PFUser currentUser] setObject:email forKey:@"email"];
                    [[PFUser currentUser] saveInBackground];
                    
                }
                
            }];
        }
    }
}

#pragma mark - Post Actions

-(void)postSold{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PostPaymentViewController *pay = [storyboard instantiateViewControllerWithIdentifier:@"PostPaymentViewController"];
    pay.delegate = self;
    [pay initializeWithPost:(SpreePost *)post];
    [self presentViewController:pay animated:YES completion:nil];
}

-(void)reviewUser{
    NSLog(@"Review the user");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    RatingViewController *rating = [storyboard instantiateViewControllerWithIdentifier:@"rating"];
    rating.post = post;
    UINavigationController *ratingNav = [[UINavigationController alloc] initWithRootViewController:rating];
    [self presentViewController:ratingNav animated:YES completion:nil];
}

-(void)claimPost{
    NSLog(@"I'll take care of this");
}

#pragma mark - Venmo

-(void)presentVenmoAuth{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    AuthorizeVenmoViewController *authVenmo = [storyboard instantiateViewControllerWithIdentifier:@"AuthVenmo"];
    authVenmo.delegate = self;
    [self presentViewController:authVenmo animated:YES completion:nil];
}

-(void)userDidNotAuthorizeVenmo{
    
}

-(void)userDidAuthorizeVenmo{
    [self setInputAccessoryView];
    [self.keyboardController.textView setNeedsDisplay];
}

-(void)userCompletedPurchase{
    NSString *purchaserName = [PFUser currentUser][@"displayName"] ? [SpreeUtility firstNameForDisplayName:[PFUser currentUser][@"displayName"]] : [PFUser currentUser][@"username"];
    NSString *sellerName = post[@"user"][@"displayName"] ? [SpreeUtility firstNameForDisplayName:post[@"user"][@"displayName"]] : post[@"user"][@"username"];
    
    NSString *paymentConfirmation = [NSString stringWithFormat:@"%@ bought %@ from %@", purchaserName, post[@"title"], sellerName];
    [self sendMessage:paymentConfirmation Video:nil Picture:nil];
}

-(void)userFailedToCompletePurchase{
    
}

-(void)checkForVenmoAuthorization{
    [post[@"user"] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error){
            if (post[@"user"][@"venmoId"]){
                [self setInputAccessoryView];
                [venmoAuthTimer invalidate];
            }
        }
    }];
}


@end
