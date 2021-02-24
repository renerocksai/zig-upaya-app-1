# zig-upaya-app-1

My first steps creating an imgui app in zig.

It uses the default and a custom font, and scrollbars to verify that window resizes work.

![image](https://user-images.githubusercontent.com/30892199/109077312-351f1e00-76fc-11eb-9f5b-2a61160ef2a7.png)

The screenshot was taken on my Chromebook, a 2015 Google Pixelbook, running Ubuntu 20.04 under ChromeOS.


# prerequisites

Clone [zig-upaya](https://github.com/prime31/zig-upaya).

Tested with: 
- zig `0.8.0-dev.1120+300ebbd56`
- zig `0.8.0-dev.1141+68e772647`
- zig-upaya [prime31/zig-upaya@154417379bfaa36f51c3b1b438fa73cf563d90f0](https://github.com/prime31/zig-upaya/commit/154417379bfaa36f51c3b1b438fa73cf563d90f0).

# build and run

```bash
$ zig build run
```

To just build: `zig build`. This will create the executable `rene` in `./zig-cache/bin/`.

