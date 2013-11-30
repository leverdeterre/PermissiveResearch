//
//  JMOViewController.m
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/26/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "JMOViewController.h"

#import "PermissiveObject.h"
#import "PermissiveResearchDatabase.h"
#import "PermissiveOperations.h"
#import "PermissiveAlignementMethods.h"

#import "JMOTableViewCell.h"
#import "UIView+WaitingView.h"

@interface JMOViewController () <UITableViewDataSource,UITextFieldDelegate, PermissiveResearchDatasource>
@property (strong, nonatomic) NSMutableArray *allElements;
@property (strong, nonatomic) NSArray *findedElements;
@property (strong, nonatomic) NSArray *searchedList;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JMOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"JMOTableViewCell" bundle:Nil] forCellReuseIdentifier:@"JMOTableViewCell"];
    self.tableView.dataSource = self;
    self.textField.delegate = self;
    
    [[PermissiveResearchDatabase sharedDatabase] setDatasource:self];
}


#pragma mark TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.findedElements.count;
}

- (JMOTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMOTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"JMOTableViewCell"];
    
    PermissiveObject *obj = [self.findedElements objectAtIndex:indexPath.row];
    NSDictionary *dict = [obj refencedObject];
    cell.labelName.text = [dict objectForKey:@"name"];
    cell.labelScore.text = [NSString stringWithFormat:@"%d", obj.score];
    return cell;
}

#pragma mark Textfield delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *final = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSLog(@"Start search by matrix");
    [self.tableView addWaitingView];
    [[ScoringOperationQueue mainQueue] cancelAllOperations];

    
    ExactScoringOperation *ope = [[ExactScoringOperation alloc] init];
    ope.searchedString = final;
    
    SearchCompletionBlock block = ^(NSArray *results) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.findedElements = results;
            [self.tableView reloadData];
            [self.tableView removeWaitingView];
            NSLog(@"End search by matrix");
        });
    };
    
    [ope setCustomCompletionBlock:block];
    [[ScoringOperationQueue mainQueue] addOperation:ope];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark ScoringDatabaseDatasource

-(void)rebuildDatabase
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"data5000"
                                                         ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    NSMutableArray *list = [NSMutableArray new];
    for (NSDictionary *dict in json) {
        [list addObject:dict];
        [[PermissiveResearchDatabase sharedDatabase] addRetainedObjet:dict forKey:[dict objectForKey:@"name"]];
    }
    
    self.searchedList = list;
}

- (NSArray *)filteredArray:(NSArray *)list withFilter:(NSString *)filter
{
    
    if ([filter length] == 0) {
        return list;
    }
    
    NSArray *result = nil;
	   
    NSString *filteredString = [filter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    filteredString = [filteredString stringByReplacingOccurrencesOfString:@" " withString:@"( |\\-|')"];
    
    filteredString = [filteredString lowercaseString];
    
    NSString *regex = nil;
    if ([filteredString rangeOfString:@"ste"].location != NSNotFound) {
        NSString *filteredStringWithSt = [filteredString stringByReplacingOccurrencesOfString:@"ste" withString:@"sainte"];
        regex = [NSString stringWithFormat:@"self matches[cd] \".*%@.*|.*%@.*\"",
                 filteredString, filteredStringWithSt];
    } else if ([filteredString rangeOfString:@"st"].location != NSNotFound) {
        NSString *filteredStringWithSt = [filteredString stringByReplacingOccurrencesOfString:@"st" withString:@"saint"];
        regex = [NSString stringWithFormat:@"self matches[cd] \".*%@.*|.*%@.*\"",
                 filteredString, filteredStringWithSt];
    } else {
        regex = [NSString stringWithFormat:@"self matches[cd] \".*%@.*\"", filteredString];
    }
    
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:regex];
    
    //    BKLog(@"** regex: %@", regex);
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [aPredicate evaluateWithObject:[evaluatedObject name]];
    }];
    result = [list filteredArrayUsingPredicate:predicate];
    
    //	BKLog(@"Filtering %i stations with filter: %@ -- Results: %i", [list count], filter, [result count]);
	return result;
    
}

@end
