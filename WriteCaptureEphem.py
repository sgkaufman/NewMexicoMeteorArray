import datetime
import ephem
import argparse

##########################################

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="""Ephemeris testing program. Arguments are --latitude (decimal degrees), --longitude (decimal degrees), --elevation, (meters), and horizon below/above which sunset/sunrise times are returned.""")
    parser.add_argument('--latitude', type=float, \
                        help='latitude of ephemeris observer, decimal', \
                        default=35.147217)
    parser.add_argument('--longitude', type=float, \
                        help='longitude of ephemeris observer, decimal, West negative', \
                        default = -106.505583 )
    parser.add_argument('--elevation', type=float,
                        help='elevation of ephemeris observer, meters, EGM96 geoidal datum, not WGS84 ellipsoidal', \
                        default = 1826.389 )
    parser.add_argument('--horizon', type=float, \
                        help='degress above or below horizon of Sun, with sign',
                        default=0.0)
    args=parser.parse_args()

    horizon = args.horizon
    lat = args.latitude
    long = args.longitude
    elev = args.elevation

    o = ephem.Observer()
    o.lat = str(lat)
    o.long = str(long)
    o.elevation = elev
    o.horizon = str(horizon)

    s=ephem.Sun()
    s.compute()

    next_rise = o.next_rising(s).datetime()
    next_set = o.next_setting(s).datetime()
    prev_rise=o.previous_rising(s).datetime()
    prev_set=o.previous_setting(s).datetime()

    now = datetime.datetime.utcnow()

    print('As of {},'.format(str(now)) )
    print('    latitude  =  {},'.format(lat) )
    print('    longitude =  {},'.format(long) )
    print('    elevation =  {},'.format(elev) )
    print('    horizon   =  {}'.format(horizon) )

    print('next sunrise and sunset times are: ')
    
    print('    sunset:  {}'.format(str(next_set)) )
    print('    sunrise: {}'.format(str(next_rise)) )

    print('Previous sunrise and sunset times are: ')
    print('    sunset:  {}'.format(str(prev_set)) )
    print('    sunrise: {}'.format(str(prev_rise)) )

