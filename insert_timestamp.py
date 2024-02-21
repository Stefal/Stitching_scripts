#!/usr/bin/env python
# -*- coding: utf-8 -*-

#script to insert timestamp in exif from filename
# ac_1592390950475.jpg -> Wednesday 17 June 2020 10:49:10.475
import argparse
import datetime
import os
import sys
import time
import logging
from builtins import input
from collections import namedtuple

from dateutil.tz import tzlocal
from lib.exif_read import ExifRead as EXIF
from lib.exif_write import ExifEdit

Picture_infos = namedtuple('Picture_infos',
                               ['path', 'DateTimeOriginal', 'SubSecTimeOriginal', "Longitude", "Latitude", "Ele", "ImgDirection", "New_DateTimeOriginal"])

def arg_parse():
    parser = argparse.ArgumentParser(
        description=" - Search for distance based duplicate images and move them in a 'duplicate' subfolder.\n - Search for image in geofence zones and move them in a 'geofence' subfolder\n - Search for images with a too large angle between them.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "paths",
        nargs="+",
        help="paths to the images folders",
    )
    parser.add_argument(
        "-r",
        "--recursive",
        help="search images in subdirectory",
        action="store_true",
        default=False,
    )
    parser.add_argument(
        "-v",
        "--version",
        action="version",
        version="release 0.1"
    )
    args = parser.parse_args()
    print(args)
    return args

def print_list(list):
    for i, image in enumerate(list):
        print(i, image)

def list_images(directory):
    ''' 
    Create a list of image tuples sorted by capture timestamp.
    @param directory: directory with JPEG files 
    @return: a list of image tuples with time, directory, lat,long...
    '''

    file_list = [os.path.join(os.path.abspath(directory), file) for file in os.listdir(directory) if file.lower().endswith(".jpg")]

    files = []
    # get DateTimeOriginal data from the images and sort the list by timestamp
    for filepath in file_list:
        metadata = EXIF(filepath)
        #metadata.read()
        try:
            t = metadata.extract_capture_time()
            #if t is None :
            #    print("Missing DateTimeOriginal on {}".format(filepath))
            #    exit()
            lon, lat = metadata.extract_lon_lat()
            img_direction = metadata.extract_direction()
            #print(filepath, lon, lat)
            #print(type(t))
            #s = metadata["Exif.Photo.SubSecTimeOriginal"].value
            files.append(Picture_infos(path=filepath, DateTimeOriginal = t,
                                                                SubSecTimeOriginal = None,
                                                                Latitude = lat,
                                                                Longitude = lon,
                                                                Ele = None,
                                                                ImgDirection = img_direction,
                                                                New_DateTimeOriginal=None ))
        except KeyError as e:
            # if any of the required tags are not set the image is not added to the list
            print("Skipping {0}: {1}".format(filepath, e))
    #try:
    #    files.sort(key=lambda file: file.DateTimeOriginal)
    #except Exception as e:
    #    print("Error on file - {}".format(e))
    #print_list(files)
    return files

def write_metadata(image_lists):
    """
    Write the exif metadata in the jpeg file
    :param image_lists : A list in list of New_Picture_infos namedtuple
    """
    for image_list in image_lists:
        for image in image_list:
            print(image)
            #TODO dans ces if, chercher pourquoi j'ai '' comme valeur, au lieu de None, ce qui
            #rendrait la condition plus lisible (if image.Latitude is not None:)
            # metadata = pyexiv2.ImageMetadata(image.path)
            metadata = ExifEdit(image.path)
            # metadata.read()
            metadata.add_date_time_original(image.New_DateTimeOriginal)
            # metadata.add_subsec_time_original(image.New_SubSecTimeOriginal)
            
            #if image.Latitude != "" and image.Longitude != "":
                #import pdb; pdb.set_trace()
            #    metadata.add_lat_lon(image.Latitude, image.Longitude)
                
            #if image.ImgDirection != "":
            #    metadata.add_direction(image.ImgDirection)
                
            #if image.Ele != "" and image.Ele is not None:
            #    metadata.add_altitude(image.Ele)
            metadata.write()
            print('Writing new Exif metadata to ', image.path)

def main(path):
    images_list=list_images(path)
    print("{} images found".format(len(images_list)))

    for idx, image in enumerate(images_list):
        unix_timestamp = int(image.path[-17:-4])/1000
        dt_obj = datetime.datetime.fromtimestamp(unix_timestamp)
        images_list[idx] = image._replace(New_DateTimeOriginal = dt_obj)
    #print_list(images_list)
    write_metadata([images_list])


if __name__ == '__main__':
    args=arg_parse()
    for _path in args.paths:
        print("Path is: ", _path)
        main(_path)
        if args.recursive:
            for sub_path in [f for f in os.scandir(_path) if f.is_dir()]:
                print("Path is: ", sub_path.path)
                main(sub_path.path)

    print("End of Script")
	