//
//  ViewController.m
//  JsonToSqlAndQuery
//
//  Created by AshaHsu on 2016-04-12.
//  Copyright © 2016 AshaHsu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) Test* test;
@property (strong, nonatomic) NSMutableArray *names;

@end

@implementation ViewController


- (void)setUpDatabase
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    _dBPath = [[NSString alloc]
               initWithString: [docsDir stringByAppendingPathComponent:
                                @"test.db"]];
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _dBPath ] == NO)
    {
        const char *dbpath = [_dBPath UTF8String];
        
        if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS TEST (LISTID INTEGER PRIMARY KEY AUTOINCREMENT, ACTIVE TEXT, BALANCE INTEGER FOREIGNKEY, INCOME INTEGER FOREIGNKEY, AGE INTEGER FOREIGNKEY, LISTTPHOTO TEXT,COMPANY TEXT)";
            
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sql_stmt =
            "CREATE TABLE IF NOT EXISTS NAMES (NAMEDATA TEXT PRIMARY KEY, NAMEID INTEGER FOREIGNKEY, LISTID INTEGER FOREIGNKEY, NAME TEXT)";
            
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            
            sqlite3_close(_contactDB);
        } else {
            NSLog(@"Failed to connect to DB");
        }
    }
}

- (void)insertListIntoDatabase:(Test *)test
{
    sqlite3_stmt    *statement;
    const char *dbpath = [_dBPath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO TEST (LISTID, ACTIVE, BALANCE, INCOME, AGE, LISTTPHOTO,COMPANY) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\" ,\"%@\")",
                               test.index, test.isActive, test.balance, test.income, test.age, test.picture,test.company];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Data added");
        }
        sqlite3_finalize(statement);
        
        sqlite3_close(_contactDB);
    }
}

- (void)insertNameIntoDatabase:(NSString *)nameId listId:(NSString *)listId name:(NSString *)name
{
    sqlite3_stmt    *statement;
    const char *dbpath = [_dBPath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO NAMES (NAMEDATA, NAMEID, LISTID, NAME) VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",
                               [NSString stringWithFormat:@"%@/%@", name, listId], nameId, listId, name];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Name added");
        }
        sqlite3_finalize(statement);
        
        sqlite3_close(_contactDB);
    }
}

- (void)populateDatabase
{
    
    NSError* err = nil;
    NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:NULL];
    if (!myJSON) {
        NSLog(@"File couldn't be read!");
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
    
    NSArray *items = [json valueForKeyPath:@"test"];
   _test = [[Test alloc] init];
    [items enumerateObjectsUsingBlock:^(NSDictionary *item , NSUInteger idx, BOOL *stop) {
        _test.index = [item objectForKey:@"index"];
        _test.isActive = [item objectForKey:@"isActive"];
        _test.balance = [item objectForKey:@"balance"];
        _test.income =  [item objectForKey:@"income"];
        _test.age = [item objectForKey:@"age"];
        _test.picture =  [item objectForKey:@"picture"];
        _test.company =  [item objectForKey:@"company"];
        _test.name = [item objectForKey:@"name"];
        NSArray *storesIdArray = [_test.name allKeys];
        NSArray *storesNamesArray = [_test.name allValues];
        [self insertListIntoDatabase:_test];
        for(int i=0;i<[_test.name count];i++) {
            [self insertNameIntoDatabase:[storesIdArray objectAtIndex:i] listId:_test.index name:[storesNamesArray objectAtIndex:i]];
        }
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUpDatabase];
    [self populateDatabase];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getLists
{
    
    const char *dbpath = [_dBPath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT * FROM TEST WHERE LISTID=\"%d\"", value];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                _test = [[Test alloc]init];
                NSString *productId = [[NSString alloc]
                                       initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, 0)];
                _test.index = productId;
                NSString *productActive = [[NSString alloc]
                                           initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 1)];
                _test.isActive = productActive;
                NSString *productBalance = [[NSString alloc]
                                            initWithUTF8String:
                                            (const char *) sqlite3_column_text(statement, 2)];
                _test.balance = productBalance;
                NSString *productIncome = [[NSString alloc]
                                           initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, 3)];
                _test.income = productIncome;
                NSString *productAge = [[NSString alloc]
                                        initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 4)];
                _test.age = productAge;
                NSString *productPhoto = [[NSString alloc]
                                          initWithUTF8String:(const char *)
                                          sqlite3_column_text(statement, 5)];
                _test.picture = [UIImage imageNamed:productPhoto];
                
                
                NSString *companyName = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(statement, 6)];
                _test.company = companyName;
                
            }
            sqlite3_finalize(statement);
            
        }
        sqlite3_close(_contactDB);
    }
}


- (void)getFullNames
{
    
    const char *dbpath = [_dBPath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT NAME FROM NAMES WHERE LISTID=\"%d\"", value];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            _names = [[NSMutableArray alloc]init];
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *myName = [[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 0)];
                [_names addObject:myName];
            }
            sqlite3_finalize(statement);
            
        }
        sqlite3_close(_contactDB);
    }
}


- (void)configureView
{
    NSString *indexString = @"INDEX: ";
    self.index.text=
    [NSString stringWithFormat:@"%@ %@", indexString,_test.index];
    
    if([_test.isActive isEqualToString:@"0"])
    {
        self.active.text = @"NOT ACTIVE";
    }else self.active.text=@"Active";
    
    NSString *companyString = @"COMPANY: ";
    self.company.text =
    [NSString stringWithFormat:@"%@ %@", companyString,_test.company];
    
    NSString *ageString = @"AGE: ";
    self.age.text =
    [NSString stringWithFormat:@"%@ %@", ageString,_test.age];
    
    
    NSString *balancetring = @"BALANCE: ";
    self.balance.text =
    [NSString stringWithFormat:@"%@ %@", balancetring, _test.balance];
    
    
    NSString *incomeString = @"INCOME: ";
    self.income.text =
    [NSString stringWithFormat:@"%@ %@", incomeString, _test.income];
    
    
    [NSString stringWithFormat:@"%@ %@", ageString,_test.age];
    
    
    
    NSString *storeString = @"NAME: ";
    for(int i=0;i<[_names count];i++) {
        storeString = [NSString stringWithFormat:@"%@ %@", storeString, [_names objectAtIndex:i]];
    }
    self.fullName.text = storeString;
}


- (void)getName:(NSString*)string
{
    
    const char *dbpath = [_dBPath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT LISTID FROM NAMES WHERE NAME=\"%@\"",string];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *store = [[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 0)];
                
                value = [store intValue];
                
                
                [self getLists];
                [self getFullNames];
                [self configureView];
                
                
            }
            sqlite3_finalize(statement);
            
        }
        sqlite3_close(_contactDB);
    }
}



-(IBAction)DataQuery:(id)sender
{
    
    NSString *enteredText = [_input text];
    
    if ([enteredText isEqualToString:@""]) {
        NSLog(@"no input");
        
    }else
        
    {
        [self getName:enteredText];
        
    }
    
}

@end
