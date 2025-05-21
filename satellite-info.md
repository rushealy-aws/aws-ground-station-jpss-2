# JPSS-2 (NOAA-21) Satellite Information

## Satellite Overview

JPSS-2 (Joint Polar Satellite System-2), also known as NOAA-21, is a polar-orbiting environmental satellite operated by the National Oceanic and Atmospheric Administration (NOAA) in partnership with NASA. It was launched on November 10, 2022, and is the second satellite in the JPSS series.

## Orbital Parameters

- **Orbit Type**: Sun-synchronous, polar orbit
- **Altitude**: Approximately 824 km (512 miles)
- **Inclination**: 98.7 degrees
- **Period**: ~101 minutes
- **Equator Crossing Time**: ~13:30 local time (ascending node)

## Downlink Information

- **Frequency Band**: X-band
- **Downlink Frequency**: 7812 MHz (center frequency)
- **Bandwidth**: 40 MHz
- **Polarization**: Right-hand circular polarization (RHCP)
- **Data Rate**: Up to 15 Mbps

## Instruments

JPSS-2 carries five primary instruments:

1. **Advanced Technology Microwave Sounder (ATMS)**: Provides atmospheric temperature and moisture profiles
2. **Cross-track Infrared Sounder (CrIS)**: Measures atmospheric temperature, pressure, and moisture profiles
3. **Visible Infrared Imaging Radiometer Suite (VIIRS)**: Collects visible and infrared imagery and radiometric data
4. **Ozone Mapping and Profiler Suite (OMPS)**: Measures ozone concentration in the atmosphere
5. **Clouds and the Earth's Radiant Energy System (CERES)**: Measures reflected solar and Earth-emitted thermal radiation

## Data Products

The data collected by JPSS-2 is used for:

- Weather forecasting
- Climate monitoring
- Environmental monitoring
- Disaster response
- Air quality assessment
- Sea surface temperature measurements
- Ocean color observations
- Vegetation and drought monitoring
- Fire detection

## AWS Ground Station Configuration Notes

When configuring AWS Ground Station for JPSS-2:

- Ensure the satellite is whitelisted for your AWS account
- Configure the downlink to match the satellite's X-band frequency (7812 MHz)
- Set appropriate bandwidth (40 MHz) and polarization (RHCP)
- Consider the satellite's orbital parameters when scheduling contacts
- Typical contact duration is 5-15 minutes depending on the ground station location

## Additional Resources

- [NOAA JPSS Website](https://www.nesdis.noaa.gov/current-satellite-missions/currently-flying/joint-polar-satellite-system)
- [NASA JPSS Website](https://www.nasa.gov/mission_pages/jpss/main/index.html)
- [AWS Ground Station Documentation](https://docs.aws.amazon.com/ground-station/)
