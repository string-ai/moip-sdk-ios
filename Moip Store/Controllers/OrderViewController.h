//
//  OrderViewController.h
//  Moip Store
//
//  Created by Fernando Nazario Sousa on 31/07/14.
//  Copyright (c) 2014 Moip Pagamentos S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MoipSDK/MoipSDK.h>
#import <MoipSDK/MPKMessage.h>

@interface OrderViewController : UITableViewController <UITextFieldDelegate>

@property NSArray *productList;
@end
