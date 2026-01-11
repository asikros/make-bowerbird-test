# Test file with targets that have dependencies

test-with-deps: dep1 dep2
	@:

test-with-order-only: | order-dep
	@:

test-with-pattern-dep: pattern-dep.o
	@:

pattern-dep.o:
	@:

dep1:
	@:

dep2:
	@:

order-dep:
	@:
