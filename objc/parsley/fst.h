//
//  fst.h
//  parsley
//
//  Created by Harry Schmidt on 9/9/13.
//  Copyright (c) 2013 Harry Schmidt. All rights reserved.
//

#ifndef fst_h
#define fst_h

#include <stdint.h>
#include <stdio.h>

typedef struct fst_node {
  uint32_t    edge_list_offset;
  uint16_t    edge_list_len;
  uint8_t     terminal;
} fst_node_t;

typedef struct fst_edge {
  uint32_t    to;
  uint16_t    in;
  uint16_t    out;
} fst_edge_t;

typedef struct fst {
  fst_node_t* nodes;
  fst_edge_t* edges;
  char**      symbols;
  int         node_count;
  int         edge_count;
  int         symbol_count;
} fst_t;

typedef struct fst_iterator {
  fst_t* fst;
  void* opaque;
} fst_iterator_t;

int
fst_load_att(FILE* ats, FILE* ate, fst_t* fst);

void
fst_destroy(fst_t* fst);

void
fst_print(fst_t* fst);

void
fst_new_iterator(fst_t* fst, fst_iterator_t* iter);

void
fst_iterator_reset(fst_iterator_t* iter, const char* in_tape);

void
fst_iterator_destroy(fst_iterator_t* iter);

int
fst_iterate(fst_iterator_t* iter);

void
fst_iterator_out(fst_iterator_t* iter, char* in, int n);

#endif
