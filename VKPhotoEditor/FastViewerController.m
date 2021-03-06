//
//  FastViewerController.m
//  VKPhotoEditor
//
//  Created by asya on 11/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "FastViewerController.h"
#import "RemoteImageView.h"
#import "DataFormatter.h"
#import "ZoomingView.h"
#import "UIColor+VKPhotoEditor.h"
#import "UserAccountController.h"
#import "VKHighlightTextView.h"
#import "UITextView+Resize.h"

@interface FastViewerController () {
    IBOutlet UIView *backTopView;
    IBOutlet UIButton *topButton;
    IBOutlet UIImageView *backBottomView;
    IBOutlet UIView *photoPlaceholder;
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *postDateLabel;
    IBOutlet RemoteImageView *avatarImageView;
    IBOutlet VKHighlightTextView *captionTextView;
    
    VKPhoto *photo;
    ZoomingView *zoomingView;
}

@end

@implementation FastViewerController

@synthesize delegate;

- (id)initWithPhoto:(VKPhoto *)_photo
{
    self = [super init];
    if (self) {
        photo = _photo;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor defaultBgColor];
    
    topButton.titleLabel.font = [UIFont fontWithName:@"Lobster" size:22.0];
    captionTextView.font = [UIFont fontWithName:@"Lobster" size:28.0];
    captionTextView.text = photo.caption;
    [captionTextView sizeFontToFitMinSize:8 maxSize:28];
    [captionTextView setNeedsDisplay];
    
    userNameLabel.text = photo.account.login;
    postDateLabel.text = [DataFormatter formatRelativeDate:photo.date];
    
    [avatarImageView displayImage:photo.account.avatar];
    
    zoomingView = [[ZoomingView alloc] initWithContentView:[[UIImageView alloc] initWithImage:photo.photo.image] frame:photoPlaceholder.bounds];
    zoomingView.shouldClip = YES;
    zoomingView.maxZoomScale = 3;
    zoomingView.bounces = NO;
    zoomingView.contentMode = UIViewContentModeScaleAspectFit;
    zoomingView.backgroundColor = [UIColor defaultBgColor];
    [photoPlaceholder addSubview:zoomingView];
}

- (IBAction)goBack
{
   [delegate fastViewerControllerDidFinish:self]; 
}

- (IBAction)showProfile
{
    [delegate fastViewerController:self didFinishWithAccount:photo.account];
}

@end
