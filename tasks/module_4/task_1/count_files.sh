#!/bin/bash

func() {
    dir=$1
    files=`find $dir -type f | wc -l`
    echo "total number of files in $dir: $files"
}
func $@