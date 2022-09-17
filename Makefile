CC       := aarch64-linux-gnu-gcc
AS       := aarch64-linux-gnu-as
LD       := aarch64-linux-gnu-ld
CUR_PATH := $(shell pwd)
BASENAME := $(shell basename $(CUR_PATH))
EXE      := $(BASENAME).out

.PHONY: default
default: build

.PHONY: build
build: *.s
	$(CC) -g -static -o $(EXE) $^ -lm

.PHONY: run
run: $(EXE)
	@qemu-aarch64 $(EXE) out.txt < input.txt


.PHONY: clean
clean:
	-rm *.out *.o &> /dev/null || true

TMP := $(CUR_PATH)/.gdb-config

.PHONY: debug
debug: $(EXE)
	@printf "set architecture aarch64\n\
	file $(EXE)\n\
	target remote localhost:31337\n" > $(TMP)
	@cat ../gdbconfig >> $(TMP) || true
	qemu-aarch64 -g 31337 $(EXE) out.txt < input.txt
	@#tmux new-session -d 'qemu-aarch64 -g 31337 $(EXE)'
	@#tmux split-window -h 'gdb-multiarch -q -x $(TMP)'
	@#-tmux -2 attach-session -d
	-rm $(TMP) && pkill -9 qemu

.PHONY: gdb
gdb: $(TMP)
	gdb-multiarch -q -x $(TMP)
