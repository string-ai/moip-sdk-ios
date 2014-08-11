//
//  Utilities.m
//  Moip Store
//
//  Created by Fernando Nazario Sousa on 31/07/14.
//  Copyright (c) 2014 Moip Pagamentos S.A. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *) currency:(NSNumber *) value
{
    NSNumberFormatter *numberformatter = [NSNumberFormatter new];
    numberformatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSString *formattedValue = [numberformatter stringFromNumber:value];
    
    return formattedValue;
}

@end
