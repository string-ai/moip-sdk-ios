//
//  ProducstCell.h
//  Moip Store
//
//  Created by Fernando Nazario Sousa on 31/07/14.
//  Copyright (c) 2014 Moip Pagamentos S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProducstCell : UITableViewCell

@property IBOutlet UIImageView *productimage;
@property IBOutlet UILabel *lblName;
@property IBOutlet UILabel *lblDetail;
@property IBOutlet UILabel *lblAmount;
@property IBOutlet UITextField *txtQuantity;

@end
