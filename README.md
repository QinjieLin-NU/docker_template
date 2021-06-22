# docker_template

## step1: install the dependency

1. code you own file in the ros folder to install dependency,  this file should include all the command line that wraps all the dependency required by your projects.
2. include it in the Dockerfile, COPY to the container folder

## step2: customize docker entrypoint

1. modify the startup folder
2. include it the Dockerfile
3. set your own entrypoint

## step3: build the images

goto the directory including the dockerfile, run `docker build .`, then we will get the image id

## step4: run the images

run `docker run --netowrk host -it IMAGE_ID` to run the container, use the VNCVIEWER to visualzie your container, check whether all the dependency has been installed or not.



