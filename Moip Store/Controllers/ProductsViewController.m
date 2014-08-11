//
//  ProductsViewController.m
//  Moip Store
//
//  Created by Fernando Nazario Sousa on 31/07/14.
//  Copyright (c) 2014 Moip Pagamentos S.A. All rights reserved.
//

#import "ProductsViewController.h"
#import "OrderViewController.h"
#import "Utilities.h"
#import "Product.h"
#import "ProducstCell.h"

#define kSEGUE_ORDER @"SEGUE_ORDER"

@interface ProductsViewController ()
{
    NSArray *productList;
    NSMutableDictionary *selectedProductList;
}

@property (weak, nonatomic) IBOutlet UIButton *btnMakeOrder;

@end

@implementation ProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.btnMakeOrder.layer.cornerRadius = 7.5f;
    self.btnMakeOrder.alpha = 0;
    
    selectedProductList = [NSMutableDictionary new];
    
    Product *product = [Product new];
    productList = [product productList];
    
    [self.tableView reloadData];
}

- (void) refreshAmountOrder
{
    [self showHideBtnOrder];
    
    NSInteger totalAmount = 0;
    for (Product *p  in selectedProductList.allValues)
    {
        totalAmount = totalAmount + (p.amount * p.quantity);
    }
    
    [self.btnMakeOrder setTitle:[NSString stringWithFormat:@"Fechar Pedido. Total: %@", [Utilities currency:@(totalAmount / 1000)]] forState:UIControlStateNormal];
}

- (void) showHideBtnOrder
{
    if (selectedProductList.allKeys.count > 0)
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.btnMakeOrder.alpha = 1;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.btnMakeOrder.alpha = 0;
        }];
    }
}

#pragma mark - IBActions
- (IBAction)btnMakeOrderTouched:(id)sender
{
    [self performSegueWithIdentifier:kSEGUE_ORDER sender:nil];
}

#pragma mark - Table view data source
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Doces";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProducstCell *cell = (ProducstCell *)[tableView dequeueReusableCellWithIdentifier:@"CellProductId" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    Product *p = productList[indexPath.row];
    cell.productimage.image = p.image;
//    cell.lblName.text = p.name;
    cell.lblDetail.text = p.name;
    if (p.stock > 0)
    {
        cell.lblAmount.text = [Utilities currency:@(p.amount / 1000)];
    }
    else
    {
        cell.lblAmount.text = @"Não Disponível";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProducstCell *newCell = (ProducstCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        newCell.accessoryType = UITableViewCellAccessoryNone;
        [selectedProductList removeObjectForKey:@(indexPath.row)];
    }
    else
    {
        Product *selectedProduct = productList[indexPath.row];
        if (selectedProduct.stock > 0)
        {
            selectedProduct.quantity = 1;
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedProductList setObject:selectedProduct forKey:@(indexPath.row)];
        }
    }
    
    [self refreshAmountOrder];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OrderViewController *orderViewController = (OrderViewController *)segue.destinationViewController;
    orderViewController.productList = [selectedProductList.allValues copy];
}


@end
