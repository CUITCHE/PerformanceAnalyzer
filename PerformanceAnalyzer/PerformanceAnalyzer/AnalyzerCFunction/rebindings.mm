//
//  Rebindings.c
//  AnalyzerCFunction
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <malloc/malloc.h>
#import <fishhook/fishhook.h>
#import <Foundation/Foundation.h>
#import <atomic>

static void* (*orig_malloc)(size_t size);
static void (*orig_free)(void *ptr);

void (*malloc_callback)(size_t size) = nullptr;
void (*free_callback)(size_t size) = nullptr;

static std::atomic<NSInteger> _memory_size(0);
FOUNDATION_EXPORT NSInteger GetCurrentMallocAllocSize() { return _memory_size; }

void* my_malloc(size_t size)
{
    void *ptr = orig_malloc(size);
    size_t sz = malloc_size(ptr);
    _memory_size += sz;
    if (malloc_callback) {
        malloc_callback(sz);
    }
    return ptr;
}

void my_free(void *ptr)
{
    size_t sz = malloc_size(ptr);
//    _memory_size -= sz;
    if (free_callback) {
        free_callback(sz);
    }
    orig_free(ptr);
}

__attribute__((constructor)) void rebinding_main()
{
    rebind_symbols((struct rebinding[2]){ {"malloc", (void *)my_malloc, (void **)&orig_malloc}, {"free", (void *)my_free, (void **)&orig_free}}, 2);
}
