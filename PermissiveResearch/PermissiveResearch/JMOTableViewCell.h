//
//  JMOTableViewCell.h
//  PermissiveSearch
//
//  Created by Jerome Morissard on 10/28/13.
//  Copyright (c) 2013 Jerome Morissard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMOTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelScore;

@end
