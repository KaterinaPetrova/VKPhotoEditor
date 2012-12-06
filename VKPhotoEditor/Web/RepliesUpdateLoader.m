//
//  RepliesUpdate.m
//  VKPhotoEditor
//
//  Created by asya on 12/4/12.
//  Copyright (c) 2012 GirlsWhoDeveloping. All rights reserved.
//

#import "RepliesUpdateLoader.h"
#import "MentionList.h"

#define TIME_INTERVAL 60

NSString *VKUpdateRepliesBadge = @"VKUpdateRepliesBadge";

@interface RepliesUpdateList : MentionList
@end

@implementation RepliesUpdateList

- (VKRequestExecutor*)newPageExec
{
    return [service getMentions:service.profile.accountId since:service.since after:nil limit:limit];
}

@end

@interface RepliesUpdateLoader ()<PhotoListDelegate>

@end
@implementation RepliesUpdateLoader {
    RepliesUpdateList *mentionList;
    NSTimer *timer;
}

#pragma mark - PhotoListDelegate

- (id)init
{
    self = [super init];
    if (self) {
        mentionList = [[RepliesUpdateList alloc] init];
        mentionList.delegate = self;
    }
    return self;
}

- (void)start
{
    [mentionList loadMore];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:TIME_INTERVAL target:mentionList selector:@selector(loadMore) userInfo:nil repeats:YES];
}

- (void)stop
{
    [timer invalidate];
    timer = nil;
}

- (void)dealloc
{
    [self stop];
}

- (void)photoList:(PhotoList *)photoList didUpdatePhotos:(NSArray *)photos
{
    NSLog(@"Update photos: %d", mentionList.mentionsCount);
    if (mentionList.mentionsCount) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VKUpdateRepliesBadge object:[NSNumber numberWithInt:mentionList.mentionsCount] userInfo:nil];
    }
}

- (void)photoList:(PhotoList *)photoList didFailToUpdate:(NSError *)error {}

@end