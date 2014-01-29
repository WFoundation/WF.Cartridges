WF.Cartridges
=============

Repository for test cartridges, which can be used to test different Wherigo players

Here we collect cartridges, used for testing the different Wherigo players and their features. Each cartridge should test a different part of the library.

TaskTest
--------

With this cartridge ZTask could be tested. You could change all attributes of a task. Additionally, there is the possibility to show an extra task, because some players have problems to display only one task.

Thanks to Jonny65 for providing this cartridge.

TimerTest
---------

With this cartridge ZTimer could be tested. There are three items, each controlling one timer. Each timer behaves a little bit different. The first plays an audio file in the OnStart event, the second plays the audio file in the OnTick, but is an intervall timer and the third plays it in OnTick, but is a countdown timer. All three timers play another audio file in OnEnd, when they are stopped.

Thanks to Jonny65 for providing this cartridge.