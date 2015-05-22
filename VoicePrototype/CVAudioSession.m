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

//AUG processing graph
AUGraph processingGraph;

//VoIP node and unit
AUNode ioNode;
AudioUnit ioUnit;
AudioComponentDescription ioUnitDescription;

//input and output bus
AudioUnitElement inputBus = 1;
AudioUnitElement outputBus = 1;


@interface CVAudioSession ()

@property (strong, nonatomic) AVAudioSession *session;
@property (nonatomic, assign) bool started;
@property (nonatomic, assign) double sampleRate;

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

    self.sampleRate = self.session.sampleRate;

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



    //Open the graph
    OSStatus status = AUGraphOpen(processingGraph);
    NSLog(@"OSStatus after opening graph: %d", (int)status);

    //Then, obtain references to the audio unit instances by way of the AUGraphNodeInfo function, as shown here
    status = AUGraphNodeInfo(processingGraph, ioNode, NULL, &ioUnit);
    NSLog(@"OSStatus after AUGraphNodeInfo: %d", (int)status);


    [self enableAudioUnitInputOutput];

    [self setUpStreamFormat];

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

#pragma mark - Setup AudioNode/Unit

-(void)enableAudioUnitInputOutput
{
    //set the property of the audio unit to accept input
    UInt32 enableInput = 1;
    OSStatus status = AudioUnitSetProperty(
                                  ioUnit,
                                  kAudioOutputUnitProperty_EnableIO,//property we are changing
                                  kAudioUnitScope_Input,
                                  inputBus,
                                  &enableInput,
                                  sizeof (enableInput)
                                  );
    NSLog(@"Status after kAudioOutputUnitProperty_EnableIO property: %d", status);
}

-(void)setUpStreamFormat
{
    //Always initialize the fields of a new audio stream basic description structure to zero
    UInt32 bytesPerSample = sizeof (SInt32);

    AudioStreamBasicDescription asbd = {0};
    asbd.mSampleRate = self.sampleRate;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    asbd.mChannelsPerFrame = 2;
    asbd.mBytesPerFrame = bytesPerSample;
    asbd.mBitsPerChannel = 8 * bytesPerSample;
    asbd.mFramesPerPacket = 1;
    asbd.mBytesPerPacket = bytesPerSample;

    //set the property of the ioUnit's stream format
    OSStatus status = AudioUnitSetProperty(
                                  ioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  inputBus,
                                  &asbd,
                                  sizeof(asbd));
    NSLog(@"Status after setting stream format: %d", status);
}
@end
