//
//  PhotoCell.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/28/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemoteImageView.h"
#import "VKPhoto.h"
#import "VKHighlightTextView.h"
#import "Account.h"

@protocol PhotoCellDelegate;

@interface PhotoCell : UITableViewCell
@property (nonatomic, assign) id<PhotoCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet RemoteImageView *remoteImageView;
@property (nonatomic, strong) IBOutlet UIImageView *addedImageView;
@property (nonatomic, strong) IBOutlet VKHighlightTextView *captionTextView;
@property (nonatomic, strong) IBOutlet UIButton *accountButton;

@property (nonatomic, strong) IBOutlet RemoteImageView *avatarRemoteImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, copy) NSString *searchString;

- (void)displayPhoto:(VKPhoto*)photo;
- (void)displayPhoto:(VKPhoto*)photo canSelectAccount:(BOOL)selectAccount;

- (IBAction)openAccount;
@end

@protocol PhotoCellDelegate <NSObject>
- (void)photoCell:(PhotoCell*)photoCell didTapHashTag:(NSString*)hashTag;
- (void)photoCell:(PhotoCell*)photoCell didTapOnPhoto:(VKPhoto*)photo;
- (void)photoCell:(PhotoCell*)photoCell didSelectAccount:(Account*)account;
@end