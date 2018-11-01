@echo off
copy ..\documents\z80oplist.txt .
python makeasm.py
copy z80asm.py ..\system

