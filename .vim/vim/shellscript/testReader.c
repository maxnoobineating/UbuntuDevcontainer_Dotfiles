#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <fileString.h>
#include <sys/select.h>
#include <poll.h>

#define DEFAULT_LINESIZE 4
#define SIZE_LIMIT 128
/* #define STEP_ECHO(n) fprintf(tty_fp, "echo %d, line = '%s'\n", (n), line); */

int main(int argc, char* argv[]) {
  char *pipename = argv[1];
  usleep(3000);
  int fd = open(pipename, O_NONBLOCK);
  FILE *fp = fdopen(fd, "r");
  char str[SIZE_LIMIT] = {0};
  fgets(str, SIZE_LIMIT, fp);
  /* fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL) | O_NONBLOCK); */
  /* fgets(str, SIZE_LIMIT, stdin); */
  printf("str=\"%s\"\n", str);
}
