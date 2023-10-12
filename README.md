# vision-only-drones

The code used in the experiment of "A Vision-Only Drone Formation Waypoint Navigation Method" is as follows:

- The code for obtaining training data using AirSim is located in the `airsim script` folder.
- `directwalk_demo.m` contains the code for waypoint navigation and formation keeping during flight.
- `replay.m` is used to generate smoothed waypoints for the flight path.

before running `directwalk_demo.m`,you should use following command to import the map image

```matlab
img = imread("xxx.png");
```

Formation and waypoint settings can be adjusted in `directwalk_demo.m`.
