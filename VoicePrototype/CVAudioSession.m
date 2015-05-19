//
//  CVAudioSession.m
//  VoicePrototype
//
//  Created by Chuong Vu on 5/16/15.
//  Copyright (c) 2015 Vu, Chuong. All rights reserved.
//

#import "CVAudioSession.h"
@import AVFoundation;
@import AudioToolbox;

AudioComponentDescription ioUnitDescription;
AUGraph processingGraph;
AUNode ioNode;
AudioUnit ioUnit;

@interface CVAudioSession ()

@property (strong, nonatomic) AVAudioSession *session;
@property (nonatomic, assign) bool started;


-(void)setPreferredInput;

@end
@implementation CVAudioSession

-(instancetype)init
{

    ioUnitDescription.componentType = kAudioUnitType_Output;
    ioUnitDescription.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags = 0;
    ioUnitDescription.componentFlagsMask = 0;

    NewAUGraph(&processingGraph);

    AUGraphAddNode(processingGraph, &ioUnitDescription, &ioNode);

    self = [super init];
    self.session = [AVAudioSession sharedInstance];

    return self;
}

-(void)startTheEngine
{
    NSError *error;
    //set category
    BOOL success = [self.session setCategory:AVAudioSessionCategoryPlayAndRecord
                   error:&error];
    if (!success) {
        NSLog(@"Error setting category: %@", error.localizedFailureReason);
    }

    success = [self.session setActive:YES error:&error];
    self.started = YES;
    if (!success) {
        self.started = NO;
        NSLog(@"Failed to start engine! :%@", error.localizedFailureReason);
    }

}

-(void)startInput
{
    [self setPreferredInput];


    if (self.session) {
        if (!self.session.inputDataSource) {
            AVAudioSessionDataSourceDescription *data = self.session.inputDataSources.firstObject;

            NSError *error;
            bool success = [self.session setInputDataSource:data error:&error];
            if (!success) {
                NSLog(@"Error on inputData: %@", error.localizedDescription);
            }
        }
    }

    OSStatus status = AUGraphOpen(processingGraph);
    NSLog(@"OSStatus after opening graph: %d", (int)status);

    //Then, obtain references to the audio unit instances by way of the AUGraphNodeInfo function, as shown here
    AUGraphNodeInfo(processingGraph, ioNode, NULL, &ioUnit);

    UInt32 enableInput = 1;
    AudioUnitElement inputBus = 1;

    //set the property of the audio unit to accept input
    status = AudioUnitSetProperty(
                                  ioUnit,
                                  kAudioOutputUnitProperty_EnableIO,//property we are changing
                                  kAudioUnitScope_Input,
                                  inputBus,
                                  &enableInput,
                                  sizeof (enableInput)
                                  );


}

-(void)stopInput
{
    NSError *error;
    [self.session setActive:NO error:&error];

    if (error)
        NSLog(@"Error stopping input: %@", error.localizedDescription);
}

-(void)setPreferredInput
{
    NSError *error;
    AVAudioSessionPortDescription *port = [self.session availableInputs].firstObject;

    [self.session setPreferredInput:port error:&error];

    if (error) {
        NSLog(@"Failed to setup preferred input: %@", error.localizedDescription);
    }
}
@end
