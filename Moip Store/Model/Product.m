//
//  Product.m
//  Moip Store
//
//  Created by Fernando Nazario Sousa on 31/07/14.
//  Copyright (c) 2014 Moip Pagamentos S.A. All rights reserved.
//

#import "Product.h"

@implementation Product

- (NSArray *)productList
{
    NSString *url = [[NSBundle mainBundle] pathForResource:@"Products" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:url];
    if (jsonData != nil)
    {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        NSArray *products = json[@"products"];
        
        NSMutableArray *productList = [NSMutableArray new];
        for (NSDictionary *product in products)
        {
            Product *newProduct = [Product new];
            newProduct.productId = product[@"productId"];
            newProduct.name = product[@"name"];
            newProduct.detail = product[@"detail"];
            newProduct.amount = [product[@"amount"] integerValue];
            newProduct.image = [UIImage imageNamed:product[@"image"]];
            newProduct.stock = [product[@"stock"] integerValue];
            
            [productList addObject:newProduct];
        }
        
        return productList;
    }
    return nil;
}

@end
