//
//  PhotoEditController.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 9/23/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FlexibleButton.h"
#import "ThumbnailsView.h"
#import "GPUImageView.h"
#import "ImageToUpload.h"
#import "VKPhoto.h"

@protocol PhotoEditControllerDelegate;

@interface PhotoEditController : UIViewController
@property (nonatomic, strong) IBOutlet FlexibleButton *saveButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *retakeButton;
@property (nonatomic, strong) IBOutlet FlexibleButton *cancelButton;
@property (nonatomic, strong) IBOutlet ThumbnailsView *filterView;
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet GPUImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIView *captionOverlayView;
@property (nonatomic, strong) IBOutlet UIButton *blurButton;
@property (nonatomic, strong) IBOutlet UILabel *avatarTagLabel;
@property (nonatomic, strong) IBOutlet FlexibleButton *publishReplyButton;

@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *leftRecognizer;
@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *rightRecognizer;
 
@property (nonatomic, unsafe_unretained) id<PhotoEditControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isPhoto;
@property (nonatomic, assign) BOOL isAvatar;
@property (nonatomic, assign) VKPhoto *replyToPhoto;

- (id)initWithImage:(UIImage *)_image filterIndex:(NSInteger)_filterIndex blurFilter:(id)_blurFilter;
- (IBAction)save;

- (IBAction)nextCaptionTemplate;
- (IBAction)prevCaptionTemplate;

- (IBAction)selectBlur;
- (IBAction)cancel;
- (IBAction)retake;
- (IBAction)publishReply;

@end

@protocol PhotoEditControllerDelegate
- (void)photoEditControllerDidCancel:(PhotoEditController *)controller;
- (void)photoEditControllerDidRetake:(PhotoEditController *)controller;
- (void)photoEditControllerDidSelect:(PhotoEditController *)controller;
- (void)photoEditController:(PhotoEditController *)controller didFinishWithImage:(ImageToUpload*)image;
@end
