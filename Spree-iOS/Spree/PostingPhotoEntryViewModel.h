//
//  PostingPhotoEntryViewModel.h
//  Spree
//
//  Created by Riley Steele Parsons on 1/30/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import <ReactiveViewModel/ReactiveViewModel.h>
#import "CEObservableMutableArray.h"
#import "SpreeViewModelServices.h"

@interface PostingPhotoEntryViewModel : RVMViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services;

@property RACCommand *nextCommand;
@property RACCommand *photoSelected;
@property RACCommand *deletePhoto;
@property RACCommand *tableViewNeedsUpdateCommand;

@property int maxPhotos;
@property int remainingPhotos;
@property int currentPhotoCount;

@property NSString *prompt;
@property CEObservableMutableArray *files;

@end
