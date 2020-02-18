//
//  main.m
//  Objective-C的本质2
//
//  Created by 赵鹏 on 2019/4/22.
//  Copyright © 2019 赵鹏. All rights reserved.
//

/**
 在终端中通过命令行的方式把main.m文件编译成C++文件(main-arm64.cpp)。
 */
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

//定义一个Student类：
@interface Student : NSObject
{
    @public
    int _no;
    int _age;
}

//从main-arm64.cpp文件中复制过来的，它表示NSObject类的底层实现。
struct NSObject_IMPL {
    Class isa;
};

/**
 由C++文件可以知道，自定义Student类的底层实现如下：
 因为自定义的Student类继承于NSObject类，所以父类的成员变量(Class isa)放在前面，自己的成员变量(int _no, int _age)放在后面。
 */
struct Student_IMPL {
    Class isa;  //占8字节内存
    int _no;  //int类型占4字节内存
    int _age;  //占4字节内存
};

@end

@implementation Student

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /**
         student对象的内部包含三个成员变量：isa、_no、_age，在系统中有三个内存空间来存储这三个成员变量，并且以结构体中最前面的成员变量(isa)的地址值为这个结构体的地址值。
         */
        Student *student = [[Student alloc] init];
        student->_no = 4;
        student->_age = 5;
        
        /**
         因为Student类的底层实现就是NSObject_IMPL结构体，所以下面等号左边的结构体指针就等同于右边的对象指针(student)， 不过OC语言要转成C语言需要桥接一下。
         */
        struct Student_IMPL *studentImpl = (__bridge struct Student_IMPL *)(student);
        NSLog(@"no is %d, age is %d", studentImpl->_no, studentImpl->_age);
        
        /**
         下面的两种方法打印的结果都为16个字节。Student类的底层实现就是Student_IMPL结构体，在Student_IMPL结构体中Class isa成员变量占8个字节，int _no成员变量占4个字节，int _age成员变量占4个字节，所以一共是占16个字节。
         */
        NSLog(@"%zd", class_getInstanceSize([Student class]));
        NSLog(@"%zd", malloc_size((__bridge const void *)(student)));
    }
    
    return 0;
}
