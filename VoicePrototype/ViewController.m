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
#import "CVAudioSession.h"

@interface ViewController ()

@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) CVAudioSession *audioSession;

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

    self.audioSession = [[CVAudioSession alloc] init];
    [self.audioSession startTheEngine];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)recordButtonPressed
{

}

@end
