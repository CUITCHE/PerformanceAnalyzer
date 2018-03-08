//
//  Rebindings.c
//  AnalyzerCFunction
//
//  Created by He,Junqiu on 2018/3/8.
//  Copyright © 2018年 hejunqiu. All rights reserved.
//

#import <malloc/malloc.h>
@import fishhook;

static void* (*orig_malloc)(size_t size);
static void (*orig_free)(void *ptr);

void (*malloc_callback)(size_t size) = 0;
void (*free_callback)(size_t size) = 0;

void* my_malloc(size_t size)
{
    void *ptr = orig_malloc(size);
    if (malloc_callback) {
        malloc_callback(malloc_size(ptr));
    }
    return ptr;
}

void my_free(void *ptr)
{
    if (free_callback) {
        free_callback(malloc_size(ptr));
    }
    orig_free(ptr);
}

__attribute__((constructor)) void rebinding_main()
{
    rebind_symbols((struct rebinding[2]){ {"malloc", my_malloc, (void *)&orig_malloc}, {"free", my_free, (void *)&orig_free}}, 2);
}
