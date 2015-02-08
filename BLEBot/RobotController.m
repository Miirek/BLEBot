//
//  FirstViewController.m
//  BLEBot
//
//  Created by Mirek Novák on 02.02.15.
//  Copyright (c) 2015 mirek.novak. All rights reserved.
//

#import "RobotController.h"
typedef  NS_ENUM(NSUInteger, PlayerControl) {
    PlayerRec = 0,
    PlayerStop,
    PlayerClear,
    PlayerPlay,
    PlaerPause
};

@interface RobotController (){
    NSMutableArray *_pressedButtons;
    NSMutableArray *stepsRecorder;
    BOOL nowRecording;
    BOOL nowPlaying;
    NSDate *timer;
    NSTimer *updater;
    RobotStep *currentStep;
}

// RECORDER MODEL
-(void) playRecordedStepsWithDelays: (BOOL)delays;
-(void) storeRecodFor:(NSString*) command andDuration: (NSInteger) duration;

// RECORDER API
-(void)startRecording;
-(void)stopRecording;
-(void)clearRecorded:(id)sender;
-(void)startPlaying;

-(IBAction)recorderControl:(id)sender;

-(NSString *)stringForDirection:(JSDPadDirection)direction;

@end

@implementation RobotStep

-(void) startWithCommand:(NSString*) cmd{
    startTime = [NSDate date];
    [self setCommand:cmd];
}

-(void) stop{
    
     _duration = [[NSDate date] timeIntervalSinceDate:startTime];
    _endWithStop = TRUE;
    
    NSLog(@"CMD %@ duration:%f ",_command,_duration);
    if ([_delegate respondsToSelector:@selector(addRecord:)]) {
        [_delegate addRecord:self];
    }else
        NSLog(@"No delegate!");
}
@end

@implementation RobotController

-(void)addRecord:(RobotStep*)rec{
    [stepsRecorder addObject:rec];
    [_stepCounter setText:[NSString stringWithFormat:@"%lu",(unsigned long)[stepsRecorder count]]];
    NSLog(@"Record added %@", rec);
}

-(void)storeRecodFor:(NSString *)command andDuration:(NSInteger)duration{
    
}

-(void)startRecording{
    stepsRecorder = nil;
    stepsRecorder = [[NSMutableArray alloc] init];
    timer = [NSDate date];
    updater = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    nowRecording = YES;
    
}

-(void) stopRecording{
    nowRecording = NO;
    
    if (updater == nil) {
        return;
    }
    
    if([updater isValid]){
        [updater invalidate];
        updater = nil;
        updater = nil;
    }
}

-(void)startPlaying{
    [self playRecordedStepsWithDelays:YES];
}

-(void)updateTimer{
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:timer];
    int hod = (int) floor(elapsed / 360);
    int min = (int) floor(elapsed / 60);
    int sec = (int) floor(elapsed - (360 * hod + 60 * min ));
    int set = (int) floor((elapsed - floor(elapsed))*100);
    NSString *timestr = [NSString stringWithFormat:@"%02d:%02d:%02d.%02d",hod,min,sec,set];
    [[self duration]setText:timestr];
    
    NSString *stepCounterVal = [NSString stringWithFormat:@"%lu",[stepsRecorder count]];
    [[self stepCounter] setText:stepCounterVal];
}

- (void)viewDidLoad {
    nowRecording = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.devState.text = NSLocalizedString(@"devState.disconnected", nil);
}

-(void)playRecordedStepsWithDelays:(BOOL)delays{
    if(nowPlaying) return;
    nowPlaying = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (RobotStep * step in stepsRecorder) {
            [self sendValue:step.command];
            usleep(step.duration*1000000);
        }
    });
    nowPlaying = NO;
}

- (void)setConnectdPeri:(CBPeripheral *)connectdPeri
{
    NSLog(@"Connecting peri");
    [self.navigationController popToViewController:self animated:TRUE];
    
    _connectdPeri = connectdPeri;
    _connectdPeri.delegate = self;
    for (CBService * service in [self.connectdPeri services])
    {
        for (CBCharacteristic * characteristic in [service characteristics])
        {
            [_connectdPeri setNotifyValue:TRUE forCharacteristic:characteristic];
        }
    }
    NSLog(@"Connected %@",_connectdPeri);
    self.devState.text = [NSString stringWithFormat:@"%@", _connectdPeri.name];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark RECORDER
-(IBAction)recorderControl:(id)sender{
    UISegmentedControl *ctrl = sender;
    NSLog(@"SEGMENT: %ld",(long)ctrl.selectedSegmentIndex);
    switch (ctrl.selectedSegmentIndex) {
        case PlayerRec:
            [self startRecording];
            break;
        case PlayerStop:
            [self stopRecording];
            break;
            
        case PlayerPlay:
            [self startPlaying];
            break;
        case PlayerClear:
            break;
            
        default:
            break;
    }
}


-(void)clearRecorded:(id)sender{

}

-(void)pausePlayer{

}

#pragma mark Communication


- (void)sendValue:(NSString *) str
{
    for (CBService * service in [self.connectdPeri services])
    {
        NSLog(@"SVC %@", service);
        for (CBCharacteristic * characteristic in [service characteristics])
        {
            NSLog(@"CHR %@ -> %@", characteristic, str);
            
            [self.connectdPeri writeValue:[str dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
}


#pragma mark CoreBlue

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString * str = [[NSString alloc] initWithData:[characteristic value] encoding:NSUTF8StringEncoding];
 //   self.bleOut.text = [NSString stringWithFormat:@"%@\n%@", self.bleOut.text, str];
    NSLog(@"BOT: %@",str);
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.devState.text = NSLocalizedString(@"devState.disconnected", nil);
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"CB Update");
   
}



#pragma mark - JSDPadDelegate

- (void)dPad:(JSDPad *)dPad didPressDirection:(JSDPadDirection)direction
{
    NSLog(@"Changing direction to: %@", [self stringForDirection:direction]);
    //[self updateDirectionLabel];
}

- (void)dPadDidReleaseDirection:(JSDPad *)dPad
{
    NSLog(@"Releasing DPad");
    [currentStep stop];
    currentStep = nil;
    RobotStep *stopCmd = [[RobotStep alloc] init];
    [stopCmd setDelegate:self];
    [stopCmd startWithCommand:@"s"];
    [self sendValue:@"s"];
    [stopCmd stop];
    stopCmd = nil;
    
    //[self updateDirectionLabel];
}

#pragma mark - JSButtonDelegate

- (void)buttonPressed:(JSButton *)button
{
    if ([_pressedButtons containsObject:button])
    {
        NSLog(@"Button is already being tracked as pressed");
        return;
    }
/*
    if ([button isEqual:self.aButton])
    {
        [_pressedButtons addObject:self.aButton];
    }
    else if ([button isEqual:self.bButton])
    {
        [_pressedButtons addObject:self.bButton];
    }
    
    [self updateButtonLabel];
 */
}

- (void)buttonReleased:(JSButton *)button
{
    if ([_pressedButtons containsObject:button] == NO)
    {
        NSLog(@"Button has already been released");
        return;
    }
    /*
    if ([button isEqual:self.aButton])
    {
        [_pressedButtons removeObject:self.aButton];
    }
    else if ([button isEqual:self.bButton])
    {
        [_pressedButtons removeObject:self.bButton];
    }
    
    [self updateButtonLabel];
    */
}


- (NSString *)stringForDirection:(JSDPadDirection)direction
{
    if(nowRecording){
        if(currentStep == nil){
            currentStep = [[RobotStep alloc] init];
            [currentStep setDelegate:self];
            
        }else{
            [currentStep stop];
            currentStep = nil;
            currentStep = [[RobotStep alloc] init];
            [currentStep setDelegate:self];
          
        }
    }
    NSString *string = nil;
    
    switch (direction) {
        case JSDPadDirectionNone:
            string = @"None";
            if(nowRecording)[currentStep startWithCommand:@"s"];
            [self sendValue:@"s"];
            
            break;
        case JSDPadDirectionUp:
            string = @"Up";
            if(nowRecording)[currentStep startWithCommand:@"f"];
            [self sendValue:@"f"];
            
            break;
        case JSDPadDirectionDown:
            string = @"Down";
            if(nowRecording)[currentStep startWithCommand:@"b"];
            [self sendValue:@"b"];

            break;
        case JSDPadDirectionLeft:
            string = @"Left";
            if(nowRecording)[currentStep startWithCommand:@"l"];
            [self sendValue:@"l"];

            break;
        case JSDPadDirectionRight:
            string = @"Right";
            if(nowRecording)[currentStep startWithCommand:@"r"];
            [self sendValue:@"r"];

            break;
        case JSDPadDirectionUpLeft:
            string = @"Up Left";
            if(nowRecording)[currentStep startWithCommand:@"y"];
            [self sendValue:@"y"];
            break;
        case JSDPadDirectionUpRight:
            string = @"Up Right";
            if(nowRecording)[currentStep startWithCommand:@"x"];
            [self sendValue:@"x"];
            break;
        case JSDPadDirectionDownLeft:
            string = @"Down Left";
            if(nowRecording)[currentStep startWithCommand:@"y"];
            [self sendValue:@"y"];
            break;
        case JSDPadDirectionDownRight:
            string = @"Down Right";
            if(nowRecording)[currentStep startWithCommand:@"x"];
            [self sendValue:@"x"];
            break;
        default:
            string = @"None";
            if(nowRecording)[currentStep startWithCommand:@"x"];
            break;
    }
    
    
    return string;
}

#pragma mark - JSAnalogueStickDelegate

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick
{
    //[self updateAnalogueLabel];
}

@end
