#!/bin/bash
set -e

show_usage() { 
        echo "$0 <dir> <filename prefix> debian repo directory" 
} 

rename_debs() {
    dir=$1
    for filename in "$dir"/*.deb; do
        deb_info=`dpkg --info "$filename" |  egrep "Version|Package|Architecture"`
        name=`echo $deb_info | cut -d ' ' -f2`
        arch=`echo $deb_info | cut -d ' ' -f6`
        version=`echo $deb_info | cut -d ' ' -f4`
        newfile="$name"_"$arch"_"$version".deb
        if [ "$filename" != "$dir/$newfile" ]; then
                mv "$filename" "$dir/$newfile"
                echo "$newfile"
        fi
    done
}

if [  $# -ne 2 ] 
then 
        show_usage
        exit 1
fi 

if [[ ( $# == "--help") ||  $# == "-h" ]] 
then 
        show_usage
        exit 0
fi 

rename_debs $1
rm -f $dir/Packages
deb-pkg-tools -u $1

# Hacking begins :)
rm -f $dir/Release
rm -f $dir/Packages.gz
sed -i -e "s?Filename: ?Filename: $2/?g" $dir/Packages
