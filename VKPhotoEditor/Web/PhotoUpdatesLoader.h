//
//  RepliesUpdate.h
//  VKPhotoEditor
//
//  Created by asya on 12/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *VKUpdateRepliesBadge;
extern NSString *VKHideRepliesBadge;

@interface PhotoUpdatesLoader : NSObject
- (void)start;
- (void)stop;
@end
