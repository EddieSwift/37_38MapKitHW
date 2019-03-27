//
//  EGBPopover.m
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/26/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import "EGBPopover.h"
#import "EGBStudent.h"

@interface EGBPopover ()

@property (strong, nonatomic) NSArray *studentInfoArray;

@end

@implementation EGBPopover

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.studentNameLabel.text = self.studentInfoArray[0];
    self.studentSurnameLabel.text = self.studentInfoArray[1];
    self.studentYearLabel.text = self.studentInfoArray[2];
    self.studentGenderLabel.text = self.studentInfoArray[3];
    self.studentCountryLabel.text = self.studentInfoArray[4];
    self.studentCityLabel.text = self.studentInfoArray[5];
    self.studentStreetLabel.text = self.studentInfoArray[6];
}

#pragma mark - StudentInfoDelegate

- (void) transferStudentInfoToPopover:(NSArray*) array {
    
    self.studentInfoArray = array;
}

#pragma mark - Actions

- (IBAction)doneBarButtonAction:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
