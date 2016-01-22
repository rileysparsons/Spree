//
//  SelectPostSubTypeViewModel.h
//  
//
//  Created by Riley Steele Parsons on 1/21/16.
//
//

#import <ReactiveViewModel/RVMViewModel.h>
#import "SpreeViewModelServices.h"

@interface SelectPostSubTypeViewModel : RVMViewModel

@property RACCommand* typeSelectedCommand;
@property PFObject *postSubTypes;

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services type:(PFObject *)type;

@end
