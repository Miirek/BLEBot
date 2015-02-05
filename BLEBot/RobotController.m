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
    NSMutableArray *_stepsRecorder;

}
// RECORDER MODEL
-(void) playRecordedStepsWithDelays: (BOOL)delays;
-(void) storeRecodFor:(NSString*) command andDuration: (NSInteger) duration;

// RECORDER API
-(void)startRecording:(id)sender;
-(void)stopRecording:(id)sender;
-(void)clearRecorded:(id)sender;

-(IBAction)recorderControl:(id)sender;

-(NSString *)stringForDirection:(JSDPadDirection)direction;
@end


@implementation RobotController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.devState.text = NSLocalizedString(@"devState.disconnected", nil);

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
    switch (ctrl.selectedSegmentIndex) {
        case PlayerRec:
            
            break;
            
        default:
            break;
    }
    
    
}

-(void)startRecording:(id)sender{
    
}
-(void)stopRecording:(id)sender{
    
}

-(void)clearRecorded:(id)sender{
    
}

-(void)playRecordedStepsWithDelays:(BOOL)delays{
    
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
    [self sendValue:@"s"];
    
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
    NSString *string = nil;
    
    switch (direction) {
        case JSDPadDirectionNone:
            string = @"None";
            [self sendValue:@"x"];
            break;
        case JSDPadDirectionUp:
            string = @"Up";
            [self sendValue:@"f"];
            
            break;
        case JSDPadDirectionDown:
            string = @"Down";
            [self sendValue:@"b"];

            break;
        case JSDPadDirectionLeft:
            string = @"Left";
            [self sendValue:@"l"];

            break;
        case JSDPadDirectionRight:
            string = @"Right";
            [self sendValue:@"r"];

            break;
        case JSDPadDirectionUpLeft:
            string = @"Up Left";
            [self sendValue:@"y"];
            break;
        case JSDPadDirectionUpRight:
            string = @"Up Right";
            [self sendValue:@"x"];
            break;
        case JSDPadDirectionDownLeft:
            string = @"Down Left";
              [self sendValue:@"y"];
            break;
        case JSDPadDirectionDownRight:
            string = @"Down Right";
            [self sendValue:@"x"];
            break;
        default:
            string = @"None";
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
