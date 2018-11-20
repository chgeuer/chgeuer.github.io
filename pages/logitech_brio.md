
# Install Logitech BRIO web cam

source: https://community.logitech.com/s/question/0D53100006cmKMjCAM/logitech-brio-issue

Every single time my Windows build updates, the camera is broken, and none of Logitech's support steps works to fix it (when I tried tech support they actually asked me to send the camera back even though nothing was wrong with it.)

What does work: 

- Device Manager
- pick the Brio under Imaging Devices
- Update Driver
- Browse my computer for driver software
- Let me pick from a list of available drivers
- Switch the driver to "USB Video Device" and okay it.  
- After it installs that driver, repeat the process, switching the driver back to "Logitech BRIO"

, and everything will work.

For some reason the Logitech apps still complain I'm not using the Logitech driver after that, even though the driver shows as Logitech 1.0.53.7, but everything works, including motion detection, Windows Hello, background removal, etc.
