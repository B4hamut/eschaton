# eschaton

needs :
- winim
- puppy

compilation :

```
nim c -d:mingw --cpu:amd64 -d:strip -d:danger --opt:size --passc=-flto --passl=-flto eschaton.nim
```

how to use :

- add procexp.sys in C:\WINDOWS\System32\drivers

- run eschaton.exe --pid:[PID of your target process]

- profit ????
