//
//  ChatViewController.m
//  Spree
//
//  Created by Riley Steele Parsons on 4/7/16.
//  Copyright © 2016 Riley Steele Parsons. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ChatViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChatCell"];
    
    RAC(self.chatViewModel, typedText) = self.textView.rac_textSignal;
    
    self.rightButton.rac_command = self.chatViewModel.sendMessageCommand;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.chatViewModel.active = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.chatViewModel.active = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
