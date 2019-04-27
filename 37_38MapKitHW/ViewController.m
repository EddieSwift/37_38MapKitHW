//
//  ViewController.m
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/24/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MKDirections.h>
#import "MapAnnotation.h"
#import "UIView+MKAnnotationView.h"
#import "EGBStudent.h"
#import "EGBPopover.h"
#import "MeetingPointAnnotation.h"
#import "UIView+MKMeetPointAnnotationView.h"


@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) MKDirections *directions;
@property (strong, nonatomic) NSArray *allStudents;
@property (strong, nonatomic) NSArray *allStudentAnnotations;
@property (strong, nonatomic) NSString *studentAddress;
@property (strong, nonatomic) NSArray *studentArrayPopover;
@property (assign, nonatomic) NSInteger oneMeetPointAdded;

@property (strong, nonatomic) MKCircle *circleOverlayThree;
@property (strong, nonatomic) MKCircle *circleOverlayFive;
@property (strong, nonatomic) MKCircle *circleOverlaySeven;

@property (assign, nonatomic) NSInteger distanceThree;
@property (assign, nonatomic) NSInteger distanceFive;
@property (assign, nonatomic) NSInteger distanceSeven;

@property (assign, nonatomic) CLLocationCoordinate2D meetPin;

@end

@implementation ViewController

static double latitudes[] = {
    
    32.070357, 32.107043, 32.070533, 32.0665637, 32.0638462, 32.056664, 32.0549635, 32.095441, 32.092299,  32.070913, 32.086756, 32.105884, 32.089254, 32.079963, 32.094200, 32.079014, 32.059632, 32.048953, 32.077102, 32.045643
};

static double longitudes[] = {
    
    34.7809829, 34.8044052, 34.767777, 34.7842366, 34.773168, 34.779869, 34.7692812, 34.777240, 34.782435, 34.839005, 34.827558, 34.832626, 34.885517, 34.884136, 34.899509, 34.898396, 34.859574, 34.814088, 34.895852, 34.776931
};

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.oneMeetPointAdded = 0;
    
    self.distanceThree = 0;
    self.distanceFive = 0;
    self.distanceSeven = 0;
    
    // For find device on the map
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    UIBarButtonItem *currentLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location_arrow.png"] style:UIBarButtonItemStyleDone target:self action:@selector(currentLocationAction:)];
    
    //    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    
    UIBarButtonItem *zoomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(actionShowAll:)];
    
    UIBarButtonItem *meetingPointButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMeetingPointAction:)];
    
    UIBarButtonItem *directionStudentsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfinder_24.png"] style:UIBarButtonItemStyleDone target:self action:@selector(directionStudentsAction:)];
    
    self.navigationItem.rightBarButtonItems = @[currentLocation, zoomButton, meetingPointButton, directionStudentsButton];
    
    self.geoCoder = [[CLGeocoder alloc] init];
    
    self.allStudents = [[NSArray alloc] init];
    self.allStudents = [NSArray arrayWithArray:[self addStudentsOnMap]];
    
    [self placeStudentsOnMap:self.allStudents];
    
}

#pragma mark - Actions Bar Buttons

- (void) directionStudentsAction:(NSArray*) array {
    
    NSLog(@"%f, %f", self.meetPin.latitude, self.meetPin.longitude);
    
    NSInteger studentsCount = 0;
    for (EGBStudent *annotation in self.allStudents) {
        
        NSLog(@"%f, %f", annotation.location.latitude, annotation.location.longitude);
        
        if (!annotation) {
            return;
        }
        if ([self.directions isCalculating]) {
            [self.directions cancel];
        }
        BOOL willTakePartInMeeting = NO;
        CLLocationCoordinate2D centerCoord = self.meetPin;
        CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
        CLLocationCoordinate2D coordinate = annotation.location;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        CLLocationDistance dist = [location distanceFromLocation:centerLocation];
        if (dist <= 5000) {
            willTakePartInMeeting = (int)(arc4random_uniform(10 * 1000) / 1000);    //90% probability
        } else if (dist <= 10000) {
            willTakePartInMeeting = (int)(arc4random_uniform(2.5f * 1000) / 1000);  //60% probability
        } else if (dist <= 15000) {
            willTakePartInMeeting = (int)(arc4random_uniform(1.5f * 1000) / 1000);  //33% probability
        } else {
            willTakePartInMeeting = (int)(arc4random_uniform(1.5f * 1000) / 1000);  //9% probability
        }
        if (willTakePartInMeeting) {
            MKDirectionsRequest *request = [MKDirectionsRequest new];
            MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:self.meetPin addressDictionary:nil];
            request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
            MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
            request.destination = destination;
            request.transportType = MKDirectionsTransportTypeAny;
            request.requestsAlternateRoutes = NO;
            
            self.directions = [[MKDirections alloc] initWithRequest:request];
            [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:[error localizedDescription]
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                } else if ([response.routes count] == 0) {
                } else {
                    NSMutableArray *array  = [NSMutableArray array];
                    for (MKRoute *route in response.routes) {
                        [array addObject:route.polyline];
                    }
                    [self.mapView addOverlays:array level:MKOverlayLevelAboveRoads];
                }
            }];
            studentsCount++;
        }
    }
//    self.studentsWIllTakePart.text = [NSString stringWithFormat:@"%ld", studentsCount];
    
//    NSLog(@"%f, %f", self.meetPin.latitude, self.meetPin.longitude);
//
//    for (EGBStudent *student in self.allStudentAnnotations) {
//
//        NSLog(@"%f, %f", student.location.latitude, student.location.longitude);
//
//    MKDirectionsRequest* request = [[MKDirectionsRequest alloc] init];
//
//    MKPlacemark* startPlacemark = [[MKPlacemark alloc] initWithCoordinate:student.location
//                                                        addressDictionary:nil];
//
//    MKMapItem* startDestination = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
//
//    request.source = startDestination;
//
//    MKPlacemark* endPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.meetPin
//                                                      addressDictionary:nil];
//
//    MKMapItem* endDestination = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
//
//    request.destination = endDestination;
//    request.transportType = MKDirectionsTransportTypeAutomobile;
//    request.requestsAlternateRoutes = YES;
//
//    self.directions = [[MKDirections alloc] initWithRequest:request];
//
//    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//
//        if (error) {
//
//        } else if ([response.routes count] == 0) {
//
//        } else {
//
//            [self.mapView addOverlay:[[response.routes firstObject] polyline] level:MKOverlayLevelAboveRoads];
//        }
//    }];
//    }
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
    
    self.allStudentAnnotations = annotations;
    
    [self.mapView addAnnotations:annotations];
}

- (NSMutableArray*) addStudentsOnMap {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 20; i++) {
        
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

- (void) addMeetingPointAction:(UIBarButtonItem*) sender {
    
    MeetingPointAnnotation *annotation = [[MeetingPointAnnotation alloc] init];
    
    // Check that only one meet point can be added
    if (self.oneMeetPointAdded == 0) {
        
        annotation.title = @"Metting Point";
        annotation.subtitle = @"Come here";
        annotation.coordinate = self.mapView.region.center;
        
        [self.mapView addAnnotation:annotation];
        
    } else {
        
        [self showAlertWithTitle:@"Meeting Point" andMessage:@"You may able to add only one meeting point!"];
    }
    
    CLLocationCoordinate2D meetPintLocation = annotation.coordinate;
    
    self.meetPin = meetPintLocation;
    
    for (EGBStudent *student in self.allStudents) {
        
//        MKMetersBetweenMapPoints(student.location, student.location);
        
//        [student.location distanceFromLocation:student.location];
//        [student.location distanceFromLocation:student.location];
        
        MKMapPoint point1 = MKMapPointForCoordinate(student.location);
        MKMapPoint point2 = MKMapPointForCoordinate(meetPintLocation);
        CLLocationDistance distance = MKMetersBetweenMapPoints(point1, point2);
        NSLog(@"Student distance: %f", distance);
        
        if (distance <= 3000) {
            self.distanceThree += 1;
        } else if (distance > 3000 && distance <= 5000) {
            self.distanceFive += 1;
        } else if (distance > 5000 && distance <= 7000) {
            self.distanceSeven += 1;
        }
        
    }
    
    NSLog(@"Students count: %ld", [self.allStudents count]);
    NSLog(@"Three km distance students: %ld", self.distanceThree);
    NSLog(@"Five km distance students: %ld", self.distanceFive);
    NSLog(@"Seven km distance students: %ld", self.distanceSeven);
    
    self.threeDistanceLabel.text = [NSString stringWithFormat:@"%ld", self.distanceThree];
    self.fiveDistanceLabel.text = [NSString stringWithFormat:@"%ld", self.distanceFive];
    self.sevenDistanceLabel.text = [NSString stringWithFormat:@"%ld", self.distanceSeven];
    
    
//    CLLocationDistance distance = [self.allStudents[0] distanceFromLocation:annotation];
    
    self.oneMeetPointAdded++;

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
        pin.draggable = NO;
        
        if ([pin.annotation.title isEqualToString:@"Metting Point"]) {
            
            pin.image = [UIImage imageNamed:@"chocolate_bar.png"];
            pin.canShowCallout = NO;
            pin.draggable = YES;
            
            CLLocationCoordinate2D meetPointCoordinate = annotation.coordinate;
            self.circleOverlayThree = [MKCircle circleWithCenterCoordinate:meetPointCoordinate radius:3000];
            self.circleOverlayFive = [MKCircle circleWithCenterCoordinate:meetPointCoordinate radius:5000];
            self.circleOverlaySeven = [MKCircle circleWithCenterCoordinate:meetPointCoordinate radius:7000];
            
//            [self.circleOverlayFive setTitle:@"Circle"];
            
            [self.mapView addOverlay:self.circleOverlayThree];
            [self.mapView addOverlay:self.circleOverlayFive];
            [self.mapView addOverlay:self.circleOverlaySeven];
        }

        UIButton *descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = descriptionButton;
        
//        UIButton *directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
//        [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
//        pin.leftCalloutAccessoryView = directionButton;
        
    } else {
        
        pin.annotation = annotation;
    }
    
    return pin;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    
    // Removing previous circles oeverlays
    [self.mapView removeOverlay:self.circleOverlayThree];
    [self.mapView removeOverlay:self.circleOverlayFive];
    [self.mapView removeOverlay:self.circleOverlaySeven];
    
    if (newState == MKAnnotationViewDragStateEnding) {
                
        CLLocationCoordinate2D location = view.annotation.coordinate;
        MKMapPoint point = MKMapPointForCoordinate(location);
        
        // Adding new circles overlays after dragging meeting point
        self.circleOverlayThree = [MKCircle circleWithCenterCoordinate:view.annotation.coordinate radius:3000];
        self.circleOverlayFive = [MKCircle circleWithCenterCoordinate:view.annotation.coordinate radius:5000];
        self.circleOverlaySeven = [MKCircle circleWithCenterCoordinate:view.annotation.coordinate radius:7000];
        
        [self.mapView addOverlay:self.circleOverlayThree];
        [self.mapView addOverlay:self.circleOverlayFive];
        [self.mapView addOverlay:self.circleOverlaySeven];
        
        NSLog(@"\nlocation: {%f, %f},\npoint = %@", location.longitude, location.latitude, MKStringFromMapPoint(point));
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    //    if ([overlay isKindOfClass:[MKPolyline class]]) {
    //
    //        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    //        renderer.lineWidth = 2.f;
    //        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
    //        return renderer;
    //    }
    //
    //    return nil;
    
    
    ///
    
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer* renderer = [[MKCircleRenderer
                                       alloc]initWithCircle:(MKCircle *)overlay];
        if ([overlay.title isEqualToString:@"Circle"]) {
            renderer.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.0];
        } else {
           renderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.0];
        }
        
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:1.f alpha:0.9f];
        renderer.lineWidth = 2.f;
        //        aRenderer.lineDashPattern = @[@2, @5];
        //        aRenderer.alpha = 0.5;
        
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
    
    NSMutableArray *studentArrayPopover = [NSMutableArray array];

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
            
            [studentArrayPopover addObject:student.firstName];
            [studentArrayPopover addObject:student.lastName];
            [studentArrayPopover addObject:[NSString stringWithFormat:@"%ld", student.yearOfBirth]];
            [studentArrayPopover addObject:student.gender];
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
                
                [studentArrayPopover addObject:placeMark.country];
                [studentArrayPopover addObject:placeMark.locality];
                [studentArrayPopover addObject:placeMark.thoroughfare];
                
            } else {

                message = @"No Placemarks Found";
            }
        }
        
        EGBPopover *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EGBPopover"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.preferredContentSize = CGSizeMake(400, 400);
        nav.modalPresentationStyle                   = UIModalPresentationPopover;
        nav.popoverPresentationController.sourceView = sender;
        nav.popoverPresentationController.sourceRect = sender.frame;
        [self presentViewController:nav animated:YES completion:nil];
        [vc transferStudentInfoToPopover:studentArrayPopover];
        
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
