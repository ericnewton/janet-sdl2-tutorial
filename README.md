
[comment]: # -*- mode: markdown-mode -*-
# Call SDL2 library code using Janet, with examples.

# Why

(Tutorial examples from https://thenumb.at/cpp-course/index.html)

I began writing some SDL2 code using some hand-rolled FFI bindings to
[Janet](https://janet-lang.org/). I don't know SDL2, so I started with
the tutorial at `thenumb.at`, converting the examples into Janet and
expanding the FFI bindings as necessary.

The examples intend to stay true to the original C++ and should be
easy enough to follow along between the two. Forgive me if there are
any blatent errors as I'm new to both Janet and SDL2.

The result is far from idiomatic Janet code. The goal was to stay very
close to the C++ examples so you can follow the excellent tutorial and
match against the equivalent Janet code.

See also [the original C++
repository](https://github.com/TheNumbat/cpp-course).


## pausing

Note that the pause call in the examples:

```
system("pause");
```

Isn't portable to all platforms. Even if a suitable `pause` command
existed, some platforms require a run through the event loop to show
any newly created windows. A replacement pause mechanism is provided
that enters the event loop until the SDL_QUIT event occurs.

# Screenshot

```
$ janet 08.janet
```

![](screenshot.mp4)
