---
title: "Batch script to open most recent file"
date: 2009-04-28T21:51:10-04:00
tags:
    - batch
    - hacks
---
I receive an issues list 2 to 5 times per week from one of my clients. For a while I was deleting the previous version, saving the new one, and renaming it. This way, the list was always up to date. That was a pain. Then I started dumping the files into one folder, and worrying about which was the correct one whenever I actually had to open it. That was better when saving the file, but worse when opening it. Then I sorted the folder by date modified, and it worked, but I never trust Windows explorer to work as anticipated, so I double-checked it every time.

Today, I decided to take the guess work out of the process. I created a batch script to scan the ‘issues list’ directory for Excel (.xls) files, and open the most recent one. Thanks to Google, and http://www.ericphelps.com/batch/samples/recent.txt, I knocked it out in about 5 minutes.

Here is the code (almost all of which was taken from erichelps.com):

```batch
@echo off
for /f "delims=" %%x in ('dir /od /a-d /b *.xls') do
set recent=%%x
start "" "C:\Program Files\Microsoft Office\Office12\excel.exe"
"%recent%"
```

Essentially what this is doing, is dumping all of the output of a directory listing (sorted by modified date) into an array and assigning as it runs through the array, assigning the variable to the array element over and over again. This means that when the loop runs out of array elements, the variable is the filename of the most recently modified file.

The start command prevents the batch window from remaining open the entire time that the spreadsheet is open.

Now, instead of opening the directory and digging for the most recent copy, I just run the batch file from a shortcut in the quick launch bar, and it opens the most recent .xls file on its own.
