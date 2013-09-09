#include <stdio.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#define FST_LINE_MAX 256 // max line len in an FST source is 256 bytes
#define FST_DEPTH_MAX 256 // max depth of nodes in FST
#define FST_EPSILON "<>"
#define FST_EPSILON_LEN 2

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

typedef struct fst_stack {
  const fst_node_t* nodes[FST_DEPTH_MAX];
  uint16_t edge_list_pos[FST_DEPTH_MAX];
  const char* in_tapes[FST_DEPTH_MAX];
  int depth;
} fst_stack_t;

typedef struct fst_iterator {
  fst_t* fst;
  fst_stack_t stack;
} fst_iterator_t;

void
fst_stack_push(fst_stack_t* stack, const fst_node_t* node, uint16_t pos, const char* in_tape) {
  if (stack->depth > FST_DEPTH_MAX) {
    return;
  }
  stack->depth++;
  stack->nodes[stack->depth] = node;
  stack->edge_list_pos[stack->depth] = pos;
  stack->in_tapes[stack->depth] = in_tape;
}

int
fst_stack_pop(fst_stack_t* stack, const fst_node_t** node, uint16_t *pos, const char** in_tape) {
  while (stack->depth > 0) {
    int next_pos = stack->edge_list_pos[stack->depth]++;
    if (next_pos < stack->nodes[stack->depth]->edge_list_len) {
      *pos = next_pos;
      *node = stack->nodes[stack->depth];
      *in_tape = stack->in_tapes[stack->depth];
      return 1;
    }
    stack->depth--;
  }
  *pos = 0;
  *node = NULL;
  *in_tape = NULL;
  return 0;
}

void
fst_destroy(fst_t* fst) {
  free(fst->nodes);
  free(fst->edges);

  int i;
  for (i = 0; i < fst->symbol_count; i++) {
    free(fst->symbols[i]);
  }

  free(fst->symbols);
}

int
fst_load_att(FILE* ats, FILE* ate, fst_t* fst) {
  char fst_line[FST_LINE_MAX];
  int i,
      from, to,
      in, out;

  // find out how much memory we need for the symbol table
  int symbol_size = 0,
      symbol_count = 0;
  while (fgets(fst_line, FST_LINE_MAX, ats)) {
    if (strlen(fst_line) <= 1) {
      printf("AT&T symbol file format error\n");
      return 1;
    }
    fst_line[strlen(fst_line) - 1] = '\0'; // chomp
    symbol_count++;
    symbol_size += strlen(fst_line) + 1; // we add 1 for the null terminator
  }
  if (ferror(ats)) {
    printf("error while reading AT&T symbol file: %s", strerror(ferror(ats)));
    return 1;
  }
  rewind(ats);

  // find out how much memory we need for the edge tables
  int edge_count = 0;
  while (fgets(fst_line, FST_LINE_MAX, ate)) {
    switch (sscanf(fst_line, "%d %d %d %d", &from, &to, &out, &in)) {
      case 1: // terminal node
        break;
      case 4: // edge
        edge_count++;
        break;
      default: // something done broke
        printf("AT&T edge file format error\n");
        return 1;
    }
  }
  if (ferror(ate)) {
    printf("error while reading AT&T edge file: %s", strerror(ferror(ate)));
    return 1;
  }
  rewind(ate);

  // allocate the memory for the tables
  int node_count = from + 1;

  fst_node_t* nodes = calloc(node_count, sizeof(*nodes));
  fst_edge_t* edges = calloc(edge_count, sizeof(*edges));
  char** symbols = calloc(symbol_count, sizeof(*symbols));

  fst->nodes = nodes;
  fst->edges = edges;
  fst->symbols = symbols;
  fst->node_count = node_count;
  fst->edge_count = edge_count;
  fst->symbol_count = symbol_count;

  // read the symbol table
  i = 0;
  while (fgets(fst_line, FST_LINE_MAX, ats)) {
    int symbol_len = strlen(fst_line) - 1;
    fst_line[symbol_len] = '\0'; // chomp

    symbols[i++] = strdup(fst_line);
  }

  // read the edge table  
  i = 0;
  int prev_from = 0,
      j = 0;
  while (fgets(fst_line, FST_LINE_MAX, ate)) {
    switch (sscanf(fst_line, "%d %d %d %d", &from, &to, &out, &in)) {
      case 1: // terminal node indicator
        nodes[from].terminal = 1;
        break;
      case 4: // edge
        if (from != prev_from) {
          if (i > 0) {
            nodes[prev_from].edge_list_len = j;
          }
          nodes[from].edge_list_offset = i;
          prev_from = from;
          j = 0;
        }
        edges[i++] = (fst_edge_t){to, in, out};
        j++;
        break;
    }
  }
  nodes[prev_from].edge_list_len = j;
  return 0;
}

void
fst_print(fst_t* fst) {
  int i, j;
  for (i = 0; i < fst->node_count; i++) {
    for (j = 0; j < fst->nodes[i].edge_list_len; j++) {
      fst_edge_t* edge = fst->edges + fst->nodes[i].edge_list_offset + j;
      printf("%d %d %s %s\n", i, edge->to, fst->symbols[edge->out], fst->symbols[edge->in]);
    }
    if (fst->nodes[i].terminal) {
      printf("%d\n", i);
    }
  }
}

void
fst_iterator_reset(fst_t* fst, fst_iterator_t* iter, const char* in_tape) {
  iter->fst = fst;
  
  iter->stack.nodes[0] = NULL;
  iter->stack.edge_list_pos[0] = 0;
  iter->stack.in_tapes[0] = NULL;

  iter->stack.depth = 1;
  iter->stack.nodes[1] = fst->nodes;
  iter->stack.edge_list_pos[1] = 0;
  iter->stack.in_tapes[1] = in_tape;
}

inline int
fst_epsilon(const char* symbol) {
  return (strlen(symbol) == FST_EPSILON_LEN &&
      strcmp(symbol, FST_EPSILON) == 0);
}

const char*
fst_match(const char* in_tape, const char* symbol) {
  size_t symbol_len = strlen(symbol),
         in_tape_len = strlen(in_tape);
  if (fst_epsilon(symbol)) {
      return in_tape;
  }
  if (symbol_len > in_tape_len) {
    return NULL;
  }
  if (strncmp(symbol, in_tape, symbol_len) == 0) {
    return in_tape + symbol_len;
  }
  return NULL;
}

int
fst_iterate(fst_iterator_t* iter) {
  const char
    *in_tape,
    *new_in_tape,
    *symbol;

  fst_t* fst = iter->fst;
  fst_edge_t* edge;
  const fst_node_t
    *node,
    *node_to;
  uint16_t pos;

  while (fst_stack_pop(&iter->stack, &node, &pos, &in_tape)) {
    edge = fst->edges + node->edge_list_offset + pos;
    symbol = fst->symbols[edge->in];
    if (new_in_tape = fst_match(in_tape, symbol)) {
      node_to = fst->nodes + edge->to;
      fst_stack_push(&iter->stack, node_to, 0, new_in_tape);
      if (strlen(new_in_tape) == 0 && node_to->terminal) {
        return 1;
      }
    }
  }
  return 0;
}

void
fst_iterator_out(fst_iterator_t* iter, char* in, int n) {
  fst_t* fst = iter->fst;
  fst_stack_t* stack = &iter->stack;
  fst_edge_t* edge;
  const char* symbol;

  // wipe out any existing string in the input buffer
  *in = '\0';

  int i;
  for (i = 1; i < stack->depth; i++) {
    edge = fst->edges + stack->nodes[i]->edge_list_offset + stack->edge_list_pos[i] - 1;
    symbol = fst->symbols[edge->out];
    if (!fst_epsilon(symbol)) {
      strncat(in, symbol, n);
      n -= strlen(symbol);
    }
  }
}

int
main(int argc, char *argv[]) {
  FILE *ats_file,
       *ate_file;
  
  if (argc < 3) {
    printf("usage: %s ats_file ate_file\n", argv[0]);
    return 0;
  }
  ats_file = fopen(argv[1], "r");
  if (ats_file == NULL) {
    printf("error opening %s: %s\n", argv[1], strerror(errno));
    return errno;
  }
  ate_file = fopen(argv[2], "r");
  if (ate_file == NULL) {
    printf("error opening %s: %s\n", argv[2], strerror(errno));
    fclose(ats_file);
    return errno;
  }
  fst_t fst;
  if (fst_load_att(ats_file, ate_file, &fst) != 0) {
    printf("fatal error: aborting\n");
  }

  fst_iterator_t iter;
  char in[256], out[256];
  memset(in, 0, 256);
  memset(out, 0, 256);
  while (1) {
    printf("Inflected form: ");
    fgets(in, 256, stdin);
    in[strlen(in) - 1] = '\0'; // chomp
    if (strlen(in) == 0) {
      return 0;
    }
    fst_iterator_reset(&fst, &iter, in);
    while (fst_iterate(&iter)) {
      fst_iterator_out(&iter, out, 256);
      printf("match: %s\n", out);
    }
  }

  fst_destroy(&fst);
  fclose(ats_file);
  fclose(ate_file);
  return 0;
}
