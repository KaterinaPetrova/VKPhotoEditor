//
//  DefaultOverlayView.m
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/6/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "DefaultCaptionView.h"

@interface DefaultCaptionView () <SPUserResizableViewDelegate>
@end

@implementation DefaultCaptionView
@synthesize captionLabel;
@synthesize delegate;
@synthesize labelView;

- (void)awakeFromNib
{
    labelView.contentView = captionLabel;
}

#pragma mark - CaptionTemplateProtocol

- (NSString*)text
{
    return captionLabel.text;
}

- (void)setText:(NSString *)_text
{
    captionLabel.text = _text;
}

- (void)setFont:(UIFont *)_font
{
    captionLabel.font = [UIFont fontWithName:_font.fontName size:captionLabel.font.pointSize];
}

- (UIFont*)font
{
    return captionLabel.font;
}

#pragma mark - SPUserResizableViewDelegate

- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView
{
    [delegate captionTemplateStartEditing:self];
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView
{
    [delegate captionTemplateEndEditing:self];
}

@end