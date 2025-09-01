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
  FILE *tty = fopen("/dev/tty", "w");
  char *pipename = argv[1];
  char str[SIZE_LIMIT];
  int fd = open(pipename, O_WRONLY);
  FILE *fp = fdopen(fd, "w");
  printf("a: start\n");
  for(int ind=0; ind<5; ind++) {
    sprintf(str, "%d ", ind);
    int ret = fputs(str, fp);
    /* fputs(str, stdout); */
    /* fprintf(tty, "%s", str); */
    printf("%s/ret=%d ", str, ret);
    fflush(stdout);
    /* fflush(tty); */
    sleep(500);
  }
  printf("finished\n");
  close(fd);
  /* struct pollfd fds[1]; */
  /* fds[0].fd = STDIN_FILENO; */
  /* fds[0].events = POLLIN; */
  /* int retval = poll(fds, 1, 2000); */
  /* printf("%d\n", retval); */

  /* printf("nani!?"); */
  /* fflush(stdout); */
  /* char *pipeName = argv[1]; */
  /* FILE *fp = fopen(pipeName, "r"); */
  /* char *read_pipe = getcFileString(fp); */
  /* printf("test:%s\n", read_pipe); */

  /* char str[10] = {-1}; */
  /* for(int ind=0; ind<10; ind++) str[ind] = (char) 66; */
  /* str[9] = '\0'; */
  /* str[0] = 10; */
  /* printf("str=%s\n", str); */
  /* pid_t fork_id = fork(); */
  /* if(fork_id == -1) { */
  /*   fprintf(stderr, "test.c: child process creation failure\n"); */
  /*   exit(1); */
  /* } */
  /* if(fork_id == 0) { */
  /*   FILE *fp = fopen(pipeName, "r"); */
  /*   fgets(str, 10, fp); */
  /*   for(int ind=0; ind<10; ind++) printf("str[%d]=%d\n", ind, (int) str[ind]); */
  /*   fclose(fp); */
  /*   exit(0); */
  /* } else { */
  /*   FILE *fpw = fopen(pipeName, "w"); */
  /*   fputs("", fpw); */
  /*   fclose(fpw); */
  /*   exit(0); */
  /* } */
}