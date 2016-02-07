//
//  PreviewPostViewModel.m
//  Spree
//
//  Created by Riley Steele Parsons on 2/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "PreviewPostViewModel.h"
#import "PostDescriptionTableViewCell.h"
#import "PostMapTableViewCell.h"
#import "PostTitleTableViewCell.h"
#import "PostUserTableViewCell.h"
#import "PhotoGalleryTableViewCell.h"
#import "BasicInfoTableViewCell.h"

@interface PreviewPostViewModel ()

@property id<SpreeViewModelServices> services;
@property NSMutableArray *cellsForTable;

@end

@implementation PreviewPostViewModel

-(instancetype)initWithServices:(id<SpreeViewModelServices>)services post:(SpreePost *)post{
    self = [super init];
    if (self) {
        _services = services;
        _post = post;
        [self initialize];
    }
    return self;
}

-(void)initialize{
    self.completePostCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal return:nil];
    }];
    self.existingFieldsToShow = [self findFieldsToShow:self.post[@"completedFields"]];
}

// Sorts the existing fields by priority for the view.
-(NSArray *)findFieldsToShow:(NSDictionary *)fields{
    NSMutableArray *fieldsToShow = [[NSMutableArray alloc] init];
    for (id field in fields){
        if (!field[@"priority"]){
            [field setObject:@(99) forKey:@"priority"];
        }
        if ([field[@"dataType"] isEqualToString:@"geoPoint"]){
            NSDictionary *mapCellDictionary;
            for (id dictionary in fieldsToShow){
                if ([dictionary[@"dataType"] isEqualToString:@"geoPoint"]){
                    mapCellDictionary = dictionary;
                }
            }
            if (!mapCellDictionary){
                [fieldsToShow addObject:field];
            }
        } else if ([field[@"dataType"] isEqualToString:@"string"]){
            [fieldsToShow addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"image"]){
            [fieldsToShow addObject:field];
        } else if ([field[@"dataType"] isEqualToString:@"date"]){
            [fieldsToShow addObject:field];
        }
        [fieldsToShow sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
    }
    return fieldsToShow;
}

@end
