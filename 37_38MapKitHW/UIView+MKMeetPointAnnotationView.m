//
//  UIView+MKMeetPointAnnotationView.m
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 4/22/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import "UIView+MKMeetPointAnnotationView.h"

@implementation UIView (MKMeetPointAnnotationView)

- (MKAnnotationView*) superAnnotationView {
    
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView*)self;
    }
    
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
}

@end
