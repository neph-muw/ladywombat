//
//  ViewController.m
//  ladywombat
//
//  Created by Roman Mykitchak on 2/3/18.
//  Copyright © 2018 Roman Mykitchak. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "XMLReader.h"

@interface ViewController  () 
@property AFHTTPSessionManager *manager;
@property NSArray *posts;
@property NSDictionary *dict;

@property UITableView *tableView;
- (void)viewDA;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://impossibleladywombat.tumblr.com/api/read"]];
    self.posts = [[NSArray alloc] init];
    
    [self.manager.requestSerializer setValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self.manager.requestSerializer setValue:@"text/xml; charset=UTF-8" forHTTPHeaderField:@"Accept"];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/javascript;charset=UTF-8"];
    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml; charset=UTF-8"];
    //
    [self.manager GET:@"/" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        NSError *error = nil;
        
        self.dict = [XMLReader dictionaryForXMLData:responseObject error:error];
        
        NSLog(@"parsedObject xml = %@", self.dict);
        
        id object = [NSJSONSerialization
                     JSONObjectWithData:responseObject
                     options:0
                     error:&error];
        NSLog(@"parsedObject = %@", object);
        
        if(error) { /* JSON was malformed, act appropriately here */ }
            NSLog(@"JSON error %@", error.localizedDescription);
        if([object isKindOfClass:[NSDictionary class]])
        {
            
            NSDictionary *results = object;
            NSLog(@"%@", results);
            self.posts = [results objectForKey:@"posts"];
            [self.tableView reloadData];
        }
        else
        {
            NSLog(@"Parsing error GET not a dictionary");
        }
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self performSelector:@selector(viewDA) withObject:nil afterDelay:20];
}

//-(void)loadView {
//
//}

- (void)viewDA {
    NSLog(@"parsedObject xml2 = %@", self.dict);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *post = self.posts[indexPath.row];
    if( [[post objectForKey:@"type"] isEqualToString:@"photo"] ){
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [post objectForKey:@"photo-url-100"]]];
        cell.imageView.image = [UIImage imageWithData: imageData];
        cell.textLabel.text = [post objectForKey:@"photo-caption"];
    } else if( [[post objectForKey:@"type"] isEqualToString:@"regular"] ) {
        cell.textLabel.text = [post objectForKey:@"regular-title"];
        cell.detailTextLabel.text = [post objectForKey:@"regular-body"];
    }
    
    return cell;
}


@end
