#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector.h>
#define DEFAULT_LINESIZE 128
#define STEP_ECHO(n) fprintf(tty_fp, "server %d: line = '%s'\n", (n), line);

int main(int argc, char* argv[]) {
  char line[DEFAULT_LINESIZE] = {0};
  FILE *tty_fp = fopen("/dev/tty", "w");
  /* fgets(line, DEFAULT_LINESIZE, stdin); */
  /* char chara; */
  /* while((chara = fgetc(stdin)) != EOF) { */
  /*   fprintf(tty_fp, "server:%c\n", chara); */
  /* } */
  /* exit(0); */
  while(1) {
    STEP_ECHO(1);
    while(fgets(line, DEFAULT_LINESIZE, stdin)) {
      STEP_ECHO(2);
      fputs(line, stdout);
    }
    STEP_ECHO(3);
  }
  exit(0);
}
