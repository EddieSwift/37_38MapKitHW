//
//  ViewController.m
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/24/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    UIBarButtonItem *currentLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location_arrow.png"] style:UIBarButtonItemStyleDone target:self action:@selector(currentLocationAction:)];
    self.navigationItem.rightBarButtonItem = currentLocation;
    
}

#pragma mark - Actions

- (void) currentLocationAction:(UIBarButtonItem*) sender {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}



@end
