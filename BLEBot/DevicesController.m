//
//  SecondViewController.m
//  BLEBot
//
//  Created by Mirek Novák on 02.02.15.
//  Copyright (c) 2015 mirek.novak. All rights reserved.
//

#import "DevicesController.h"
#import "RobotController.h"

@interface DevicesController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *conindicator;
@property (strong, nonatomic) NSMutableDictionary *devices;

@end

@implementation DevicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    NSLog(@"Devices view");
    self.devices = [[NSMutableDictionary alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    self.centralManager.delegate = self;
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BT Manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn){
        return;
    }
    if (central.state == CBCentralManagerStatePoweredOn){
        // Scan for devices
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        NSLog(@"Scanning started");
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Device discovered");
    NSString * uuid = [[peripheral identifier] UUIDString];
    if (uuid)
    {
        NSLog(@"Device discovered: %@",uuid);
        [self.devices setObject:peripheral forKey:uuid];
    }
    
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [self.tabBarController setSelectedIndex:0];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService * service in [peripheral services])
    {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic * character in [service characteristics])
    {
        [peripheral discoverDescriptorsForCharacteristic:character];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"%@",characteristic);
    const char * bytes =[(NSData*)[[characteristic UUID] data] bytes];
    if (bytes && strlen(bytes) == 2 && bytes[0] == (char)255 && bytes[1] == (char)225){
       RobotController * bot = [[self.tabBarController viewControllers] objectAtIndex:0];
        bot.centralManager=self.centralManager;
        bot.centralManager.delegate = bot;
        [bot setConnectdPeri:peripheral];
    
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // unsigned char * bytes = [[characteristic value] bytes];
    NSString * str = [[NSString alloc] initWithData:[characteristic value] encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", str);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    
}


#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.devices allKeys] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Making cell");
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    CBPeripheral * peri = nil;
    if ([indexPath row] < [uuids count])
    {
        peri = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"devices_cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"devices_cell"];
    }
    
    if (peri)
    {
        cell.textLabel.text = [peri name];
        cell.detailTextLabel.text = [uuids objectAtIndex:[indexPath row]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    CBPeripheral * peri = nil;
    if ([indexPath row] < [uuids count])
    {
        peri = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
        if (peri)
        {
            [_centralManager connectPeripheral:peri options:nil];
           // [self.conindicator startAnimating];
        }
    }
}


@end
