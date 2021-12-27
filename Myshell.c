#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
bool bg;
pid_t rPid;
int cdfunction(char** args) {
        if(args[1]==NULL) {
                return 0;
        }
        else {
        chdir(args[1]);
        }
        return 1;
}
int exitfunction() {
        return 0;
}
#define escape_char " \t\r\n\a"
char** subtractArgs(char *line) {
        int counter=0;
        char** arguments = malloc(sizeof(char*));
        arguments[counter] = strtok(line,escape_char);
        while(arguments[counter]!=NULL) {
                counter++;
                arguments = (char**)realloc(arguments,(counter+1)*sizeof(char*));
                arguments[counter]=strtok(NULL,escape_char);
        }
        if(!strcmp(arguments[counter-1],"&")) {
                arguments[counter-1]=NULL;
                        bg=1;

        }else {
                bg=0;
        }
        return arguments;
}
int newProcess(char** args) {
        pid_t pid, wpid;
        int status;
        pid = fork();
        if(pid==0){
                signal(SIGINT, SIG_DFL);
                execvp(args[0],args);
        }else {
                do {
                        if(!bg) {
                        wpid = waitpid(pid, &status, WUNTRACED);
                        } else {
                                signal(SIGCHLD,SIG_IGN);
                        }
                }
                while (!WIFEXITED(status) && !WIFSIGNALED(status) && !bg);
        }
        return 1;

}
int execute(char** args) {
        char* builtins[2];
        builtins[0]="cd";
        builtins[1]="exit";
        if(!strcmp(args[0],builtins[0])) {
                return cdfunction(args);
        }
        if(!strcmp(args[0],builtins[1])) {
                return exitfunction();
        }
        return newProcess(args);


}
char* readLine() {
        size_t linesize = 0;
        //Sam String line, jest w zasadzie po to, że funckja getline()
        //może nam zwrócić -1
        char *line = NULL;
        if(getline(&line,&linesize,stdin)==-1) {
        if(feof(stdin)) {
                 exit(EXIT_SUCCESS);  // We recieved an EOF
        }else {
                perror("readline");
                exit(EXIT_FAILURE);
        }
        }
        return line;
}

void run(){
        int status=1;
        char path[1000];
        while(status) {
        char** args;
        getcwd(path,1000);
        printf("\033[0;34m%s\033[0m>",path);
        char* line;
        line = readLine();
        if(strcmp(line,"\n")){
        args = subtractArgs(line);
        status=(execute(args));
        free(line);
        free(args);}
        }
}

void sigInt_handler() {
        signal(SIGINT,sigInt_handler);
}
int main() {
        signal(SIGINT,sigInt_handler);
        while(1) {
        run();
        }
        return 0;

}
