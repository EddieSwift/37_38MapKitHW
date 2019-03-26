//
//  EGBStudent.h
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/26/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EGBStudent : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSInteger yearOfBirth;
@property (strong, nonatomic) NSString *gender;
@property (assign, nonatomic) CLLocationCoordinate2D location;

+ (EGBStudent*) randomStudent;

@end

NS_ASSUME_NONNULL_END
