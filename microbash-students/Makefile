CFLAGS=-ggdb -Og -fno-omit-frame-pointer -Wall -pedantic -Werror -std=gnu11 -fsanitize=address -D_GNU_SOURCE

all: microbash

microbash: microbash.o
	$(CC) $(CFLAGS) -o $@ $^ -lreadline

clean:
	rm -f microbash microbash.o

tgz: clean
	cd .. && tar cvzf microbash-students.tgz microbash-students

.PHONY: clean tgz


