//
//  FirstViewController.h
//  BLEBot
//
//  Created by Mirek Novák on 02.02.15.
//  Copyright (c) 2015 mirek.novak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "JSDPad.h"
#import "JSButton.h"
#import "JSAnalogueStick.h"

@class RobotStep;

@protocol RobotStepRecorderProtocol <NSObject>
-(void) addRecord:(RobotStep*)rec;
@end

@interface RobotController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate,JSDPadDelegate, JSButtonDelegate, JSAnalogueStickDelegate,RobotStepRecorderProtocol>
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *connectdPeri;
@property (strong, nonatomic) IBOutlet UILabel *devState;
@property (weak, nonatomic) IBOutlet JSAnalogueStick *analogueStick;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *stepCounter;
@property (weak, nonatomic) IBOutlet JSDPad *dPad;
@property (weak, nonatomic) IBOutlet UIProgressView *playerProgress;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cPanel;
- (void)setCentralManager:(CBCentralManager *)centralManager;
- (void)setConnectdPeri:(CBPeripheral *)connectdPeri;
@end

@interface RobotStep : NSObject{
    NSDate *startTime;
}

@property (nonatomic,strong) NSString *command;
@property CGFloat duration;
@property BOOL endWithStop;
@property (nonatomic, strong) id delegate;


@end

