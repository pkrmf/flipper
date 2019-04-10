//
//  UserDefaultsViewController.m
//  Sample
//
//  Created by Marc Terns on 10/7/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "UserDefaultsViewController.h"

@interface UserDefaultsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) dispatch_block_t block;
@end

@class Department;

@interface Person:NSObject
@property (strong,nonatomic)Department * department;
@end

@implementation Person
-(void)dealloc{
    NSLog(@"dealloc person");
}

@end
@interface Department: NSObject
@property (strong,nonatomic)Person * person;
@end

@implementation Department
-(void)dealloc{
    NSLog(@"dealloc Department");
}
@end

@implementation UserDefaultsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:nil];
    }
    return self;
}

- (void)viewDidLoad {
    Person * person = [[Person alloc] init];
    Department * department = [[Department alloc] init];
    person.department = department;
    department.person = person;
}

- (IBAction)tappedSave:(id)sender {
    [self.userDefaults setObject:self.valueTextField.text forKey:self.keyTextField.text];
}

@end
