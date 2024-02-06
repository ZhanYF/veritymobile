

## Common problems and FAQ

### Error: reference is not a tree: 0747a16893c403fa9937963b2379cd07c0709d8b

```
cd external/MSRSec/external/wolfssl/ && \
	git checkout 0747a16893c403fa9937963b2379cd07c0709d8b
fatal: reference is not a tree: 0747a16893c403fa9937963b2379cd07c0709d8b
make: *** [Makefile:103: ftpm] Error 128
```

Check if git submodules are initialized properly, a corrupted submodule might not be obvious, re-run `make init` when in doubt.
