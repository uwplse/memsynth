.PHONY: test all make-litmus test-litmus make-alglave test-alglave make-madorhaim test-madorhaim

test: test-litmus test-alglave test-madorhaim

all: litmus alglave madorhaim

make-litmus:
	raco make litmus/herd/compile.rkt
test-litmus: make-litmus
	raco test litmus/herd/compile.rkt

make-alglave:
	raco make frameworks/alglave/test/*test.rkt
	raco make frameworks/alglave/test/ppc/*test.rkt
	raco make frameworks/alglave/test/x86/*test.rkt
test-alglave: make-alglave
	raco test frameworks/alglave/test/*test.rkt
	raco test frameworks/alglave/test/ppc/*test.rkt
	raco test frameworks/alglave/test/x86/*test.rkt

make-madorhaim:
	raco make frameworks/madorhaim/test/*test.rkt
test-madorhaim: make-madorhaim
	raco test frameworks/madorhaim/test/*test.rkt
