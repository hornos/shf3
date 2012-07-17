.SUFFIXES: .c

include arch.make

# Fortran modules
C_SRC  = connect.c
C_OBJ  = $(C_SRC:.c=.o)
EXE = connect

all: $(EXE)

$(EXE): $(C_OBJ)
	$(CC) $(LDFLAGS) -o $(EXE) $(C_OBJ)

.c.o:
	$(CC) -c $(CFLAGS) $< -o $@

clean:
	rm -f *.o *.a connect
