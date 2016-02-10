//
//  PostingStringEntryViewModel.h
//  
//
//  Created by Riley Steele Parsons on 1/24/16.
//
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import "SpreeViewModelServices.h"

@interface PostingStringEntryViewModel : RVMViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services field:(NSDictionary *)field;

@property int maxCharacters;
@property int remainingCharacters;
@property NSString *prompt;
@property NSString *enteredString;

@property RACCommand *nextCommand;

@end
