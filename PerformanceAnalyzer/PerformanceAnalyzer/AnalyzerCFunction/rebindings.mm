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

static std::atomic<NSInteger> _memory_size(0);
FOUNDATION_EXPORT NSInteger GetCurrentMallocAllocSize() { return _memory_size; }

struct Tail {
    size_t magic;
};

#define MAGIC 0xdead7a11
#define TAILSIZE sizeof(struct Tail)

void* my_malloc(size_t size)
{
    void *ptr = orig_malloc(size + TAILSIZE);
    size_t sz = malloc_size(ptr);
    struct Tail *tail = (struct Tail *)((char *)ptr + sz - TAILSIZE);
    tail->magic = MAGIC;
    _memory_size += sz;
    return ptr;
}

void my_free(void *ptr)
{
    if (ptr == nullptr) {
        return;
    }
    size_t sz = malloc_size(ptr);
    struct Tail *tail = (struct Tail *)((char *)ptr + sz - TAILSIZE);
    if (tail->magic == MAGIC) {
        _memory_size -= sz;
    }
    orig_free(ptr);
}

__attribute__((constructor)) void rebinding_main()
{
    rebind_symbols((struct rebinding[2]){ {"malloc", (void *)my_malloc, (void **)&orig_malloc}, {"free", (void *)my_free, (void **)&orig_free}}, 2);
}
