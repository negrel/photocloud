# 🖼️ `photocloud`- A modular cloud photos.

A modular cloud photos made of the following components:
- [`syncthing`](https://syncthing.net/): a continuous file synchronization program.
- [`photosort`](https://github.com/negrel/photosort): a pictures/files organizer.
- [`photoview`](https://photoview.github.io/): a photo gallery server sync with your filesystem.

Each component is optional and can be replaced depending of your need. For
example, you could replace `photoview` with an FTP server (or deploy it along).

This as the following advantages:
- each component does one task but does it very well
- you're not tied to any software

and the following drawbacks:
- Components can't communicate
	- see [Why is there a cron service ?](#why-is-there-a-cron-service-)
- Two source of truth
	- files under `synced/` (files synchronized by `syncthing`) and `sorted/` (files sorted by `photosort`)

## Big picture

Before getting started, you must know a little bit of how `photocloud` works so
you don't mess with your pictures.

Services are designed as follow:
- `syncthing`: synchronize files and store them under `photos/synced/`
- `photosort`: sort files using **hardlink** from `photos/synced` to `photos/sorted`
- `photoview`: Web app gallery showing pictures under `photos/sorted`

But because components can't communicate, there is an extra service: `cron`.

## Why is there a cron service ?

The `cron` service is responsible of *cleaning* sorted photos.

At the time of writing, it is responsible of:
- removing replicated files whose source has been deleted by `syncthing`
- adding date exif metadata to images that do not have it (see [`exif_fix.sh` utils scripts](#exif_fixsh))

Without periodic scans (cron jobs), files removed by `syncthing` in `synced/` can't be removed of the `sorted/` directory.
This is because `photosort` can't communicate with `syncthing` and **needs** the
content of removed file under `synced/` to determine it's location under `sorted/`.

This may be a hacky solution but it has one advantage: files aren't deleted immediately and
you may recover them from the `sorted/` directory.

### When `cron` service remove file ?

During periodic scan, cron remove files if they meet one of the following conditions:
- link count is 0, that is a file has no hardlink
- a symbolic link point to inexistent file.

## Utils scripts

### `exif_fix.sh`

A simple bash scripts based on `exiftool` that adds missing date exif metadata.
Date is determined based on parent directories.
For example, it will add `2022:09:01 00:00:00` date to any file under `path/to/a/dir/2022/09` directory.
It can only determine year and month currently.

#### Usage

```shell
# Recursively fix every files under /path/to/directory1 and /path/to/directory2
# A maximum of 1024 parallel jobs
MAX_JOBS=1024 ./exif_fix.sh /path/to/directory1 /path/to/directory2
```

### `list_removed.sh`

Recursively list files that can be deleted from `photos/sorted` directory.
A files can be deleted if:
- file is a symbolic link that points to no file.
- file is a regular file with a link count of 0 (no hardlink).

This scripts should be run only under `photos/sorted` directory.
It should not be used on files replicated using `copy` replicator (it will list all files).

#### Usage

```shell
# List every sorted photos that should be removed in ./photos/sorted/
# A maximum of 1024 parallel jobs
MAX_JOBS=1024 ./list_removed.sh ./photos/sorted/

# Delete replicated files whose original has been deleted
# NOTE: USE WITH CAUTION
# NOTE: The script won't list any file under a .*sync.* directory by default
./list_removed.sh ./photos/sorted | xargs rm -f
```

This scripts is used by the `cron` service to delete sorted files whose original
has been removed.

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

