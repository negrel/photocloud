# 🖼️ `photocloud`- A modular cloud photos.

## Utilis scripts

### `exif_fix.sh`

A simple bash scripts based on `exiftool` that adds date exif metadata (if missing) to files based
on their location. For example, it will add `2022:09:01 00:00:00` date to any file under `path/to/a/dir/2022/09` directory.

#### Usage

```shell
# A maximum of 1024 parallel jobs
MAX_JOBS=1024 ./exif_fix.sh /path/to/directory1 /path/to/directory2 ...
```

## Contributing

If you want to contribute to `photosort` to add a feature or improve the code contact
me at [negrel.dev@protonmail.com](mailto:negrel.dev@protonmail.com), open an
[issue](https://github.com/negrel/photosort/issues) or make a
[pull request](https://github.com/negrel/photosort/pulls).

## :stars: Show your support

Please give a :star: if this project helped you!

[![buy me a coffee](.github/bmc-button.png)](https://www.buymeacoffee.com/negrel)

## :scroll: License

MIT © [Alexandre Negrel](https://www.negrel.dev/)

