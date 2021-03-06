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

#import "recent.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartPrivateChat(PFUser *user1, PFUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *id1 = user1.objectId;
	NSString *id2 = user2.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groupId;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecentItem(PFUser *user, NSString *groupId, NSString *description, PFUser *toUser, PFObject *post, NSString *firstMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
	[query whereKey:PF_RECENT_USER equalTo:user];
	[query whereKey:PF_RECENT_GROUPID equalTo:groupId];
    [query whereKey:PF_RECENT_POST equalTo:post];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			if ([objects count] == 0)
			{
				PFObject *recent = [PFObject objectWithClassName:PF_RECENT_CLASS_NAME];
				recent[PF_RECENT_USER] = user;
                recent[PF_RECENT_TOUSER] = toUser;
				recent[PF_RECENT_GROUPID] = groupId;
                recent[PF_MESSAGE_POST] = post;
				recent[PF_RECENT_DESCRIPTION] = description;
				recent[PF_RECENT_LASTUSER] = [PFUser currentUser];
				recent[PF_RECENT_LASTMESSAGE] = firstMessage;
				recent[PF_RECENT_COUNTER] = @0;
				recent[PF_RECENT_UPDATEDACTION] = [NSDate date];
				[recent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
					if (error != nil) NSLog(@"CreateRecentItem save error.");
				}];
			}
		}
		else NSLog(@"CreateRecentItem query error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecentCounter(NSString *groupId, NSInteger amount, NSString *lastMessage, PFObject *post)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"Update recent counter");
	PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
	[query whereKey:PF_RECENT_GROUPID equalTo:groupId];
    [query whereKey:PF_MESSAGE_POST equalTo:post];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
        NSLog(@"objects: %lu", (unsigned long)objects.count);
		if (error == nil)
		{
			for (PFObject *recent in objects)
			{
                NSLog(@"objects: %lu", (unsigned long)objects.count);
				PFUser *user = recent[PF_RECENT_USER];
				if ([user.objectId isEqualToString:[PFUser currentUser].objectId] == NO)
					[recent incrementKey:PF_RECENT_COUNTER byAmount:[NSNumber numberWithInteger:amount]];
				//---------------------------------------------------------------------------------------------------------------------------------
				recent[PF_RECENT_LASTUSER] = [PFUser currentUser];
				recent[PF_RECENT_LASTMESSAGE] = lastMessage;
				recent[PF_RECENT_UPDATEDACTION] = [NSDate date];
				[recent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
					if (error != nil) NSLog(@"UpdateRecentCounter save error.");
				}];
			}
		}
		else NSLog(@"UpdateRecentCounter query error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounter(NSString *groupId)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
	[query whereKey:PF_RECENT_GROUPID equalTo:groupId];
	[query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			for (PFObject *recent in objects)
			{
				recent[PF_RECENT_COUNTER] = @0;
				[recent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
					if (error != nil) NSLog(@"ClearRecentCounter save error.");
				}];
			}
		}
		else NSLog(@"ClearRecentCounter query error.");
	}];
}
