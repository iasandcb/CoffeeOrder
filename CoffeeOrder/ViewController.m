//
//  ViewController.m
//  CoffeeOrder
//
//  Created by T on 2014. 1. 15..
//  Copyright (c) 2014년 T. All rights reserved.
//

#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface ViewController ()<NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation ViewController {
    NSMutableData *_buffer;
    NSArray *_result;
}
- (IBAction)logIn:(id)sender {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
        } else {
            NSLog(@"User with facebook logged in! %@", user.email);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"count %d", _result.count);
    return _result.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"COFFEE_CELL" forIndexPath:indexPath];
    NSDictionary *coffee = _result[indexPath.row];
    cell.textLabel.text = coffee[@"name"];
    cell.detailTextLabel.text = [coffee[@"hotOrIced"] boolValue] ? @"Iced" : @"Hot";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"주문" message:@"확인하세요" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"주문", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        // TODO
        //어떤 커피를 선택했나?
        // 요청을 발송한다
        // "https://api.parse.com/1/classes/Order"
        // 단순히 GET을 요청하는 것은 했지만
        NSURL *url = [NSURL URLWithString:@"https://api.parse.com/1/classes/Order"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url] ;
        [request addValue:@"T4JC47GMzVl5a19lIQokMxxE8Nx5WheSeptT8346" forHTTPHeaderField:@"X-Parse-Application-Id"];
        [request addValue:@"2mvT9BGUhPDAOBhKEJbdE3UhWVnyBEhKmgiybXUt" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        // JSON Serialization
        // NSDictionary를 요청 데이터로
        __autoreleasing NSError *error;
        NSDictionary *requestDic =
        @{@"coffee": @"latte", @"orderer" : @"ias"};
        NSData *postData = [NSJSONSerialization dataWithJSONObject:requestDic options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:postData];
        
        // POST에 데이터를 담아 보내는 것은 아직...
        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL URLWithString:@"https://api.parse.com/1/classes/Coffee"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url] ;
    [request addValue:@"T4JC47GMzVl5a19lIQokMxxE8Nx5WheSeptT8346" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request addValue:@"2mvT9BGUhPDAOBhKEJbdE3UhWVnyBEhKmgiybXUt" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _buffer = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSUInteger option = kNilOptions;
    __autoreleasing NSError *error;
    // JSON 파싱:응답 데이터를 NSDictionary
    id result = [NSJSONSerialization JSONObjectWithData:_buffer options:option error:&error];
    NSLog(@"Result : %@", result);
    _result = result[@"results"];
    [self.table reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
