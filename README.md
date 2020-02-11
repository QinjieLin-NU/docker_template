# docker_template

## step1:  warp the dependency

modify the dep/install_dependency.sh, this file should include all the command line that wraps all the dependency required by your projects.

## step2: build the images

goto the directory including the dockerfile, run `docker build .`, then we will get the image id

## step3: run the images

run `docker run -it IMAGE_ID` to run the container, use the VNCVIEWER to visualzie your container, check whether all the dependency has been installed or not.

## step4: contact the TA if the images work well



