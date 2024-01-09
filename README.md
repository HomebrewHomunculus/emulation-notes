# emulation-notes

Notes and useful resources on developing emulators, TAS, etc.

## NES


### Tetris

Emulator options include:

* [Mesen2](https://github.com/SourMesen/Mesen2)
    - C++17 backend
    - Clang or GCC
    - C# + SDL2 + .NET frontend
    - An earlier Mesen fork, [Mesen-x](https://github.com/NovaSquirrel/Mesen-X), is inactive since 2023.
* [BizHawk](https://github.com/TASEmulators/BizHawk)
    - multi-system emulator
    - C++ backend (C for some emulators)
    - C# + SDL2 + .NET frontend
* [fceux](https://github.com/TASEmulators/fceux)
    - C
    - cmake
    - SDL2 + Qt5/QT6
    - has a TAS editor starting on 2.6.0, as well as LUA scripting
    - DO NOT USE fceux if your aim is Tetris accuracy and chasing/avoiding a crash! It has an inaccuracy (per /u/Le_Martian)
      which avoids certain crashes that do happen on real hardware (and likewise on Mesen2 and BizHawk).

Videos and other resources:

- [HydrantDude's video: why the colors glitch out at level 138 - YouTube](https://www.youtube.com/watch?v=2Lp2yA2wYKI)
- [HydrantDide's video: why clearing a single at level 155 crashes nes tetris - YouTube](https://www.youtube.com/watch?v=BpEcjdr_YDo)
- [HydrantDude's "Crash Theory" spreadsheet - Google Sheets](https://docs.google.com/spreadsheets/d/1zAQIo_mnkk0c9e4-hpeDvVxrl9r_HvLSx8V4h4ttmrs)
- [aGameScout's video: AFter 34 Years, Someone Finally Beat Tetris - YouTube](https://www.youtube.com/watch?v=GuJ5UuknsHU)
- [Greg Cannon's video on StackRabbit getting to level 237 (note: on a MODIFIED ROM)](https://www.youtube.com/watch?v=l_KY_EwZEVA)

Technical information - RAM maps etc.:
- [ROM Detectives wiki - RAM ](http://www.romdetectives.com/Wiki/index.php?title=Tetris_(NES)_-_RAM)
- [Data Crystal - RAM map](https://datacrystal.romhacking.net/wiki/Tetris_(NES):RAM_map)
- [Data Crystal - ROM map](https://datacrystal.romhacking.net/wiki/Tetris_(NES):ROM_map)
- [Data Crystal - Known Dumps](https://datacrystal.romhacking.net/wiki/Tetris_(NES)#Known_Dumps)


<!-- # -->

