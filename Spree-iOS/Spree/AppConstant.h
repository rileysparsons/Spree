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

typedef enum {
    SpreeCampusTabBarItemIndex = 0,
    SpreeBrowseTabBarItemIndex = 1,
    SpreeNotificationTabBarItemIndex = 2,
    SpreeMeTabBarItemIndex = 3
} SpreeTabBarControllerViewControllerIndex;

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]

#define		DEFAULT_TAB							3

#define		COLOR_OUTGOING						HEXCOLOR(0x007AFFFF)
#define		COLOR_INCOMING						HEXCOLOR(0xE6E5EAFF)

#define		PF_INSTALLATION_CLASS_NAME			@"_Installation"		//	Class name
#define		PF_INSTALLATION_OBJECTID			@"objectId"				//	String
#define		PF_INSTALLATION_USER				@"user"					//	Pointer to User Class

#define		PF_USER_CLASS_NAME					@"_User"				//	Class name
#define		PF_USER_OBJECTID					@"objectId"				//	String
#define		PF_USER_USERNAME					@"username"				//	String
#define		PF_USER_PASSWORD					@"password"				//	String
#define		PF_USER_EMAIL						@"email"				//	String
#define		PF_USER_EMAILCOPY					@"emailCopy"			//	String
#define		PF_USER_FULLNAME					@"username"				//	String
#define		PF_USER_FULLNAME_LOWER				@"fullname_lower"		//	String
#define     PF_USER_FACEBOOK_ID                 @"fbId"                 //  String
#define     PF_USER_PROFILE_PICTURE_SMALL       @"profilePictureSmall"
#define     PF_USER_PROFILE_PICTURE_MEDIUM      @"profilePictureMedium"

#define		PF_MESSAGE_CLASS_NAME				@"Message"				//	Class name
#define		PF_MESSAGE_USER						@"user"					//	Pointer to User Class
#define		PF_MESSAGE_GROUPID					@"groupId"				//	String
#define		PF_MESSAGE_TEXT						@"text"					//	String
#define		PF_MESSAGE_CREATEDAT				@"createdAt"			//	Date
#define		PF_MESSAGE_POST                     @"post"                 //	Pointer to Post Class

#define		PF_RECENT_CLASS_NAME				@"Recent"				//	Class name
#define		PF_RECENT_USER						@"user"					//	Pointer to User Class
#define		PF_RECENT_GROUPID					@"groupId"				//	String
#define		PF_RECENT_DESCRIPTION				@"description"			//	String
#define		PF_RECENT_LASTUSER					@"lastUser"				//	Pointer to User Class
#define		PF_RECENT_TOUSER					@"toUser"				//	Pointer to User Class
#define		PF_RECENT_LASTMESSAGE				@"lastMessage"			//	String
#define		PF_RECENT_COUNTER					@"counter"				//	Number
#define		PF_RECENT_UPDATEDACTION				@"updatedAction"		//	Date
#define		PF_RECENT_POST                      @"post"                 //	Pointer to Post Class

#define     PF_POST_TITLE                       @"title"                //  String
#define     PF_POST_PRICE                       @"price"                //  Number
#define     PF_POST_DESCRIPTION                 @"userDescription"      //  String
#define     PF_POST_TYPE                        @"type"                 //  String
#define     PF_POST_BOOKFORCLASS                @"bookForClass"         //  String
#define     PF_POST_EVENTDATE                   @"eventDate"            //  String
#define     PF_POST_DATEFOREVENT                @"dateForEvent"         //  Date
#define     PF_POST_PHOTOARRAY                  @"photoArray"           //  Array
#define     PF_POST_USER                        @"user"                 //  Pointer to User Class
#define     PF_POST_EVENT                       @"event"                //  String
#define     PF_POST_TYPEPOINTER                 @"typePointer"          //  Pointer to PostType Class

#define     POST_TYPE_BOOKS                     @"Books"
#define     POST_TYPE_ELECTRONICS               @"Electronics"
#define     POST_TYPE_CLOTHING                  @"Clothing"
#define     POST_TYPE_FURNITURE                 @"Furniture"
#define     POST_TYPE_TICKETS                   @"Tickets"
#define     POST_TYPE_TASKSANDSERVICES          @"Tasks & Services"
#define     POST_TYPE_KITCHEN                   @"Kitchen"
#define     POST_TYPE_WHEELS                    @"Wheels"
#define     POST_TYPE_SPORTS                    @"Sports"
#define     POST_TYPE_OUTDOORS                  @"Outdoors"
#define     POST_TYPE_ACCESSORIES               @"Accessories"


#define		NOTIFICATION_APP_STARTED			@"NCAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NCUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NCUserLoggedOut"

#define     POST_VIEW_DESCRIPTION               @"Add description..."
#define     POST_VIEW_TITLE                     @"Add title..."


