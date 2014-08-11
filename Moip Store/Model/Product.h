//
//  Product.h
//  Moip Store
//
//  Created by Fernando Nazario Sousa on 31/07/14.
//  Copyright (c) 2014 Moip Pagamentos S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property NSString *name;
@property NSString *detail;
@property NSInteger amount;
@property NSInteger quantity;
@property NSString *productId;
@property UIImage *image;
@property NSInteger stock;

- (NSArray *) productList;

@end
