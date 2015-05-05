#!/bin/bash
# -------------------------------------------------------------------------------
# Author:    	Michael DeGuzis
# Git:	    	https://github.com/ProfessorKaos64/higan-src
# Scipt Name:	build-higan.sh
# Script Ver:	0.1.1
# Description:	Attempts to build higan from src
#
# Usage:	./build-higan-sh
# -------------------------------------------------------------------------------

time_start=$(date +%s)
time_stamp_start=(`date +"%T"`)

m_install_ue4_src()
{
  
# start apt mode if check
if [[ "$apt_mode" == "install" ]]; then
  
  #################################################
  # Prerequisites
  #################################################
  
  # Handled by desktop-software.sh
  # Software list: cfgs/ue4.txt
  
  ######################
  # Clang notice:
  ######################
  
  # Old version is only available
  # From UE4 Team: Note: as of 4.7, we want to install those packages in 
  # semi-automatic way (from Setup.sh). While you can certainly use the 
  # manual way, it is preferred to use - and test - provided "out of the box" experience.
  # 1:3.0-6.2 Debian:7.8/oldstable 
  
  # per this, we will attempt using setup.sh instead of ue4.txt first
  
  #################################################
  # Initial setup
  #################################################
  
  
  # notify user they MUST have a UE4 account to build
  echo -e "\nMake sure you linked your GitHub account to your profile on \
https://unrealengine.com, as all Epic repositories are private. The script \
may ask you to install additional packages (on certain distributions), then \
it will download the archives with binary dependencies (by default, to \
~/Downloads), which are pretty large (3GB in total) - they won't be re-downloaded \
unless they are updated for the particular release tag. If any new archives have \
been downloaded (which is the case the first time you do this), the script will \
unpack them over your repository (it will ask you to confirm that action as it \
is potentially destructive). You can force this by supplying -updatedeps flag \
if for some reason you want to unpack them again.\n\nPress [ENTER] to continue \
or CTRL+C to abort.\n"
  
  read -n 1 
  printf "\nContinuing...\n" 
  clear 
  
  # set vars
  export install_dir="/home/desktop/ue4-src"
  export git_dir="/home/desktop/ue4-src/UnrealEngine"
  export git_url="https://github.com/3dluvr/UnrealEngine.git"
  #export symlink_target="/usr/bin/ue4"
  #export binary_loc="$git_dir/ue4"

  # If git folder UnrealEngine exists, evaluate it
  # Avoiding a large download again is much desired.
  # If the DIR is already there, the fetch info should be intact
  
  # start git check if
  if [[ -d "$git_dir" ]]; then
  	
  	echo -e "\n==Info==\nGit folder already exists! Attempting git pull...\n"
  	sleep 1s
  	# attempt to pull the latest source first
  	cd $git_dir
  	# eval git status
  	output=$(git pull $git_url)
  
  	# evaluate git pull. Remove, create, and clone if it fails
  	# start git pull check
  	if [[ "$output" != "Already up-to-date." ]]; then
  		echo -e "\n==Info==\nGit directory pull failed. Removing and cloning...\n"
  		sleep 2s
  		cd
  		rm -rf "$git_dir"
  		mkdir -p "$install_dir"
  		cd "$install_dir"
  		# clone and fetch super build (evaluating currently)
  		git clone "$git_url"
  else
  	echo -e "\n==Info==\nGit directory does not exist. cloning now...\n"
  	sleep 2s
  	# create and clone
  	mkdir -p "$install_dir"
  	cd "$install_dir"
  	# clone and fetch super build (evaluating currently)
  	git clone "$git_url"
  
    # end  git pull check
    fi
  
  # end git check if
  fi
 
  #################################################
  # Build UE4
  #################################################
  
  echo -e "\n==> Building sources...please wait"
  sleep 2s
  
  ############################
  # proceed to global build:
  ############################
  
  # perform directory check for *.so (libretro cores) in
  # /usr/bin/libretro. These will be present if this module was
  # already ran before
  
  ue4_check=$(ls "$git_dir")
  
  ############################
  # Begin UE4 build eval
  ############################
  
  # start UE4 build eval
  if [[ "$ue4_check" != "" ]]; then
  	
  	echo -e "\n==INFO=="
  	echo -e "It seems UE4 is already built in $git_dir"
  	echo -e "Would you like to rebuild [y], or [n]?\n"
  	
  	# the prompt sometimes likes to jump above sleep
  	sleep 0.5s
  	
  	# gather user input
  	read -ep "Choice: " user_input_ue4
  	
  	if [[ "$user_input_ue4" == "n" ]]; then
  		echo -e "\n==> Skipping UE4 build...\n"
  		sleep 2s
  	elif [[ "$user_input_ue4" == "y" ]]; then
  		echo -e "\n==> Rebuilding UE4...\n"
  		sleep 2s
  		# build UE4
  		./Setup.sh
      ./GenerateProjectFiles.sh
  	else
  		echo -e "\n==ERROR=="
  		echo -e "Invalid input, exiting...\n"
  		sleep 2s
  		exit
  	fi
  else	
  	echo -e "\nUE4 does not appear to be built."
  	echo -e "Building now...\n"
  	sleep 2s
  	# build UE4
  	./Setup.sh
    ./GenerateProjectFiles.sh
  
  # end UE4 build eval
  fi
  
  #################################################
  # Post install configuration
  #################################################
  
  # TODO
  
  #################################################
  # Cleanup
  #################################################
  
  # clean up dirs
  
  # note time ended
  time_end=$(date +%s)
  time_stamp_end=(`date +"%T"`)
  runtime=$(echo "scale=2; ($time_end-$time_start) / 60 " | bc)
  
  # output finish
  echo -e "\nTime started: ${time_stamp_start}"
  echo -e "Time started: ${time_stamp_end}"
  echo -e "Total Runtime (minutes): $runtime\n"
  
  
  elif [[ "$apt_mode" == "remove" ]]; then
  
    #Remove directories, build files, etc if uninstall is specified by user
    echo -e "\n==> Removing related files for UE4-src routine"
    sleep 2s
    
    # remove directories
    sudo rm -rf "$install_dir" "$git_dir" "$symlink_target"
  
  # end apt mode if check  
  fi

}
