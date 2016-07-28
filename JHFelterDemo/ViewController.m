//
//  ViewController.m
//  JHFelterDemo
//
//  Created by 简豪 on 16/7/25.
//  Copyright © 2016年 codingMan. All rights reserved.
//

#import "ViewController.h"
#import "JHFeilterManager.h"

#define imagName  @"5BXM4H6IZ134.jpg"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *row11;
@property (weak, nonatomic) IBOutlet UITextField *row12;

@property (weak, nonatomic) IBOutlet UITextField *row13;

@property (weak, nonatomic) IBOutlet UITextField *row14;

@property (weak, nonatomic) IBOutlet UITextField *row15;

@property (weak, nonatomic) IBOutlet UITextField *row21;

@property (weak, nonatomic) IBOutlet UITextField *row22;

@property (weak, nonatomic) IBOutlet UITextField *row23;

@property (weak, nonatomic) IBOutlet UITextField *row24;

@property (weak, nonatomic) IBOutlet UITextField *row25;

@property (weak, nonatomic) IBOutlet UITextField *row31;

@property (weak, nonatomic) IBOutlet UITextField *row32;

@property (weak, nonatomic) IBOutlet UITextField *row33;

@property (weak, nonatomic) IBOutlet UITextField *row34;

@property (weak, nonatomic) IBOutlet UITextField *row35;

@property (weak, nonatomic) IBOutlet UITextField *row41;

@property (weak, nonatomic) IBOutlet UITextField *row42;

@property (weak, nonatomic) IBOutlet UITextField *row43;

@property (weak, nonatomic) IBOutlet UITextField *row44;

@property (weak, nonatomic) IBOutlet UITextField *row45;
@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;

@property (nonatomic,strong)NSArray * itemsArr;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    _itemsArr = @[_row11,_row12,_row13,_row14,_row15,
                  _row21,_row22,_row23,_row24,_row25,
                  _row31,_row32,_row33,_row34,_row35,
                  _row41,_row42,_row43,_row44,_row45
                  ];
    
    
    for (UITextField *field in _itemsArr) {
        
        field.layer.cornerRadius = 5;
        field.layer.borderColor = [UIColor orangeColor].CGColor;
        field.layer.masksToBounds = YES;
        field.layer.borderWidth = 1.0;
        field.keyboardType = UIKeyboardTypeNumberPad;
        
    }
    
    _currentImageView.image = [UIImage imageNamed:imagName];
    
    _currentImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImage) name:UITextFieldTextDidChangeNotification object:nil];
}



- (void)showImage{
    
    
    float p[20];
    
    for (NSInteger i=0; i<_itemsArr.count; i++) {
        
        UITextField *textFiled = _itemsArr[i];
        
        if (textFiled.text.length>0) {
            
            p[i] = textFiled.text.floatValue;
        }else{
            
            p[i] = 0.0f;
        }
    }
    
    JHFeilterManager *manager = [JHFeilterManager new];
    
    _currentImageView.image = [manager createImageWithImage:[UIImage imageNamed:imagName] andColorMatrix:p];
    
}


- (IBAction)btnClick:(id)sender {
    
   
    UIImageWriteToSavedPhotosAlbum(_currentImageView.image, nil, nil, nil);
    
    
    float p[20];
    printf("//\nconst float colormatrix_[] = {\n");
    for (NSInteger i=0; i<_itemsArr.count; i++) {
        
        UITextField *textFiled = _itemsArr[i];
        
        if (textFiled.text.length>0) {
            
            p[i] = textFiled.text.floatValue;
        }else{
            
            p[i] = 0.0f;
        }
        
    
        
        if (i==19) {
            
               printf(" %.2f",p[i]);
        }else{
                printf(" %.2f,",p[i]);
        }
        
        if ((i+1)%5==0) {
            if (i!=19) {
                 printf("\n");
                
            }else{
                
            }
           
        }
        
    }
    printf("\n};");
   
//    [manager clear];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    for (UITextField *field in _itemsArr) {
        
        [field resignFirstResponder];
        
    }
    
}

@end
