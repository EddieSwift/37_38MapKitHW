//
//  UIView+MKAnnotationView.h
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/26/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotationView.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MKAnnotationView)

- (MKAnnotationView*) superAnnotationView;

@end

NS_ASSUME_NONNULL_END
