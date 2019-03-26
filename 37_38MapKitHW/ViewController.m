//
//  ViewController.m
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/24/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import "ViewController.h"
#import "MapAnnotation.h"
#import "UIView+MKAnnotationView.h"
#import "EGBStudent.h"


@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) MKDirections *directions;
@property (strong, nonatomic) NSArray *allStudents;
@property (strong, nonatomic) NSArray *allStudentAnnotations;

@end

@implementation ViewController

static double latitudes[] = {
    
    32.070357, 32.107043, 32.085533, 32.0665637, 32.0638462, 32.056664, 32.0549635, 32.095441, 32.092299, 32.087381
};

static double longitudes[] = {
    
    34.7809829, 34.8044052, 34.775875, 34.7842366, 34.773168, 34.779869, 34.7692812, 34.777240, 34.782435, 34.782762
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // For find device on the map
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    UIBarButtonItem *currentLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location_arrow.png"] style:UIBarButtonItemStyleDone target:self action:@selector(currentLocationAction:)];
    
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    
    UIBarButtonItem *zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionShowAll:)];
    
    self.navigationItem.rightBarButtonItems = @[currentLocation, zoomButton];
    
    self.geoCoder = [[CLGeocoder alloc] init];
    
    self.allStudents = [[NSArray alloc] init];
    self.allStudents = [NSArray arrayWithArray:[self addStudentsOnMap]];
    
    [self placeStudentsOnMap:self.allStudents];
    
}

- (void) placeStudentsOnMap:(NSArray*) array {
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (EGBStudent *student in array) {
        
        MapAnnotation *annotation = [[MapAnnotation alloc] init];
        annotation.title = [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
        annotation.subtitle = [NSString stringWithFormat:@"Year of Birth: %ld", student.yearOfBirth];
        annotation.coordinate = student.location;
        [annotations addObject:annotation];
    }
    
    [self.mapView addAnnotations:annotations];
}

- (NSMutableArray*) addStudentsOnMap {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 10; i++) {
        
        EGBStudent *student = [EGBStudent randomStudent];
        student.location = CLLocationCoordinate2DMake(latitudes[i], longitudes[i]);
        [array addObject:student];
    }
    
    return array;
}

- (void) dealloc {
    
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
}

#pragma mark - Actions

- (void) addAction:(UIBarButtonItem*) sender {
    
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    annotation.title = @"Test Title";
    annotation.subtitle = @"Test Subtitle";
    annotation.coordinate = self.mapView.region.center;
    
    [self.mapView addAnnotation:annotation];
}

- (void) actionShowAll:(UIBarButtonItem*) sender {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        static double delta = 20000;
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta *2);
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    
    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
}

#pragma mark - CLLocationManagerDelegate

// For aprove finding current location
- (void) locationManager:(CLLocationManager*) manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.location = locations.lastObject;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        return nil;
    }
    
    static NSString *identifier = @"Annotation";
    
    MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    CLLocationCoordinate2D studentCoordinate = annotation.coordinate;
    
    // Checking gender
    NSString *studentGender = [[NSString alloc] init];
    
    for (EGBStudent *student in self.allStudents) {
        
        if (student.location.latitude == studentCoordinate.latitude && student.location.longitude == studentCoordinate.longitude) {
            
            studentGender = student.gender;
        }
    }
    
    if (!pin) {
        
        pin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        if ([studentGender isEqualToString:@"Male"]) {
            pin.image = [UIImage imageNamed:@"male.png"];
        } else {
            pin.image = [UIImage imageNamed:@"female.png"];
        }
        
        pin.canShowCallout = YES;
        pin.draggable = YES;
        
        UIButton *descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = descriptionButton;
        
        UIButton *directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
        pin.leftCalloutAccessoryView = directionButton;
        
    } else {
        
        pin.annotation = annotation;
    }
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding) {
        
        CLLocationCoordinate2D location = view.annotation.coordinate;
        MKMapPoint point = MKMapPointForCoordinate(location);
        
        NSLog(@"\nlocation: {%f, %f},\npoint = %@", location.longitude, location.latitude, MKStringFromMapPoint(point));
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        return renderer;
    }
    
    return nil;
}

#pragma mark - Alert Dialog

- (void) showAlertWithTitle:(NSString*) title andMessage:(NSString*) message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions for Objects on the Map

- (void) actionDescription:(UIButton*) sender {

    MKAnnotationView *annotationView = [sender superAnnotationView];

    if (!annotationView) {
        return;
    }

    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;

    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];

    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    
    NSString *studentInfo = [[NSString alloc] init];
    
    for (EGBStudent *student in self.allStudents) {
        
        if (student.location.latitude == coordinate.latitude && student.location.longitude == coordinate.longitude) {
            studentInfo = [NSString stringWithFormat:@"Name: %@,\n Surname: %@,\n Year of Birth: %ld,\n Gender: %@", student.firstName, student.lastName, student.yearOfBirth, student.gender];
        }
    }
    
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {

        NSString *message = nil;

        if (error) {

            message = [error localizedDescription];

        } else {

            if ([placemarks count] > 0) {

                MKPlacemark *placeMark = (MKPlacemark*)[placemarks firstObject];

                message = [NSString stringWithFormat:@"City: %@,\n Country: %@,\n CountryCode: %@,\n Street: %@,\n Name: %@,\n State: %@", placeMark.locality, placeMark.country, placeMark.ISOcountryCode, placeMark.thoroughfare, placeMark.name, placeMark.administrativeArea];
                
            } else {

                message = @"No Placemarks Found";
            }
        }

        [self showAlertWithTitle:@"Location" andMessage:[NSString stringWithFormat:@"%@,\n Address: %@", studentInfo, message]];
    }];
}

- (void) actionDirection:(UIButton*) sender {
    
    MKAnnotationView *annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    if ([self.directions isCalculating]) {
        [self.directions cancel];
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    request.destination = destination;
    
    request.transportType = MKDirectionsTransportTypeAny;
    
    request.requestsAlternateRoutes = YES;
    
    self.directions = [[MKDirections alloc] initWithRequest:request];
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            
            [self showAlertWithTitle:@"Error" andMessage:[error localizedDescription]];
        } else if ([response.routes count] == 0) {
            
            [self showAlertWithTitle:@"Error" andMessage:@"No routes found"];
        } else {
            
            [self.mapView removeOverlays:[self.mapView overlays]];
            
            NSMutableArray *array = [NSMutableArray array];
            
            for (MKRoute *rount in response.routes) {
                
                [array addObject:rount.polyline];
            }
            
            [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
        }
    }];
    
    
}

#pragma mark - Actions on the View Controller

- (void) currentLocationAction:(UIBarButtonItem*) sender {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}



@end
