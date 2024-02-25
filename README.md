# ppaste

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

The history is saved in `"$HOME"/ppaste/history`

After the file is sent the server will generate 3 links: editor, plain and lined.

You can choose which links to display at the end using: 

```
--output-format FORMAT
```

For example, if you need to upload multiples files and grab all the plain links: 

```
./ppaste.sh  --output-format plain
```

You can save the current session and set the expire date: 

```
./ppaste.sh --save-session --expire-time 7 file1 file2
```

To display the history of all the links that are still alive: 

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
