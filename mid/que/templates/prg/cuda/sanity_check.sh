#!/bin/bash
# This script do a quick check if one GPU or all GPUs are in good health.
# usage: ./sanity_check.sh 0   //check GPU 0
#        ./sanity_check.sh 1   //check GPU 1 
#        ./sanity_check.sh     //check All GPUs in the system

echo "Hostname:" $(hostname)
echo "Cuda environment settings:"
set | grep CUDA

if [ "$#" = "1" ]; then
	args="--device $1"
fi
#set -x
workdir=`dirname $0`
# $workdir/cuda_memtest --stress $args
$workdir/cuda_memtest --stress --num_passes 2 --num_iterations 100 $args
exit $?
