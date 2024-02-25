# ppaste

<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/pankunull/ppaste/main/docs/screenshot.png">
<img alt="ppaste screenshot" src="https://raw.githubusercontent.com/pankunull/ppaste/main/docs/screenshot.png">
</picture>

## Description
ppaste is a POSIX bash script that paste files at oetec.com/pastebin via shell.


## Installation
- clone the git repository
- cd into 'src'
- run the script

Or alternatively you can copy/link it anywhere in the system.


## Usage

To display the help page: 

```
./ppaste.sh --help
```


To just paste a file: 

```
./ppaste.sh file1
```


You can save the current session and set the expire date: 

```
./ppaste.sh --save-session --expire-time 7 file1 file2
```
The history is saved in `"$HOME"/ppaste/history`

The server generates 3 links: **editor**, **plain** and **lined**.

You can choose which links to display, for example to show only **plain** links: 

```
./ppaste.sh --output-format plain file1
```

For example, if you need to upload multiples files and grab all the plain links: 

```
./ppaste.sh  --output-format plain
```


To display the history of the links that are still alive:

```
./ppaste.sh --history alive
```


You can download multiple paste from the server using the hash or the link: 

```
./ppaste.sh --download bG5tgrF6 https://www.oetec.com/pastebin/plain/5tGy6HjU
```


To download all the links that are still alive: 

```
./ppaste.sh --download-alive
```


NOTE: The script checks for duplicates when downloading.


## Credits
Pastebin: o1
2nd mirror: blastwave
Coding: deesix
