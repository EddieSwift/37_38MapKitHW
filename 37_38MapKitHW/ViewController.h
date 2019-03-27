//
//  ViewController.h
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/24/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol StudentInfoDelegate;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end

@protocol StudentInfoDelegate <NSObject>

@required
- (void) transferStudentInfoToPopover:(NSArray*) array;

@end

