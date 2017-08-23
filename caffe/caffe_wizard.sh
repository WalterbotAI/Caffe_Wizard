#!/usr/bin/env sh
# Authors
# @Author: Wen Wei, defined the list of steps of the whole install process
# @Author: Tony Wang, defined the list of steps of the whole install process
# @Author: Walter Riviera, wrote this wizard
#
# Contacts:
# @email: wei.wen@intel.com
# @email: tony.z.wang@intel.com
# @email: walter.riviera@intel.com
# @Authors_info: DCG Sales - AI Technical Solution Specialists
# @date: 1st release 14/07/2017
# 
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# RESTRICTIONS:
# This code has been tested on Centos7. Help to tests on different platform is required.
#
# DESCRIPTION:
# This code automate the Caffe frameworks intallation process (on Centos7).
# The procedure adopted is the one provided by Tony Wang & Wen Wei in the pdf v2.
#
# type:
# sudo bash caffe_wizard.sh [SINGLE/multi], according to the required install configuration.
# 
# The whole process produce a log file named "install_log.txt" that can be useful in case
# of unexpected interruptions



## INIT
echo INIT
echo LOG_FILE_INIT > install_log.txt

# checking parameter value: [SINGLENODE/multinode]
if [ $1 ]; then
	paramlower=`echo $1 | tr '[:upper:]' '[:lower:]'`
	
	if [ $paramlower = 'multi' ]; then
		mode='MULTI'
	elif [ $paramlower = 'single' ]; then
		mode='single'
	else
		echo unrecognized mode $paramlower >> install_log.txt
		exit 1
	fi
else
	mode='single'
fi

echo mode is $mode node >> install_log.txt
echo $mode



######################### AUX functions ##########################
function check_cmd(){

	if [ $1 ];
	then	
		echo $1 >> install_log.txt;
	else	
		echo exit 1, because $1 has FAILED
		echo $1 FAILED >> install_log.txt;
		exit 1
	fi
	return 0
}


function check_ffmpeg(){

	URL="http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-2.el7.nux.noarch.rpm"

	# Run the command
	eval $1	

	if [ -z $? ];
	then	
		echo $1 >> install_log.txt;
	else	
		sudo rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
		sudo rpm -Uvh $URL
		check_cmd `yum -y install ffmpeg ffmpeg-devel`;

		sudo yum-config-manager --disable nux-dextop
	fi
	return 0
}



function setEnvVar(){
	
	echo $1 | grep -q $2
	
	if [ -z $? ];
	then	
		echo $1 = $2 >> install_log.txt;
	else	
		export LD_LIBRARY_PATH = /usr/lib64:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH
		export $1 = $2:$1
	fi
	return 0

}

###################################################################



echo PREPARING DEVELOPMENT ENVIRONMENT
## PREPARING DEVELOPMENT ENVIRONMENT
#-------------------------------------------------------------------
#check_cmd `sudo yum update`
sudo yum update
check_cmd `sudo yum -y install make` && echo sudo yum install make >> install_log.txt;
check_cmd `sudo yum -y install cmake` && echo sudo yum install cmake >> install_log.txt;

check_cmd `sudo yum -y install epel-release` && echo sudo yum -y install epel-release >> install_log.txt;

# Development Tools might bring to some issue. One way to solve it is to run yum clean all before it
yum clean all 
check_cmd `sudo yum -y groupinstall "Development Tools"` && echo sudo yum -y groupinstall "Development Tools" >> install_log.txt;

check_cmd `sudo yum -y install gcc` && echo sudo yum -y install gcc >> install_log.txt;
check_cmd `sudo yum -y install git` && echo sudo yum -y install git >> install_log.txt;
check_cmd `sudo yum -y install gtk2-devel` && echo sudo yum -y install gtk2-devel >> install_log.txt;
check_cmd `sudo yum -y install pkgconfig` && echo sudo yum -y install pkgconfig >> install_log.txt;

check_ffmpeg `sudo yum -y install ffmpeg ffmpeg-devel` && echo sudo yum -y install ffmpeg ffmpeg-devel >> install_log.txt;

check_cmd `sudo yum -y install libjpeg-turbo` && echo sudo yum -y install libjpeg-turbo >> install_log.txt;
check_cmd `sudo yum -y install libpng-devel` && echo sudo yum -y install libpng-devel >> install_log.txt;
check_cmd `sudo yum -y install libtiff-devel` && echo sudo yum -y install libtiff-devel >> install_log.txt;
check_cmd `sudo yum -y install python-devel python-pip` && echo sudo yum -y install python-devel python-pip >> install_log.txt;
check_cmd `sudo yum -y install numpy scipy` && echo sudo yum -y install numpy scipy >> install_log.txt;


echo INSTALLING DEPENDECIES
## INSTALLING DEPENDENCIES
#------------------------------------------------------------------
check_cmd `sudo yum -y install protobuf-devel leveldb-devel snappy-devel opencv-devel boost-devel hdf5-devel` && echo sudo yum -y install protobuf-devel leveldb-devel snappy-devel opencv-devel boost-devel hdf5-devel >> install_log.txt;
check_cmd `sudo yum -y install gflags-devel glog-devel lmdb-devel` && echo sudo yum -y install gflags-devel glog-devel lmdb-devel >> install_log.txt;


## INSTALLING MKL MANUALLY
#------------------------------------------------------------------
#Download MKL library from this link: https://github.com/intel/caffe/releases/
#MKL="mklml_lnx_2018.0.20170425.tgz"

#if [ -e $MKL ]; 
#then
#	echo "MKL library already downloaded!";

#else 
	# need to visit the link to understand which is the latest version of MKL
#	wget https://github.com/intel/caffe/releases/download/1.0.0/MKL
#	echo $MKL downloaded >> install_log.txt

	# Check if file correctly downloaded
#	tar -xvf $MKL
#	echo $MKL Unzipped  >> install_log.txt;
#fi




# DOWNLOADING LATEST CAFFE VERSION (with latest MKL version included)
echo DOWNLOADING LATEST CAFFE VERSION
#------------------------------------------------------------------

if [ ! -e 'caffe' ]; 
then
	# Download caffe from github repo
	git clone https://github.com/intel/caffe.git
fi	


# Get latest MKL
# Prepare MKL and extract fields value
echo Get latest MKL

# download and set-up mkl
install_status=`ls caffe/external/mkl/ | wc -l`
if [ $install_status == 1 ];
then

	cmd=`./caffe/external/mkl/prepare_mkl.sh`
	if [ cmd ];
	then 
		echo MKL library succesfully downloaded >> install_log.txt;
	else
		echo "prepare_mkl.sh" run FAILED >> install_log.txt;
		exit 1
	fi

else
	echo "MKL already downloaded - download skipped"
	echo MKL already downloaded >> install_log.txt;	
fi




# Save lib and include mkl paths
mkl_lib_pt=`find caffe/external -type d -name "lib"`
mkl_include_pt=`find caffe/external -type d -name "include"`

if [ -z "$mkl_lib_pt" ];
then
	echo exit 1, because mkl_lib_path not found
	echo mkl_lib_path not found >> install_log.txt;
	exit 1
else
	if [ -z "$mkl_include_pt" ];
	then
		echo exit 1, because mkl_include_path not found
		echo mkl_include_path not found >> install_log.txt;
		exit 1
	else

		# Extract dir names from path
		IFS='/' read -r -a dirnames <<< "$mkl_lib_pt"
		MKL=${dirnames[3]}
			
		#	Modify make.config here
		echo MKL version is $MKL
		echo "MKL version found:" $MKL >> install_log.txt;
	fi		
fi		

# Export env variables
echo EXPORTING ENV VARs
#------------------------------------------------------------------

# LD_LIBRARY_PATH
#export LD_LIBRARY_PATH = /usr/lib64:/usr/local/lib:/usr/lib:$LD_LIBRARY_PATH

val=/usr/lib
echo $LD_LIBRARY_PATH | grep -q $val
if [ $? == 0 ]; then echo $val already added to LD_LIBRARY_PATH >> install_log.txt; else export LD_LIBRARY_PATH=$val:$LD_LIBRARY_PATH; echo $val added to LD_LIBRARY_PATH >> install_log.txt; fi

val=/usr/local/lib
echo $LD_LIBRARY_PATH | grep -q $val
if [ $? == 0 ]; then echo $val already added to LD_LIBRARY_PATH >> install_log.txt; else export LD_LIBRARY_PATH=$val:$LD_LIBRARY_PATH; echo $val added to LD_LIBRARY_PATH >> install_log.txt; fi

val=/usr/lib64
echo $LD_LIBRARY_PATH | grep -q $val
if [ $? == 0 ]; then echo $val already added to LD_LIBRARY_PATH >> install_log.txt; else export LD_LIBRARY_PATH=$val:$LD_LIBRARY_PATH; echo $val added to LD_LIBRARY_PATH >> install_log.txt; fi


# PYTHONPATH
# export PYTHONPATH=${HOME}/caffe/python:$PYTHONPATH
val=${HOME}/caffe/python
echo $PYTHONPATH | grep -q $val
if [ $? == 0 ]; then echo $val already added to PYTHONPATH >> install_log.txt; else export PYTHONPATH=$val:$PYTHONPATH; echo $val added to PYTHONPATH >> install_log.txt; fi

# MKLROOT
#export MKLROOT=${HOME}/caffe/external/mkl/$MKL
val=${HOME}/caffe/external/mkl/$MKL
echo $MKLROOT | grep -q $val
if [ $? == 0 ]; then echo $val already added to MKLROOT >> install_log.txt; else export MKLROOT=$val: ; echo $val added to MKLROOT >> install_log.txt; fi


# PATH
#export PATH=/usr/bin:/usr/include/python2.7:$PATH
val=/usr/include/python2.7
echo $PATH | grep -q $val
if [ $? == 0 ]; then echo $val already added to PATH >> install_log.txt; else export PATH=$val:$PATH; echo $val added to PATH >> install_log.txt; fi


val=/usr/bin
echo $PATH | grep -q $val
if [ -nz $? ]; then export PATH=$val:$PATH; fi
if [ $? == 0 ]; then echo $val already added to PATH >> install_log.txt; else export PATH=$val:$PATH; echo $val added to PATH >> install_log.txt; fi



if [ "$mode" == "MULTI" ];
then

	#LD_LIBRARY_PATH=opt/intel/mlsl_2017.0.006/intel64/lib:$LD_LIBRARY_PATH
	val=opt/intel/mlsl_2017.0.006/intel64/lib
	echo $LD_LIBRARY_PATH | grep -q $val
	if [ $? == 0 ]; then echo $val already added to LD_LIBRARY_PATH >> install_log.txt; else export LD_LIBRARY_PATH=$val:$LD_LIBRARY_PATH; echo $val added to LD_LIBRARY_PATH >> install_log.txt; fi


	#export PATH=/opt/intel/impi/2017.1.132/bin64:$PATH;
	val=opt/intel/impi/2017.1.132/bin64
	echo $PATH | grep -q $val
	if [ $? == 0 ]; then echo $val already added to PATH >> install_log.txt; else export PATH=$val:$PATH; echo $val added to PATH >> install_log.txt; fi

fi	


# MAKEFILE CONFIGURATION
echo MAKEFILE CONFIGURATION
#------------------------------------------------------------------
cp caffe/Makefile.config.example caffe/Makefile.config

#TODO: Add a check_cmd function for sed ops.
# Replacing # BLAS_INCLUDE := /path/to/your/blas
sed -i -e "s|\# BLAS_INCLUDE := /path/to/your/blas|BLAS_INCLUDE := external/mkl/$MKL/include|g" caffe/Makefile.config
echo "BLAS_INCLUDE should have := external/mkl/$MKL/include" >> install_log.txt

# Replacing # BLAS_LIB := /path/to/your/blas
#check_cmd `sed -i -e "s|\# BLAS_LIB := /path/to/your/blas|BLAS_LIB := external/mkl/$MKL/lib|g" mfw`
sed -i -e "s|\# BLAS_LIB := /path/to/your/blas|BLAS_LIB := external/mkl/$MKL/lib|g" caffe/Makefile.config
echo "BLAS_LIB  should have := external/mkl/$MKL/lib" >> install_log.txt


# Replacing PYTHON_INCLUDE := PYTHON_INCLUDE := /usr/include/python2.7 \
#		/usr/lib/python2.7/dist-packages/numpy/core/include
#check_cmd `sed -i -e 's|\\t\\t/usr/lib/python2.7/dist-packages/numpy/core/include|/usr/lib64/python2.7/dist-packages/numpy/core/include|g' mfw`
sed -i -e "s|\\t\\t/usr/lib/python2.7/dist-packages/numpy/core/include|\\t\\t/usr/lib64/python2.7/dist-packages/numpy/core/include|g" caffe/Makefile.config
echo "PYTHON_INCLUDE should have := /usr/lib64/python2.7/dist-packages/numpy/core/include" >> install_log.txt


# Replacing PYTHON_LIB := /usr/lib
#check_cmd `sed -i -e 's|PYTHON_LIB := /usr/lib|PYTHON_LIB := /usr/lib64|g' mfw`
sed -i -e 's|PYTHON_LIB := /usr/lib|PYTHON_LIB := /usr/lib64|g' caffe/Makefile.config
echo "PYTHON_LIB should have:= /usr/lib64" >> install_log.txt


# Get ready to buld it!
if [ "$mode" == "MULTI" ];
then
	# Replacing INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include
	#check_cmd `sed -i -e 's|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include /usr/include/opencv /opt/intel/mlsl_2017.0.006/intel64/include|g' mfw`
	sed -i -e 's|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include /usr/include/opencv /opt/intel/mlsl_2017.0.006/intel64/include|g' caffe/Makefile.config
	echo "INCLUDE_DIRS should have:= /opt/intel/mlsl_2017.0.006/intel64/include" >> install_log.txt

	# Replacing LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib
	#check_cmd `sed -i -e 's|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib64 /opt/intel/mlsl_2017.0.006/intel64/lib|g' mfw`
	sed -i -e 's|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib64 /opt/intel/mlsl_2017.0.006/intel64/lib|g' caffe/Makefile.config
	echo "LIBRARY_DIRS should have:= /opt/intel/mlsl_2017.0.006/intel64/lib" >> install_log.txt

else
	# Replacing INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include
	#check_cmd `sed -i -e 's|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include /usr/include/opencv|g' mfw`
	sed -i -e 's|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include|INCLUDE_DIRS := \$(PYTHON_INCLUDE) /usr/local/include /usr/include/opencv|g' caffe/Makefile.config
	echo "INCLUDE_DIRS should have:= /usr/include/opencv" >> install_log.txt

	# Replacing LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib
	#check_cmd `sed -i -e 's|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib64|g' mfw`
	sed -i -e 's|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib|LIBRARY_DIRS := \$(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib64|g' caffe/Makefile.config
	echo "LIBRARY_DIRS should have:= /usr/lib64" >> install_log.txt
fi


# LET'S BUILD!!!
echo BUILD CAFFE
#-------------------------------------------------------------------
# Calculate number of threads
cd caffe
make all -j64 -k
