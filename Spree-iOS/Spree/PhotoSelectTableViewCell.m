//
//  PhotoSelectTableViewCell.m
//  Spree
//
//  Created by Riley Steele Parsons on 7/12/15.
//  Copyright (c) 2015 Riley Steele Parsons. All rights reserved.
//

#import "PhotoSelectTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface PhotoSelectTableViewCell ()

@property AVCaptureSession *liveFeedSession;

@end

@implementation PhotoSelectTableViewCell

- (void)setFrame:(CGRect)frame {
    if(frame.size.width != self.bounds.size.width) {
        [super setFrame:frame];
        self.contentView.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.contentView layoutIfNeeded];
    }
    else {
        [super setFrame:frame];
    }
}

- (void)awakeFromNib {
    // Initialization code
    float halfViewWidth = self.frame.size.width/2;
    self.buttonWidthLayoutContraint.constant = halfViewWidth;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupLiveCamera{
    self.liveFeedSession = [[AVCaptureSession alloc] init];
    self.liveFeedSession.sessionPreset = AVCaptureSessionPresetLow;
    NSError *error = nil;
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            [self.liveFeedSession addInput:input];
        }
    }
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.liveFeedSession];
    newCaptureVideoPreviewLayer.frame = self.takePhotoButton.bounds;
    newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.takePhotoButton.layer addSublayer:newCaptureVideoPreviewLayer];
    [self.liveFeedSession startRunning];
    CALayer *overlay = [CALayer layer];
    overlay.frame = self.takePhotoButton.bounds;
    overlay.backgroundColor = [[UIColor spreeDarkBlue] CGColor];
    overlay.opacity = 0.55f;
    [self.takePhotoButton.layer addSublayer:overlay];
    
}



@end
