//
//  MapAnnotation.h
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/26/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end

NS_ASSUME_NONNULL_END
