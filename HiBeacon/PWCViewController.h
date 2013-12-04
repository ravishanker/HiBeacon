//
//  PWCViewController.h
//  HiBeacon
//
//  Created by Ravi on 27/11/2013.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface PWCViewController : UIViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *beaconTableView;

@property (weak, nonatomic) IBOutlet UISwitch *rangingSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *advertisingSwitch;

@end
