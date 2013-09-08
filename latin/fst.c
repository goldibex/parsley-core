#include <stdio.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

#define FST_LINE_MAX 256 // max line len in an FST source is 256 bytes

typedef struct {
  uint32_t    to;
  uint8_t     last_in_list;
  uint8_t     terminal;
  const char* in;
  const char* out;
} fst_edge_t;

typedef struct {
  fst_edge_t* edges;
  char*       symbols;
} fst_t;

void
fst_destroy(fst_t* fst) {
  free(fst->edges);
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
  int edge_count = 0,
      terminal_node_count = 0;
  while (fgets(fst_line, FST_LINE_MAX, ate)) {
    switch (sscanf(fst_line, "%d %d %d %d", &from, &to, &in, &out)) {
      case 1: // terminal node indicator
        terminal_node_count++;
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

  fst_edge_t* edges = malloc(edge_count * sizeof(*edges));
  char* symbols = malloc(symbol_size * sizeof(*symbols));

  fst->edges = edges;
  fst->symbols = symbols;

  char** symbol_lookup = malloc(symbol_count * sizeof(*symbol_lookup));
  uint32_t* node_lookup = malloc(node_count * sizeof(*node_lookup));
  uint32_t* terminal_nodes = calloc(node_count, sizeof(*terminal_nodes));
  node_lookup[0] = 0;

  // read the symbol table
  i = 0;
  while (fgets(fst_line, FST_LINE_MAX, ats)) {
    int symbol_len = strlen(fst_line) - 1;
    fst_line[symbol_len] = '\0'; // chomp

    strcpy(symbols, fst_line);
    symbol_lookup[i++] = symbols;
    symbols += symbol_len + 1;
  }

  // read the edge table  
  i = 0;
  int terminal_node_id = 0,
      prev_from = 0;
  while (fgets(fst_line, FST_LINE_MAX, ate)) {
    switch (sscanf(fst_line, "%d %d %d %d", &from, &to, &in, &out)) {
      case 1: // terminal node indicator
        terminal_nodes[from] = 1;
        break;
      case 4: // edge
        if (from != prev_from) {
          node_lookup[from] = i;
          prev_from = from;
        }
        edges[i] = (fst_edge_t){to, 0, 0, symbol_lookup[in], symbol_lookup[out]};
        break;
    }
    i++;
  }

  // one last loop, to set the edges' 'to' pointer properly
  for (i = 0; i < edge_count; i++) {
    if (terminal_nodes[edges[i].to]) {
      edges[i].terminal = 1;
    }
    edges[i].to = node_lookup[edges[i].to];
  }

  /*
 * // one last loop, to set the edges' "to" pointer properly
  while (i > 0) {
    edges[i].to = node_lookup[j] - node_lookup;
    i--;
  }
*/
  free(terminal_nodes);
  free(node_lookup);
  free(symbol_lookup);
  return 0;
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

  fst_destroy(&fst);
  fclose(ats_file);
  fclose(ate_file);
  return 0;
}
