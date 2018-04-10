//
//  aop.m
//  AnalyzerCFunction
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <mach/task_info.h>
#import <mach/task.h>
#import <mach/thread_act.h>
#import <mach/mach_init.h>
#import <mach/vm_map.h>

void instanceMethodExchange(Class clazz, SEL sel, SEL esel)
{
    Method oriMethod = class_getInstanceMethod(clazz, sel);
    Method aopMethod = class_getInstanceMethod(clazz, esel);
    BOOL didAddMethod = class_addMethod(clazz, sel, method_getImplementation(aopMethod), method_getTypeEncoding(aopMethod));
    if (didAddMethod) {
        class_replaceMethod(clazz, esel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        class_addMethod(clazz, esel, method_getImplementation(aopMethod), method_getTypeEncoding(aopMethod));
        method_exchangeImplementations(oriMethod, aopMethod);
    }
}

double usageOfCurrentAPPCPU()
{
    // ref: http://stackoverflow.com/questions/8223348/ios-get-cpu-usage-from-application
    static kern_return_t kr;
    static task_info_data_t tinfo;
    static mach_msg_type_number_t task_info_count = TASK_INFO_MAX;

    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS)
        return -1;

    static thread_array_t         thread_list;
    static mach_msg_type_number_t thread_count;
    static thread_info_data_t     thinfo;
    static mach_msg_type_number_t thread_info_count;
    static thread_basic_info_t basic_info_th;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS)
        return -1;

    long tot_sec = 0;
    long tot_usec = 0;
    double tot_cpu = 0;

    for (int j = 0; j < thread_count; ++j) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS)
            return -1;

        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
        }

    } // for each thread
    if (tot_cpu - 1 > 0.00000001) {
        tot_cpu = 1;
    }
    vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    return tot_cpu * 100;
}

NSInteger GetCurrentMallocAllocSize()
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;

    int r = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, & count);

    return r == KERN_SUCCESS ? info.resident_size : -1;
}

