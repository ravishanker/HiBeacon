//
//  PWCOfferViewController.h
//  HiBeacon
//
//  Created by Ravi on 2/12/2013.
//  Copyright (c) 2013 PwC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PWCOfferViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *offerImage;

@end
