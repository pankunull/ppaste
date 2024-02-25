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

---

### Display format
The server generates 3 links:
+ editor: edit the paste from the website
+ plain: direct link to the file
+ lined: display line numbers

If you want to display all links when all files are uploaded you can use `--output-format` or short `-o`.

```
./ppaste.sh --output-format plain file1 file2
```

```
Sending: /tmp/foobar.txt
######################################################## 100.0%
   Created on : Sun Feb 25 23:26:32 CET 2024
   Expires on : Mon Feb 26 03:19:52 CET 2024
     Lifetime : 4 hours
         Hash : bvt2aALW
 Save session : false
       Editor : https://www.oetec.com/pastebin/bvt2aALW
        Lined : https://www.oetec.com/pastebin/lined/bvt2aALW
        Plain : https://www.oetec.com/pastebin/plain/bvt2aALW

Sending: /tmp/foobar.txt
######################################################## 100.0%
   Created on : Sun Feb 25 23:26:32 CET 2024
   Expires on : Mon Feb 26 03:19:52 CET 2024
     Lifetime : 4 hours
         Hash : bvt2a33j
 Save session : false
       Editor : https://www.oetec.com/pastebin/bvt2a33j
        Lined : https://www.oetec.com/pastebin/lined/bvt2a33j
        Plain : https://www.oetec.com/pastebin/plain/bvt2a33j


Output format: plain

https://www.oetec.com/pastebin/plain/bvt2aALW
https://www.oetec.com/pastebin/plain/bvt2a33j
```

---

### History
The history is saved in `"$HOME"/ppaste/history`

To display the history of the links that are still alive:

```
./ppaste.sh --history alive
```

You can display more information for each paste using:

```
./ppaste.sh --history-table alive
```

---

### Download
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
