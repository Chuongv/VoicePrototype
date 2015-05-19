//
//  CVAudioSession.h
//  VoicePrototype
//
//  Created by Chuong Vu on 5/16/15.
//  Copyright (c) 2015 Vu, Chuong. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface CVAudioSession : NSObject

-(void)startTheEngine;
-(void)startInput;
-(void)stopInput;
@end
