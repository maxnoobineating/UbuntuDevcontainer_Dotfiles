#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fileString.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <poll.h>
#include <vector.h>
#define DEFAULT_LINESIZE 1024
#define BUFFER_SIZE_LIMIT 4
/* #define STEP_ECHO(n) fprintf(tty_fp, "relay %d: read = '%s', write = '%s'\n", (n), pipe_read, pipe_write); fflush(tty_fp); */
#define STEP_ECHO(n) fprintf(tty_fp, "relay %d\n", (n)); fflush(tty_fp);


int main(int argc, char* argv[]) {
  /* char* line = malloc(default_linsSize); */
  if(argc != 3) {
    fprintf(stderr, "arguments number error\n");
    exit(1);
  }
  char *p2relay_pipe = argv[1]
    , *relay2p_pipe = argv[2];
  FILE *tty_fp = fopen("/dev/tty", "w");
  /* char line[DEFAULT_LINESIZE] = {0}; */
  /* char *pipe_read = malloc(sizeof(char) * DEFAULT_LINESIZE), *pipe_write = malloc(sizeof(char) * DEFAULT_LINESIZE); */
  STEP_ECHO(1);
  int p2r_fd = open(p2relay_pipe, O_RDONLY);
  STEP_ECHO(2);
  /* fcntl(STDOUT_FILENO, F_SETFL, fcntl(STDOUT_FILENO, F_GETFL)); */
  int r2p_fd = open(relay2p_pipe, O_WRONLY);
  /* fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL)); */
  const int connection_counts = 4;
  const int timeout_ms = 1000;
  /* const int poll_timeout_ms = 50; */
  struct pollfd fds[connection_counts];
  fds[0].fd = p2r_fd;
  fds[0].events = POLLIN;
  fds[1].fd = STDOUT_FILENO;
  fds[1].events = POLLOUT;
  fds[2].fd = r2p_fd;
  fds[2].events = POLLIN;
  fds[3].fd = STDIN_FILENO;
  fds[3].events = POLLOUT;
  FILE *p2r_fp = fdopen(p2r_fd, "r")
    , *r2p_fp = fdopen(r2p_fd, "w");
  /* int queueNr = 0; // to reduce unnecessary checking if things went too */
  /* while((queueNr = poll(fds, connection_counts, timeout_ms)) > 0) { */
  Vector *p2s_vec = vectorCreate(sizeof(char *)),
    *s2p_vec = vectorCreate(sizeof(char *));
  for(int ind=0; ind < 4; ind++) {
    STEP_ECHO(3);
    int ret = poll(fds, connection_counts, timeout_ms);
    fprintf(tty_fp, "# poll: %d\n", ret);
    if(ret == -1) {
      fprintf(tty_fp, "poll failed\n");
      break;
    } else if(ret == 0) {
      fprintf(tty_fp, "timeout expired\n");
      break;
    }
    if(fds[0].revents & POLLIN) {
      STEP_ECHO(4);
      // process to relay
      char *p2s_msg = getdelimFileString(p2r_fp, '\n');
      vectorAdd(p2s_vec, &p2s_msg);
      if (vectorLen(p2s_vec) >= BUFFER_SIZE_LIMIT) {
        fprintf(tty_fp, "relay buffer p2s overflow");
        exit(1);
      }
    }
    if(!vectorIsEmpty(p2s_vec) && (fds[1].revents & POLLOUT)) {
      // relay to server
      char *p2s_msg;
      vectorGet(p2s_vec, &p2s_msg, vectorLen(p2s_vec) - 1);
      vectorPop(p2s_vec);
      STEP_ECHO(5);
      fputs(p2s_msg, r2p_fp);
      fflush(r2p_fp);
      if(p2s_msg[strlen(p2s_msg) - 1] != '\n') fputc('\n', r2p_fp);
      free(p2s_msg);
    }
    if(fds[2].revents & POLLIN) {
      // server to relay
      STEP_ECHO(6);
      char *s2p_msg = getdelimFileString(stdin, '\n');
      vectorAdd(s2p_vec, &s2p_msg);
      if (vectorLen(s2p_vec) >= BUFFER_SIZE_LIMIT) {
        fprintf(tty_fp, "relay buffer s2p overflow");
        exit(1);
      }
    }
    if(!vectorIsEmpty(s2p_vec) && (fds[3].revents & POLLOUT)) {
      // relay to process
      char *s2p_msg;
      vectorGet(s2p_vec, &s2p_msg, vectorLen(s2p_vec));
      vectorPop(s2p_vec);
      STEP_ECHO(7);
      fputs(s2p_msg, stdin);
      fflush(r2p_fp);
      if(s2p_msg[strlen(s2p_msg) - 1] != '\n') fputc('\n', r2p_fp);
      free(s2p_msg);
    }
    STEP_ECHO(8);
    usleep(500000);
  }
  exit(0);
}