//
//  EGBPopover.h
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/26/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EGBPopover : UITableViewController <StudentInfoDelegate>

@property (weak, nonatomic) IBOutlet UILabel *studentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentSurnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentGenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentStreetLabel;

- (IBAction)doneBarButtonAction:(UIBarButtonItem *)sender;



@end

NS_ASSUME_NONNULL_END
