//
//  PWCViewController.m
//  HiBeacon
//
//  Created by Ravi on 27/11/2013.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import "PWCViewController.h"
#import "PWCAppDelegate.h"

static NSString * const kCellIdentifier = @"BeaconCell";
static NSString * const kUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";
static NSString * const kRegionIdentifier = @"PWCBeaconRegion";

@interface PWCViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic, strong) NSArray *detectedBeacons;

@end

@implementation PWCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.rangingSwitch addTarget:self
                           action:@selector(switchRangingState:)
                 forControlEvents:UIControlEventValueChanged];
    
    [self.advertisingSwitch addTarget:self
                               action:@selector(switchAdvertisingState:)
                     forControlEvents:UIControlEventValueChanged];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)switchRangingState:sender
{
    UISwitch *rangeSwitch = (UISwitch *)sender;
    
    if (rangeSwitch.on) {
        [self startRangingForBeacons];
    } else {
        [self stopRangingForBeacons];
    }
}

- (void)switchAdvertisingState:sender
{
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on) {
        [self startAdvertisingBeacon];
    } else {
        [self stopAdvertisingBeacon];
    }
}

- (void)startRangingForBeacons
{
    // setup Beacon Manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self turnOnRanging];
    
}

- (void)stopRangingForBeacons
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    
//    [self postDataToSpreadsheetViaForm];

    self.detectedBeacons = nil;
    [self.beaconTableView reloadData];
}

#pragma mark - Beacon ranging
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kRegionIdentifier];
}



- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        self.rangingSwitch.on = NO;
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [self createBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);

    
}

#pragma mark - Beacon ranging delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
        self.rangingSwitch.on = NO;
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Couldn't turn on ranging: Location services not authorised.");
        self.rangingSwitch.on = NO;
        return;
    }
    
    self.rangingSwitch.on = YES;
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    if ([beacons count] == 0) {
        NSLog(@"No beacons found nearby.");
    } else {
        NSLog(@"Found beacons!");
    }
    
    self.detectedBeacons = beacons;
    [self.beaconTableView reloadData];
}

#pragma mark - Beacon advertising
- (void)turnOnAdvertising
{
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral manager is off.");
        self.advertisingSwitch.on = NO;
        return;
    }
    
    time_t t;
    srand((unsigned) time(&t));
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                     major:rand()
                                                                     minor:rand()
                                                                identifier:self.beaconRegion.identifier];
    NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];
}

- (void)startAdvertisingBeacon
{
    NSLog(@"Turning on advertising...");
    
    [self createBeaconRegion];
    
    if (!self.peripheralManager)
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
    
    [self turnOnAdvertising];
}

- (void)stopAdvertisingBeacon
{
    [self.peripheralManager stopAdvertising];
    
    NSLog(@"Turned off advertising.");
}

#pragma mark - Beacon advertising delegate methods
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
{
    if (error) {
        NSLog(@"Couldn't turn on advertising: %@", error);
        self.advertisingSwitch.on = NO;
        return;
    }
    
    if (peripheralManager.isAdvertising) {
        NSLog(@"Turned on advertising.");
        self.advertisingSwitch.on = YES;
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Peripheral manager is off.");
        self.advertisingSwitch.on = NO;
        return;
    }
    
    NSLog(@"Peripheral manager is on.");
    [self turnOnAdvertising];
}



# pragma mark TableView Delegate Methods
////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                          reuseIdentifier:kCellIdentifier];
    
    CLBeacon *beacon = self.detectedBeacons[indexPath.row];
    defaultCell.textLabel.text = beacon.proximityUUID.UUIDString;
    NSLog(@"%@ beacon desc", beacon.description);
    
    NSString *proximityString;
    switch (beacon.proximity) {
        case CLProximityNear:
            proximityString = @"Near";
            break;
        case CLProximityImmediate:
            proximityString = @"Immediate";
            break;
        case CLProximityFar:
            proximityString = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityString = @"Unknown";
            break;
    }
    defaultCell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ • %@ • %.2fm • %li",
                                        beacon.major.stringValue, beacon.minor.stringValue, proximityString, beacon.accuracy, (long)beacon.rssi];
    defaultCell.detailTextLabel.textColor = [UIColor grayColor];
    
    return defaultCell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detectedBeacons.count ;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"iBeacons Found";
}


@end
