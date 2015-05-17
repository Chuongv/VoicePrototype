//
//  ViewController.m
//  VoicePrototype
//
//  Created by Chuong Vu on 3/15/15.
//  Copyright (c) 2015 Vu, Chuong. All rights reserved.
//

#import "ViewController.h"


typedef int COOLINT;
@import AVFoundation;

@interface ViewController ()

@property (strong, nonatomic) UIButton *recordButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    COOLINT num = 5;
    COOLINT num2 = 7;

    NSLog(@"num + num2 = %d", num + num2);

    CGRect buttonFrame = CGRectMake(100, 100, 100, 100);
    self.recordButton = [[UIButton alloc] initWithFrame:buttonFrame];
    self.recordButton.backgroundColor = [UIColor blackColor];
    [self.recordButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)recordButtonPressed
{
    NSLog(@"Button pressed");

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession requestRecordPermission:^(BOOL granted) {
        if (granted)
            NSLog(@"Request permitted!");
    }];
    NSError *error;
    [audioSession setActive:YES error:&error];
    if (error) {
        NSLog(@"Error setting active %@", error.localizedDescription);
    }

    NSLog(@"Available inputs: %@", [audioSession availableInputs]);
    AVAudioSessionPortDescription *firstPort = [audioSession availableInputs].firstObject;

    
    [audioSession setInputDataSource:firstPort error:&error];

}

@end
