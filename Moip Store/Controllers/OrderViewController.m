//
//  OrderViewController.m
//  Moip Store
//
//  Created by Fernando Nazario Sousa on 31/07/14.
//  Copyright (c) 2014 Moip Pagamentos S.A. All rights reserved.
//

#import "OrderViewController.h"
#import "Product.h"
#import "ProducstCell.h"
#import "Utilities.h"
#import "MBProgressHUD.h"

#define DEFAULT_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];

@interface OrderViewController ()

@property UITextField *txtNameHolder;
@property MPKView *paymentView;
@property MPKCreditCard *card;
@property BOOL isValidCreditCard;
@property IBOutlet UIButton *btnPayment;
@property UIView *loadingView;
@property MBProgressHUD *HUD;

@end

@implementation OrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.btnPayment.layer.cornerRadius = 7.5f;
    self.btnPayment.alpha = 0;
    
    [MPKMessage setDefaultViewController:self];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.HUD];

    self.paymentView = [[MPKView alloc] initWithFrame:CGRectMake(5, 5, 300, 55) borderStyle:MPKViewBorderStyleNone delegate:self];
    self.paymentView.defaultTextFieldFont = DEFAULT_FONT;
    
    self.txtNameHolder = [[UITextField alloc] initWithFrame:CGRectMake(20, 5, 280, 50)];
    self.txtNameHolder.placeholder = @"Nome (Ex. João S dos Santos)";
    self.txtNameHolder.font = DEFAULT_FONT;
    self.txtNameHolder.delegate = self;

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    self.productList = nil;
}


- (NSString *) calculateTotalAmountOrder
{
    NSInteger totalAmount = 0;
    for (Product *p  in self.productList)
    {
        totalAmount = totalAmount + (p.amount * p.quantity);
    }
    
    return [Utilities currency:@(totalAmount / 1000)];
}

#pragma mark - View Animations
- (void) showHud:(NSString *)msg
{
    if (msg != nil && ![msg isEqualToString:@""] && (NSNull*)msg != [NSNull null])
    {
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = msg;
        [self.HUD show:YES];
    }
}

- (void) showHudPaymentConfirmation
{
	self.HUD.mode = MBProgressHUDModeCustomView;
	self.HUD.labelText = @"Pagamento autorizado!";
    [self.HUD show:YES];
}

- (void) hideHud
{
    [self.HUD hide:YES];
}

- (void) hideHud:(NSString *)msg
{
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.labelText = msg;
    [self.HUD hide:YES afterDelay:1.7f];
}

- (void) showSuccessFeedback:(MPKPaymentTransaction *)transaction
{
    NSString *message = @"Seu pagamento foi autorizado com sucesso!";
    /*
    NSString *message = @"Seu pagamento foi criado com sucesso!";
    if (transaction.status == MPKPaymentStatusAuthorized)
    {
        message = @"Seu pagamento foi autorizado com sucesso!";
    }
    else if (transaction.status == MPKPaymentStatusConcluded)
    {
        message = @"Seu pagamento foi concluido com sucesso!";
    }
    else if (transaction.status == MPKPaymentStatusInAnalysis)
    {
        message = @"Seu pagamento foi criado e está em Analise";
    }
    */
    [MPKMessage showNotificationInViewController:self
                                           title:@"Pagamento criado"
                                        subtitle:message
                                            type:MPKMessageNotificationTypeSuccess
                                        duration:7.20f];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:6.0f];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (void) showErrorFeedback:(NSArray *)errors
{
    NSMutableString *errorMessage = [NSMutableString string];
    for (MPKError *er in errors)
    {
        [errorMessage appendFormat:@"%@\n", er.localizedFailureReason];
    }
    
    [MPKMessage showNotificationInViewController:self
                                           title:@"Oops! Ocorreu um imprevisto..."
                                        subtitle:errorMessage
                                            type:MPKMessageNotificationTypeWarning
                                        duration:7.0f];
}

- (void) createOrder
{
    [self showHud:@"Criando Pedido"];
    
    MPKCustomer *customer = [MPKCustomer new];
    customer.fullname = @"José Silva";
    customer.email = @"jose@gmail.com";
    customer.phoneAreaCode = 11;
    customer.phoneNumber = 999999999;
    customer.birthDate = [NSDate date];
    customer.documentType = MPKDocumentTypeCPF;
    customer.documentNumber = @"36021561848";
    
    MPKAmount *amount = [MPKAmount new];
    amount.shipping = 1000;
    amount.addition = 0;
    amount.discount = 0;
    
    NSMutableArray *mpkItems = [NSMutableArray new];
    for (Product *p in self.productList)
    {
        MPKItem *newItem = [MPKItem new];
        newItem.product = p.name;
        newItem.quantity = p.quantity;
        newItem.detail = p.detail;
        newItem.price = p.amount;
        
        [mpkItems addObject:newItem];
    }
    
    MPKOrder *newOrder = [MPKOrder new];
    newOrder.ownId = @"sandbox_OrderID_xxx";
    newOrder.amount = amount;
    newOrder.items = mpkItems;
    newOrder.customer = customer;
    
    NSMutableURLRequest *rq = [NSMutableURLRequest new];
    rq.HTTPMethod = @"POST";
    rq.URL = [NSURL URLWithString:@"https://test.moip.com.br/v2/orders"];

    [[MoipSDK session] createOrder:rq order:newOrder success:^(MPKOrder *order, NSString *moipOrderId) {
        NSLog(@"Order Created at Moip: %@", moipOrderId);
        [self createPayment:moipOrderId];
    } failure:^(NSArray *errorList) {
        [self hideHud];
        [self showErrorFeedback:errorList];
    }];
}

- (void) createPayment:(NSString *)moipOrderId
{
    [self showHud:@"Criando Pagamento"];
    
    MPKCardHolder *holder = [MPKCardHolder new];
    holder.fullname = self.txtNameHolder.text;
    holder.birthdate = @"1988-04-27";
    holder.documentType = MPKDocumentTypeCPF;
    holder.documentNumber = @"36021561848";
    holder.phoneCountryCode = @"55";
    holder.phoneAreaCode = @"11";
    holder.phoneNumber = @"975902554";
    
    self.card.cardholder = holder;
    
    MPKFundingInstrument *instrument = [MPKFundingInstrument new];
    instrument.creditCard = self.card;
    instrument.method = MPKMethodTypeCreditCard;
    
    MPKPayment *payment = [MPKPayment new];
    payment.moipOrderId = moipOrderId;
    payment.installmentCount = 1;
    payment.fundingInstrument = instrument;
    
    [[MoipSDK session] submitPayment:payment success:^(MPKPaymentTransaction *transaction) {
        [self hideHud];
        [self showSuccessFeedback:transaction];
        
    } failure:^(NSArray *errorList) {
        [self hideHud];
        [self showErrorFeedback:errorList];
    }];
}

#pragma mark -
#pragma mark IBActions
- (IBAction)btnPayTouched:(id)sender
{
    [self createOrder];
}

#pragma mark -
#pragma mark MPKViewDelegate
- (void)paymentViewWithCard:(MPKCreditCard *)aCard isValid:(BOOL)valid
{
    self.isValidCreditCard = valid;
    self.card = aCard;
    if (self.isValidCreditCard)
    {
        [self resignFirstResponder];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.btnPayment.alpha = 1;
        }];
    }
}

#pragma mark - Table view data source
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Seu Pedido";
            break;
        case 1:
            return @"Dados de Pagamento";
            break;
            
        default:
            break;
    }
    
    return @"";
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NSString stringWithFormat:@"Valor total do seu pedido: %@", [self calculateTotalAmountOrder]];
            break;
        case 1:
            return @"";
            break;
            
        default:
            break;
    }
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.productList.count;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        ProducstCell *productCell = (ProducstCell *)[tableView dequeueReusableCellWithIdentifier:@"CellProductId"
                                                                                    forIndexPath:indexPath];
        Product *p = self.productList[indexPath.row];
        productCell.productimage.image = p.image;
        productCell.lblName.text = p.name;
        productCell.lblDetail.text = p.detail;
        productCell.lblAmount.text = [Utilities currency:@(p.amount / 1000)];
        productCell.txtQuantity.tag = indexPath.row;
        productCell.txtQuantity.text = [NSString stringWithFormat:@"%li", (long)p.quantity];
        
        return productCell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellPaymentId"
                                                                forIndexPath:indexPath];

        if (indexPath.row == 0)
        {
            [cell.contentView addSubview:self.txtNameHolder];
        }
        else if (indexPath.row == 1)
        {
            [cell.contentView addSubview:self.paymentView];
        }
        
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 93;
            break;
        case 1:
            return 60;
            break;
        default:
            break;
    }
    
    return 93;
}

/*
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Text Field
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        Product *p = self.productList[textField.tag];
        p.quantity = [textField.text integerValue];
        
        [self.tableView reloadData];
    }
}

@end
