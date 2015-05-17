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
@property (nonatomic, assign) bool started;

@end
@implementation CVAudioSession

-(void)startTheEngine
{
    NSError *error;
    [self.session setActive:YES error:&error];
    self.started = YES;
    if (error) {
        self.started = NO;
        NSLog(@"Failed to start engine! :%@", error.localizedDescription);
    }

}

-(void)startInput
{
    if (self.session) {
        if (!self.session.inputDataSource) {
            NSLog(@"InputDataSources: %@", self.session.inputDataSource);
        }
    }
}
@end
