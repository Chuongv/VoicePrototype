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
#define kInputBus 1
#define kOutputBus 0

const double kDefaultSampleRate = 44100.0;

@interface CVAudioSession ()

@property (strong, nonatomic) AVAudioSession *session;
@property (nonatomic, assign) bool started;
@property (nonatomic, assign) double sampleRate;

@property (nonatomic, assign) AUGraph processingGraph;

@property (nonatomic, assign) AUNode ioNode;
@property (nonatomic, assign) AudioUnit ioUnit;
@property (nonatomic, assign) AudioComponentDescription ioUnitDescription;

-(void)setPreferredInput;

@end
@implementation CVAudioSession

#pragma mark - Initialization
-(instancetype)init
{

    _ioUnitDescription.componentType = kAudioUnitType_Output;
    _ioUnitDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    _ioUnitDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    _ioUnitDescription.componentFlags = 0;
    _ioUnitDescription.componentFlagsMask = 0;

    NewAUGraph(&_processingGraph);

    AUGraphAddNode(_processingGraph, &_ioUnitDescription, &_ioNode);

    self = [super init];
    self.session = [AVAudioSession sharedInstance];

    return self;
}

#pragma mark - Methods to manage audio session
-(void)startTheEngine
{
    NSError *error;

    //Set preferred sample rate
    self.sampleRate = kDefaultSampleRate;
    BOOL success = [self.session setPreferredSampleRate:self.sampleRate error:&error];
    if (!success) {
        NSLog(@"Error setting preferred sample rate: %@", error.localizedFailureReason);
    }

    //set category
    success = [self.session setCategory:AVAudioSessionCategoryPlayAndRecord
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
    OSStatus status = AUGraphOpen(self.processingGraph);
    NSLog(@"OSStatus after opening graph: %d", (int)status);

    //Then, obtain references to the audio unit instances by way of the AUGraphNodeInfo function, as shown here
    AudioComponentDescription ioDescription;
    status = AUGraphNodeInfo(self.processingGraph, self.ioNode, &ioDescription, &_ioUnit);
    NSLog(@"OSStatus after AUGraphNodeInfo: %d", (int)status);


    [self enableAudioUnitInputOutput];

    [self setUpStreamFormat];
    [self connectTheRemoteElements];
    //Before you can start audio flow, an audio processing graph must be initialized by calling the AUGraphInitialize function.
    status = AUGraphInitialize(self.processingGraph);
    NSLog(@"OSStatus after initializing graph: %d", (int)status);

    status = AUGraphStart(self.processingGraph);
    NSLog(@"OSStatus after starting graph: %d", (int)status);

}

-(void)stopInput
{
    NSError *error;
    [self.session setActive:NO error:&error];

    if (error)
        NSLog(@"Error stopping input: %@", error.localizedDescription);
}

#pragma mark - Private methods

-(void)setPreferredInput
{
    NSError *error;
    AVAudioSessionPortDescription *port = [self.session availableInputs].firstObject;

    [self.session setPreferredInput:port error:&error];

    if (error) {
        NSLog(@"Failed to setup preferred input: %@", error.localizedDescription);
    }
}

-(void)connectTheRemoteElements
{
    AudioUnitConnection conn;
    conn.destInputNumber = kOutputBus;
    conn.sourceAudioUnit = self.ioUnit;
    conn.sourceOutputNumber = kInputBus;

    OSStatus status = AudioUnitSetProperty(self.ioUnit,
                                           kAudioUnitProperty_MakeConnection,
                                           kAudioUnitScope_Input,
                                           kOutputBus,
                                           &conn,
                                           sizeof(conn));
    NSLog(@"Status after connecting elements: %d", (int)status);
}

#pragma mark - Setup AudioNode/Unit

-(void)enableAudioUnitInputOutput
{
    //set the property of the audio unit to accept input
    UInt32 enableInput = 1;
    OSStatus status = AudioUnitSetProperty(
                                  self.ioUnit,
                                  kAudioOutputUnitProperty_EnableIO,//property we are changing
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &enableInput,
                                  sizeof (enableInput)
                                  );
    NSLog(@"Status after enabling Element 1's OutputScope property: %d", (int)status);

    status = AudioUnitSetProperty(
                                  self.ioUnit,
                                  kAudioOutputUnitProperty_EnableIO,//property we are changing
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &enableInput,
                                  sizeof (enableInput)
                                  );
    NSLog(@"Status after enabling Element 0's OutputScope property: %d", (int)status);
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
                                  self.ioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &asbd,
                                  sizeof(asbd));
    NSLog(@"Status after setting stream format: %d", (int)status);
}
@end
