//
//  ProfileHeaderView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 12/3/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "ProfileHeaderView.h"
#import "UIView+Helpers.h"

@implementation ProfileHeaderView
@synthesize avatarTheaterView;
@synthesize nameLabel;
@synthesize centralButton;
@synthesize headerTopView;
@synthesize headerBottomView;
@synthesize noAvatarImageView;
@synthesize avatarActivity;
@synthesize noAvatarLabel;
@synthesize photosLabelCount;
@synthesize followersLabelCount;
@synthesize mentionsLabelCount;
@synthesize headerCentralView;
@synthesize mode;
@synthesize state;
@synthesize delegate;

- (void)awakeFromNib
{
    centralButton.bgImagecaps = CGSizeMake(23, 0);
}

#pragma mark - actions

- (IBAction)back
{
    [delegate profileHeaderViewDidBack:self];
}

- (IBAction)centerAction
{
    [delegate profileHeaderViewDidTapButton:self];
}

- (IBAction)changeMode:(UIButton*)sender
{
    self.mode = sender.tag;
}

- (void)setMode:(ProfileHeaderViewMode)_mode
{
    if (mode == _mode)
        return;
    
    mode = _mode;
    [delegate profileHeaderView:self didChangeMode:mode];
}

- (UIView*)addView:(UIView*)view afterView:(UIView*)previosView
{
    [self addSubview:view];
    [view moveTo:CGPointMake(0, previosView ? previosView.frame.origin.y + previosView.frame.size.height : 0)];
    return view;
    
}

- (void)setState:(ProfileHeaderViewState)_state
{
    if (state == _state)
        return;
    
    state = _state;
    [headerCentralView removeFromSuperview];
    [headerBottomView removeFromSuperview];
    [headerCentralView removeFromSuperview];
    UIView *lastView;
    
    switch (state) {
        case ProfileHeaderViewStateFollowing:
            [self addView:headerTopView afterView:nil];
            lastView = [self addView:headerBottomView afterView:headerTopView];
            break;
        case ProfileHeaderViewStateHeader:
            lastView = [self addView:headerTopView afterView:nil];
            break;
        case ProfileHeaderViewStateCompact:
            noAvatarLabel.hidden = NO;
            avatarTheaterView.hidden = YES;
            [self addView:headerTopView afterView:nil];
            [self addView:headerCentralView afterView:headerTopView];
            [headerCentralView resizeTo:noAvatarImageView.frame.size];
            lastView = [self addView:headerBottomView afterView:headerCentralView];
            break;
        case ProfileHeaderViewStateFull:
            noAvatarLabel.hidden = YES;
            avatarTheaterView.hidden = NO;
            [self addView:headerTopView afterView:nil];
            [self addView:headerCentralView afterView:headerTopView];
            [headerCentralView resizeTo:avatarTheaterView.frame.size];
            lastView = [self addView:headerBottomView afterView:headerCentralView];
            break;
        default:
            break;
    }
    
    [self resizeTo:CGSizeMake(320, lastView.frame.origin.y + lastView.frame.size.height)];
}

@end