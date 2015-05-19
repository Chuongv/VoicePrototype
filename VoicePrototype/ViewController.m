//
//  ViewController.m
//  VoicePrototype
//
//  Created by Chuong Vu on 3/15/15.
//  Copyright (c) 2015 Vu, Chuong. All rights reserved.
//

#import "ViewController.h"

@import AVFoundation;
#import "CVAudioSession.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) CVAudioSession *audioSession;
@property (assign, nonatomic) bool recording;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recording = false;
    CGRect buttonFrame = CGRectMake(100, 100, 100, 100);
    self.recordButton = [[UIButton alloc] initWithFrame:buttonFrame];
    self.recordButton.backgroundColor = [UIColor blackColor];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];

    self.audioSession = [[CVAudioSession alloc] init];
    [self.audioSession startTheEngine];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)recordButtonPressed
{
    if (self.recording) {
        [self.audioSession stopInput];
        self.recording = false;
    } else {
        [self.audioSession startInput];
        self.recording = true;
    }

}

@end
