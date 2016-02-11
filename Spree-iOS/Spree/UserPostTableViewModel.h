//
//  UserPostTableViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 2/10/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PostTableViewModel.h"

@interface UserPostTableViewModel : PostTableViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services user:(PFUser *)user params:(NSDictionary *)params;


@end
