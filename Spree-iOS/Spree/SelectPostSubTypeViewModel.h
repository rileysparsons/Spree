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

@property RACCommand* subTypeSelectedCommand;
@property PFObject *postSubTypes;
@property BOOL isLoading;

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services type:(PFObject *)type;

@end
