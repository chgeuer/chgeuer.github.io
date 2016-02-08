@echo off
chcp 65001


REM call jekyll build
REM call jekyll serve --watch --trace
REM call C:\Ruby22\bin\bundle.bat exec jekyll serve --watch
REM call C:\tools\ruby22\bin\jekyll.bat serve --watch

call jekyll.bat serve --watch
