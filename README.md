# odas_ros

This package is a ROS package for [ODAS](https://github.com/introlab/odas).

[IntRoLab - Université de Sherbrooke](https://introlab.3it.usherbrooke.ca)

[![ODAS Demonstration](https://img.youtube.com/vi/n7y2rLAnd5I/0.jpg)](https://youtu.be/n7y2rLAnd5I)

# Authors
* Marc-Antoine Maheux
* Cédric Godin
* Simon Michaud
* Samuel Faucher
* Olivier Roy
* Vincent Pelletier
* François Grondin

# License
[GPLv3](LICENSE)

## Prerequisites
You will need CMake, GCC and the following external libraries:
```
sudo apt-get install cmake gcc build-essential libfftw3-dev libconfig-dev libasound2-dev
```

ODAS ROS uses the audio utilities from [AudioUtils](https://github.com/introlab/audio_utils) so it should be installed in your catkin workspace. If it is not already, here is how to do so:

Clone AudioUtils in your catkin workspace:
```
git clone https://github.com/introlab/audio_utils.git
```
Install dependencies:
```
sudo apt-get install gfortran texinfo
sudo pip install libconf
```

In the cloned directory of `audio_utils`, run this line to install all submodules:
```
git submodule update --init --recursive
```

If you get errors when building with `catkin_make`, you can modify the cmake file of audio_utils to add C++ 14 compiler option.
```
add_compile_options(-std=c++14)
```

## Installation
First, you need to clone the repository in your catkin workspace.
```
git clone https://github.com/XYZT-Autonomous-Vehicle/odas_ros
```
In the cloned directory of `odas_ros`, run this line to install all submodules:
```
git submodule update --init --recursive
```

If this does not install the correct submodules, you can hard install the orginal ODAS library into your catkin workspace:
- Navigate to the main ODAS (non-ROS version) library (https://github.com/introlab/odas/tree/2ed307ba22403f96260d8741cbb568a87cf647a0) 
- Download ZIP files 
- Unzip folders to your catkin workspace (inside odas_ros/src)

## Hardware configuration
For ODAS to locate and track sound sources, it needs to be configured. There is a file (`configuration.cfg`) that is used to provide ODAS with all the information it needs. 

For the Microsoft Azure Kinect DK Sensor, use the file ('azure_local.cfg'). For remote users, use ('azure.cfg').

To use rviz for visualization, please set odas.launch rviz argument to 'true'

<arg name="rviz" default="true"/> 


Here are the important steps:

To know what is your card number, plug it in your computer and run `arecord -l` in a terminal. The output should look something like this:
```
**** List of CAPTURE Hardware Devices ****
card 0: PCH [HDA Intel PCH], device 0: ALC294 Analog [ALC294 Analog]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
card 1: 8_sounds_usb [16SoundsUSB Audio 2.0], device 0: USB Audio [USB Audio]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```
In this case, the card number is 1 and the device is 0 for the 16SoundsUSB audio card. So the device name should be: `"hw:CARD=1,DEV=0";`.

At this part of the configuration file, you need to set the correct card and device number.
```
# Input with raw signal from microphones
    interface: {    #"arecord -l" OR "aplay --list-devices" to see the devices
        type = "soundcard_name";
        devicename = "hw:CARD=1,DEV=0";
```

### Sound Source Localization, Tracking and Separation
ODAS can output the sound source localization, the source source tracking and the sound source separation:
* Sound Source Localization: All the potential sound sources in the unit sphere. Each sound source position on the unit sphere and its energy.
* Sound Source Tracking: The most probable location of the sound source is provided (xyz position on the unit sphere).
* Sound Source Separation: An Audio Frame of the isolated sound source is provided.

Depending on what type of information will be used, the configuration file needs to be modified. For example, if I need only the Sound Source Tracking, the configuration file should be modified. The only thing that should be changed is the format and interface for each type of data. The required format if it is enabled is `json` and the interface type should be `socket`. If it is disabled, the format can be set to `undefined` and the interface type to `blackhole`.

For example, if the only data that will be used is the sound source tracking:
* In the `# Sound Source Localization` section, this should be modified to look like this:
```
potential: {

        #format = "json";

        #interface: {
        #    type = "socket";
        #    ip = "127.0.0.1";
        #    port = 9002;
        #};

        format = "undefined";

        interface: {
           type = "blackhole";
        };
```

* In the `# Sound Source Tracking` section, this should be modified to look like this:
```
# Output to export tracked sources
    tracked: {

        format = "json";

        interface: {
            type = "socket";
            ip = "127.0.0.1";
            port = 9000;
        };
    };
```

* In the `# Sound Source Separation` section, this should be modified to look like this:
```
separated: { #packaging and destination of the separated files

        fS = 44100;
        hopSize = 256;
        nBits = 16;

        interface: {
           type = "blackhole";
        };

        #interface: {
        #    type = "socket";
        #    ip = "127.0.0.1";
        #    port = 9001;
        #}        
    };
 ```
 
 Note that if an interface type is set to "blackhole" and the format to "undefined", the associated topic won't be published.
 
 The current configuration file ('azure.cfg') establishing at connection with the pocketsphinx node through a socket to receive the audio data. It then takes the data from SSL, SST, and SSS and streams it via socket to ODAS Web (https://github.com/introlab/odas_web)
 
 ### Launching
 First make sure the pocketsphinx node is running 
```
roslaunch odas_ros odas.launch 
```
