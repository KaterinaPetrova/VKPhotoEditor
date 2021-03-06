//
//  UserAccount.h
//  VKPhotoEditor
//
//  Created by Ekaterina Petrova on 10/25/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface UserProfile : Account <NSCoding>
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *avatarId;
@property (nonatomic, strong) NSArray *lastPhotos;
@property (nonatomic, assign) BOOL hasExtendedMenu;

+ (id)accountWithDict:(NSDictionary*)dict;
@end
