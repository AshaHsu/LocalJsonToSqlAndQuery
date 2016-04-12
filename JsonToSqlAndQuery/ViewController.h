//
//  ViewController.h
//  JsonToSqlAndQuery
//
//  Created by AshaHsu on 2016-04-12.
//  Copyright © 2016 AshaHsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Test.h"
@interface ViewController : UIViewController

@property (nonatomic) NSString *dBPath;
@property (nonatomic) sqlite3 *contactDB;
@property (nonatomic) IBOutlet UITextField* input;
@property (nonatomic) IBOutlet UIButton* search;



@property (weak, nonatomic) IBOutlet UILabel *index;
@property (weak, nonatomic) IBOutlet UILabel *active;
@property (weak, nonatomic) IBOutlet UILabel *company;
@property (weak, nonatomic) IBOutlet UILabel *age;
@property (weak, nonatomic) IBOutlet UILabel *balance;
@property (weak, nonatomic) IBOutlet UILabel *income;
@property (weak, nonatomic) IBOutlet UILabel *fullName;


-(IBAction)DataQuery:(id)sender;
@end
int value;

