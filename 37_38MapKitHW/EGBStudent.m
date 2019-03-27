//
//  EGBStudent.m
//  37_38MapKitHW
//
//  Created by Eduard Galchenko on 3/26/19.
//  Copyright © 2019 Eduard Galchenko. All rights reserved.
//

#import "EGBStudent.h"

@implementation EGBStudent

static NSString* firstNames[] = {
    
    @"Billie", @"Tamica", @"Crystle", @"Kandi", @"Caridad",
    @"Vanetta", @"Taylor", @"Pinkie", @"Ben", @"Rosanna",
    @"Willard", @"Mireille", @"Alex", @"Elise", @"Trang",
    @"Ty", @"Pierre", @"Floyd", @"Savanna", @"Arvilla",
    @"Whitney", @"Denver", @"Norbert", @"Meghan", @"Tandra",
    @"Jenise", @"Brent", @"Elenor", @"Sha", @"Jessie"
};

static NSString* lastNames[] = {
    
    @"Farrah", @"Laviolette", @"Heal", @"Sechrest", @"Roots",
    @"Homan", @"Starns", @"Oldham", @"Yocum", @"Mancia",
    @"Lenz", @"Gildersleeve", @"Wimbish", @"Bello", @"Beachy",
    @"Jurado", @"William", @"Beaupre", @"Dyal", @"Doiron",
    @"Plourde", @"Bator", @"Krause", @"Odriscoll", @"Corby",
    @"Waltman", @"Michaud", @"Kobayashi", @"Sherrick", @"Woolfolk",
};

static NSInteger amountOfStudents = 30;

+ (EGBStudent*) randomStudent {
    
    EGBStudent *student = [[EGBStudent alloc] init];
    
    student.firstName = firstNames[arc4random() % amountOfStudents];
    student.lastName = lastNames[arc4random() % amountOfStudents];
    student.yearOfBirth = arc4random() % 15 + 1985;
    student.gender = arc4random() % 1000 / 500 ? @"Male" : @"Female";
    
    return student;
}

@end
