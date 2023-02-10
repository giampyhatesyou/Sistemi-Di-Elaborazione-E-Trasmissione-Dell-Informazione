#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>
#include <string.h>


int main(){
    int pp;
    if (pp = fork() < 0){
        return -1;
    }
    if(pp == 0){
        int x = execlp("ls", "ls", "-l", NULL);
        return -1; //non dovrei arrivare fino a qui   
    }
    else{
        int status;
        wait(&status);
        if(WIFEXITED(status)){
            printf("Il figlio ha terminato con codice %d" , WEXITSTATUS(status));
        }
    }
    return 0;
}