#include <stdio.h>
#include <stdlib.h>

#ifdef _WIN32
#include <string.h>

static char buffer[2048];

char* readline(char *prompt) {
  fputs(prompt, stdout);
  fgets(buffer, 2048, stdin);
  char *cpy = malloc(strlen(buffer) + 1);
  strcpy(cpy, buffer);
  cpy[strlen(cpy) - 1] = '\0';
  return cpy;
}

void add_history(char *unused) {}

#else
#include <editline/readline.h>
#include <editline/history.h>
#endif

#include "mpc.h"


int main(int argc, char **argv) {
  mpc_parser_t *Number = mpc_new("number");
  mpc_parser_t *Operator = mpc_new("operator");
  mpc_parser_t *OpSymbol = mpc_new("op_symbol");
  mpc_parser_t *OpText = mpc_new("op_text");
  mpc_parser_t *Expr = mpc_new("expr");
  mpc_parser_t *Lispy = mpc_new("lispy");

  mpca_lang(MPCA_LANG_DEFAULT,
    "                                                            \
      number: /-?[0-9]+([.][0-9]+)?/ ;                           \
      op_symbol: '+' | '-' | '/' | '*' | '%' ;                   \
      op_text: \"add\" | \"sub\" | \"mul\" | \"div\" | \"mod\" ; \
      operator: <op_symbol> | <op_text> ;                        \
      expr: <number> | '(' <operator> <expr>+ ')' ;              \
      lispy: /^/ <operator> <expr>+ /$/ ;                        \
    ",
    Number, Operator, OpSymbol, OpText, Expr, Lispy);

  puts("HaskLisp version 0.0.0");
  puts("Press Ctrl+c to Exit\n");

  while (1) {
    char *input = readline("\\> ");
    add_history(input);
    mpc_result_t r;
    if (mpc_parse("<stdin>", input, Lispy, &r)) {
      mpc_ast_print(r.output);
      mpc_ast_delete(r.output);
    } else {
      mpc_err_print(r.error);
      mpc_err_delete(r.error);
    }
    free(input);
  }

  mpc_cleanup(6, Number, Operator, OpSymbol, OpText, Expr, Lispy);
  return 0;
}
