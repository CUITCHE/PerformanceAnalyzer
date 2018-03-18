//
//  rebingdings.m
//  Performance
//
//  Created by hejunqiu on 2018/3/18.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <malloc/malloc.h>
#import <fishhook/fishhook.h>
#import <Foundation/Foundation.h>
#import <atomic>

static void* (*orig_malloc)(size_t size);
static void (*orig_free)(void *ptr);
static void* (*orig_calloc)(size_t n, size_t size);
static void * (*orig_realloc)(void *mem_address, size_t newsize);

static std::atomic<NSInteger> _memory_size(0);
FOUNDATION_EXPORT NSInteger GetCurrentMallocAllocSize() { return _memory_size; }

void* my_malloc(size_t size)
{
    void *ptr = orig_malloc(size);
    size_t sz = malloc_size(ptr);
    _memory_size += sz;
    return ptr;
}

void *my_calloc(size_t n, size_t size)
{
    void *ptr = orig_calloc(n, size);
    return ptr;
}

void *my_realloc(void *mem_address, size_t newsize)
{
    size_t sz = malloc_size(mem_address);
    _memory_size -= sz;
    void *ptr = orig_realloc(mem_address, newsize);
    sz = malloc_size(ptr);
    _memory_size += sz;
    return ptr;
}

void my_free(void *ptr)
{
    size_t sz = malloc_size(ptr);
    _memory_size -= sz;
    orig_free(ptr);
}

__attribute__((constructor)) void rebinding_main()
{
    rebind_symbols((struct rebinding[4]){
        {"malloc", (void *)my_malloc, (void **)&orig_malloc},
        {"calloc", (void *)my_calloc, (void **)&orig_calloc},
        {"realloc", (void *)my_realloc, (void **)&orig_realloc},
        {"free", (void *)my_free, (void **)&orig_free}
    }, 4);
}
