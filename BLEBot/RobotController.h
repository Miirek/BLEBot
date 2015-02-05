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

@interface RobotController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate,JSDPadDelegate, JSButtonDelegate, JSAnalogueStickDelegate>
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *connectdPeri;
@property (strong, nonatomic) IBOutlet UILabel *devState;

@property (weak, nonatomic) IBOutlet JSAnalogueStick *analogueStick;

@property (weak, nonatomic) IBOutlet JSDPad *dPad;



- (void)setCentralManager:(CBCentralManager *)centralManager;
- (void)setConnectdPeri:(CBPeripheral *)connectdPeri;



@end

