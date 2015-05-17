//
//  CVAudioSession.m
//  VoicePrototype
//
//  Created by Chuong Vu on 5/16/15.
//  Copyright (c) 2015 Vu, Chuong. All rights reserved.
//

#import "CVAudioSession.h"
@import AVFoundation;

@interface CVAudioSession ()

@property (strong, nonatomic) AVAudioSession *session;

@end
@implementation CVAudioSession

-(void)startTheEngine
{
    NSError *error;
    [self.session setActive:YES error:&error];

}
@end
