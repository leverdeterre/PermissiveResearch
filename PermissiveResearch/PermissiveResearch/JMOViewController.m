//
//  JMOViewController.m
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/26/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import "JMOViewController.h"

#import "PermissiveScoringMatrix.h"
#import "PermissiveObject.h"
#import "PermissiveResearchDatabase.h"
#import "PermissiveOperations.h"
#import "PermissiveAlignementMethods.h"

#import "JMOTableViewCell.h"
#import "UIView+WaitingView.h"

@interface JMOViewController () <UITableViewDataSource,UITextFieldDelegate, PermissiveResearchDatasource, PermissiveResearchDelegate>
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
    [[PermissiveResearchDatabase sharedDatabase] setDelegate:self];
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
    //[self searchStringUsingPredicates:final];
    [self searchString:final];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)searchString:(NSString *)searchedString
{
    NSLog(@"Start search by matrix");
    [self.tableView addWaitingView];
    [[PermissiveResearchDatabase sharedDatabase] searchString:searchedString withOperation:ScoringOperationTypeHeuristic];
}

-(void)searchStringUsingPredicates:(NSString *)searchedString
{
    NSLog(@"Start search Using Predicates ");
    NSPredicate *predicates = [NSCompoundPredicate orPredicateWithSubpredicates:
                               @[
                                 [NSPredicate predicateWithFormat:@"name == %@",searchedString],
                                 [NSPredicate predicateWithFormat:@"gender == %@",searchedString],
                                 [NSPredicate predicateWithFormat:@"company == %@",searchedString],
                                 [NSPredicate predicateWithFormat:@"email == %@",searchedString]
                                 ]];

    /*NSArray *filteredList = */[self.searchedList filteredArrayUsingPredicate:predicates];
    NSLog(@"End search Using Predicates ");
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
        /*
         {
         "id": 0,
         "guid": "2900f458-80ef-4b14-bbca-2c15ca81587c",
         "isActive": true,
         "balance": "$3,341.12",
         "picture": "http://placehold.it/32x32",
         "age": 27,
         "name": "Naomi Pope",
         "gender": "female",
         "company": "ASIMILINE",
         "email": "naomipope@asimiline.com",
         "phone": "+1 (909) 412-3639"
         },
         */
        [[PermissiveResearchDatabase sharedDatabase] addRetainedObjet:dict forKey:[dict objectForKey:@"name"]];
        [[PermissiveResearchDatabase sharedDatabase] addRetainedObjet:dict forKey:[dict objectForKey:@"gender"]];
        [[PermissiveResearchDatabase sharedDatabase] addRetainedObjet:dict forKey:[dict objectForKey:@"company"]];
        [[PermissiveResearchDatabase sharedDatabase] addRetainedObjet:dict forKey:[dict objectForKey:@"email"]];

    }
    
    self.searchedList = list;
}

-(NSInteger)customCostForEvent:(ScoringEvent)event
{
    switch (event) {
        case ScoringEventPerfectMatch:
            return 2;
            break;
           
        case ScoringEventNotPerfectMatchKeyboardAnalyseHelp:
            return 1;
            break;
            
        case ScoringEventNotPerfectBecauseOfAccents:
            return 2;
            break;
            
        case ScoringEventLetterAddition:
            return -1;
            break;
            
        default:
            break;
    }
    
    return NSNotFound;
}

#pragma mark PermissiveResearchDelegate

-(void)searchCompletedWithResults:(NSArray *)results
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView removeWaitingView];
        self.findedElements = results;
        [self.tableView reloadData];
        NSLog(@"End search by matrix");
    });
}

@end
