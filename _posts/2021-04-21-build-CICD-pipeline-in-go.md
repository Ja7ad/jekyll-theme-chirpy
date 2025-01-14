---
title: Build CI/CD pipelines in Go with github actions and Dockers
author: Javad Rajabzade
date: 2021-05-27 12:18:23 +0800
categories: [Golang, Tutorial]
tags: [golang, go, cicd, github, action, docker]
---

This tutorial will show you how to setup a CI/CD pipeline using GitHub Actions. The pipeline will test, build and publish a Go app to Docker Hub when changes are pushed to a GitHub repository.

## Overview

Here is an overview of what’s in this guide:

- We start by creating a simple console app in Go that prints Hello World along with the version number of the app.
- We will create a GitHub repository and assign Docker Hub credentials using the Secrets feature of GitHub.
- We will create a GitHub workflow that runs Go tests each time a change is pushed to the main branch. The workflow will be configured to build a Docker image and push it to Docker Hub when a tag is pushed to the repository.
- The workflow will extract a version number from a Git tag and assign it to a Go variable at build time so the latest version is printed when the app is run.
- We will see the workflows in action. First by seeing what happens when we push code that fails tests. We will fix the code and see it pass, then we will see what happens when we push a tag.

# 1. Create Go Project

First let’s create a simple Go program that prints out Hello World along with the version number of our app.
Create a folder to store our files:

```console
javad@fedora:~$ mkdir ~/golang-pipeline
javad@fedora:~$ cd ~/golang-pipeline
```

Create **main.go** and **main_test.go**

```console
javad@fedora:~$ touch main.go
javad@fedora:~$ touch main_test.go
```

Add the following code to **main.go**

```go
package main

import "fmt"

var version = "dev"

func main() {

 fmt.Printf("Version: %s\n", version)

 fmt.Println(hello())
}

func hello() string {
 return "Hello Glang"
}
```

Note: the version variable is assigned the string `dev` and the string returned by the `hello` function is intentionally wrong so that our tests fail. Later we will see how the GitHub action can be configured to automatically replace the version string at build time.

Add the following code to **main_test.go**

```go
package main

import "testing"

func TestHello(t *testing.T) {

 want := "Hello Golang"

 got := hello()

 if want != got {
  t.Fatalf("want %s, got %s\n", want, got)
 }
}
```

Make sure our tests run and fail by running:

```console
javad@fedora:~$ go test

--- FAIL: TestHello (0.00s)
    main_test.go:9: want Hello Golang, got Hello Glang
FAIL
exit status 1
FAIL    hello   0.003s

```

It fails because we made the return value of the hello function wrong on purpose so we can test the CI/CD pipeline catches errors.

We can also test the app runs by running:

```console
javad@fedora:~$ go run main.go

Version: dev
Hello glang
```

Notice it prints out **dev** for the version. When we run the release version from the published image on Docker Hub, we will see the version number that was tagged when pushing a release to the GitHub repo.

# 2. Create GitHub Repository

Login to your GitHub account and create a new repository. For the following example I have created a new public repo (exmple [golang-pipeline](https://github.com/Ja7ad/golang-pipeline))

# 3. Assign Docker Hub Credentials as Secrets

For this step you will need to login to your Docker Hub account and generate an [access token](https://hub.docker.com/settings/security). Once you’ve done that, navigate to the **Settings** screen of the GitHub repository then click on **Secrets**.

![Create Secret DOCKER_USERNAME](https://raw.githubusercontent.com/Ja7ad/blog/master/images/golang-CICD/1.png)
_Create Secret DOCKER_USERNAME_

![Create Secret DOCKER_ACCESS_TOKEN](https://raw.githubusercontent.com/Ja7ad/blog/master/images/golang-CICD/2.jpg)
_Create Secret DOCKER_ACCESS_TOKEN_

![Secrets for pipeline](https://raw.githubusercontent.com/Ja7ad/blog/master/images/golang-CICD/3.png)
_Secrets for pipeline_

# 4. Create GitHub Workflow

We are now ready to create the GitHub workflow. Create a folder inside your repository called `.github/workflows` and add a file called **push.yml**.

```console
javad@fedora:~$ mkdir -p .github/workflows
javad@fedora:~$ touch .github/workflows/push.yml
```

Add the following config to the **push.yml** file:

```yml
name: golang-pipeline
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags')
    steps:
      - uses: actions/checkout@v2
      - name: Run Unit Tests
        run: go test

  deploy:
    runs-on: ubuntu-latest
    needs: test
    if: startsWith(github.ref, 'refs/tags')
    steps:
      - name: Extract Version
        id: version_step
        run: |
          echo "##[set-output name=version;]VERSION=${GITHUB_REF#$"refs/tags/v"}"
          echo "##[set-output name=version_tag;]$GITHUB_REPOSITORY:${GITHUB_REF#$"refs/tags/v"}"
          echo "##[set-output name=latest_tag;]$GITHUB_REPOSITORY:latest"

      - name: Print Version
        run: |
          echo ${{steps.version_step.outputs.version_tag}}
          echo ${{steps.version_step.outputs.latest_tag}}

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v1

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: PrepareReg Names
        id: read-docker-image-identifiers
        run: |
          echo VERSION_TAG=$(echo ${{ steps.version_step.outputs.version_tag }} | tr '[:upper:]' '[:lower:]') >> $GITHUB_ENV
          echo LASTEST_TAG=$(echo ${{ steps.version_step.outputs.latest_tag  }} | tr '[:upper:]' '[:lower:]') >> $GITHUB_ENV

      - name: Build and push
        id: docker_build
        uses: docker/build-push-action@v2
        with:
          push: true
          tags: |
            ${{env.VERSION_TAG}}
            ${{env.LASTEST_TAG}}
          build-args: |
            ${{steps.version_step.outputs.version}}

```

Replace Variables in the environment with **$** ( [example push.yml](https://github.com/Ja7ad/golang-pipeline/blob/main/.github/workflows/push.yml) )

The workflow config is quite simple. You will notice there are two jobs, one called **test** and one called **deploy**. The **test** job has one step that uses an if to make sure it only runs when changes are pushed to the main branch or a tag is pushed.

The deploy job requires the test job to run first so that if the tests fail, the Docker image will not be built. If the test job does pass, the remaining steps will run. The first step extracts the version number from a git tag that has the following format **v1.0.0**.

The next two steps setup the environment so that Docker images can be built. Finally, a step is run that signs into your Docker Hub account using the credentials stored in GitHub Secrets, then the Docker image is built and pushed to Docker Hub.

You Can see you run action pipeline in **https://github.com/USERNAME/golang-pipeline/actions** your repo.

# 5. Create Dockerfile

Now we need to create a **Dockerfile** for the GitHub action to use when building the image. Create a file called **Dockerfile** at the root of the repo.

```console
javad@fedora:~$ touch Dockerfile
```

Add the following to the **Dockerfile**:

```dockerfile
FROM golang:1.16.4-buster AS builder

ARG VERSION=dev

WORKDIR /go/src/app
COPY main.go .
RUN go build -o main -ldflags=-X=main.version=${VERSION} main.go 

FROM debian:buster-slim
COPY --from=builder /go/src/app/main /go/bin/main
ENV PATH="/go/bin:${PATH}"
CMD ["main"]
```

The config above uses a multi-stage build process to build the Go app then copy it to a slim Debian image. If you want to make the image smaller, you can change it to alpine or scratch.

Let’s test the **Dockerfile** by building it with the following command:

```console
javad@fedora:~$ docker build -t golang-pipeline:dev .

Sending build context to Docker daemon  114.2kB
Step 1/9 : FROM golang:1.16.4-buster AS builder
1.16.4-buster: Pulling from library/golang
d960726af2be: Pull complete 
e8d62473a22d: Pull complete 
8962bc0fad55: Pull complete 
65d943ee54c1: Pull complete 
f2253e6fbefa: Pull complete 
6d7fa7c7d5d3: Pull complete 
e2e442f7f89f: Pull complete 
Digest: sha256:ab32429d40c1b734ed4f036838ac516352182f9414563478fa88a1553c4a4414
Status: Downloaded newer image for golang:1.16.4-buster
 ---> 96129f3766cf
Step 2/9 : ARG VERSION=dev
 ---> Running in 819610ae34de
Removing intermediate container 819610ae34de
 ---> 9eec806043be
Step 3/9 : WORKDIR /go/src/app
 ---> Running in 46c0cf6a36b4
Removing intermediate container 46c0cf6a36b4
 ---> 1f1f66dfcc4f
Step 4/9 : COPY main.go .
 ---> 963a3bcf262b
Step 5/9 : RUN go build -o main -ldflags=-X=main.version=${VERSION} main.go
 ---> Running in c18447aa254a
Removing intermediate container c18447aa254a
 ---> 3d5364678624
Step 6/9 : FROM debian:buster-slim
buster-slim: Pulling from library/debian
69692152171a: Pull complete 
Digest: sha256:f077cd32bfea6c4fa8ddeea05c53b27e90c7fad097e2011c9f5f11a8668f8db4
Status: Downloaded newer image for debian:buster-slim
 ---> 80b9e7aadac5
Step 7/9 : COPY --from=builder /go/src/app/main /go/bin/main
 ---> f96694436dca
Step 8/9 : ENV PATH="/go/bin:${PATH}"
 ---> Running in 0423a0a1b60a
Removing intermediate container 0423a0a1b60a
 ---> 8ac59bcbe805
Step 9/9 : CMD ["main"]
 ---> Running in 1491bcf193c6
Removing intermediate container 1491bcf193c6
 ---> 190ba9407211
Successfully built 190ba9407211
Successfully tagged golang-pipeline:dev
```

Now run the image and see if it prints the incorrect string **Hello Glang**:

```console
javad@fedora:~$ docker run --rm golang-pipeline:dev

Version: dev
Hello glang
```

We can assign a version to the image by using `--build-arg VERSION=1.0.0` while building the image. For example:

```console
javad@fedora:~$ docker build -t golang-pipeline:1.0.0 . --build-arg VERSION=1.0.0

Sending build context to Docker daemon  114.2kB
Step 1/9 : FROM golang:1.16.4-buster AS builder
 ---> 96129f3766cf
Step 2/9 : ARG VERSION=dev
 ---> Using cache
 ---> 9eec806043be
Step 3/9 : WORKDIR /go/src/app
 ---> Using cache
 ---> 1f1f66dfcc4f
Step 4/9 : COPY main.go .
 ---> Using cache
 ---> 963a3bcf262b
Step 5/9 : RUN go build -o main -ldflags=-X=main.version=${VERSION} main.go
 ---> Running in 352fb8de7969
Removing intermediate container 352fb8de7969
 ---> 0950776088fa
Step 6/9 : FROM debian:buster-slim
 ---> 80b9e7aadac5
Step 7/9 : COPY --from=builder /go/src/app/main /go/bin/main
 ---> 91938ce4f326
Step 8/9 : ENV PATH="/go/bin:${PATH}"
 ---> Running in 44541fe9de77
Removing intermediate container 44541fe9de77
 ---> c8924b6b45b3
Step 9/9 : CMD ["main"]
 ---> Running in 424b93b94419
Removing intermediate container 424b93b94419
 ---> 9da417e7399b
Successfully built 9da417e7399b
Successfully tagged golang-pipeline:1.0.0
```

The docker image built can be found here:

```console
javad@fedora:~$ docker images

REPOSITORY                TAG             IMAGE ID       CREATED          SIZE
golang-pipeline           1.0.0           9da417e7399b   22 seconds ago   71.2MB
golang-pipeline           dev             190ba9407211   3 minutes ago    71.2MB
golang                    1.16.4-buster   96129f3766cf   2 weeks ago      862MB
debian                    buster-slim     80b9e7aadac5   2 weeks ago      69.2MB
```

The reason this works, is because we use `-ldflags` to modify the version variable at compile time. The `--build-arg` assigns the version to **VERSION** and is used in the following line:

```dockerfile
RUN go build -o main -ldflags=-X=main.version=${VERSION} main.go
```

Okay, we are now ready to push our code to the GitHub repository.

# 6. Push Code to Main

Now that we know our project builds and we have created a repository, we are ready to push our code to the main branch. Let’s initialise Git, commit our changes, add the origin, and push the changes by running the following commands (replace the repo URL with your own):

```console
javad@fedora:~$ git init
javad@fedora:~$ git add .
javad@fedora:~$ git commit -m "first commit"
javad@fedora:~$ git remote add origin git@github.com:USERNAME/golang-pipeline
javad@fedora:~$ git branch -M main
javad@fedora:~$ git push -u origin main
```

# 7. Check Build Failed

Go to your GitHub repository and click **Actions**. We should see the GitHub action running. Since we are pushing to the main branch, it will run the **test** job and it should fail.

![Github Action test fail](https://raw.githubusercontent.com/Ja7ad/blog/master/images/golang-CICD/5.png)
_Github Action test fail_

# 8. Fix Code so Test Passes

Let’s fix the broken test.
Open **main.go** and modify the return value of the `hello` function so that it returns `Hello Golang`.

```console
javad@fedora:~$ go test

PASS
ok      hello   0.003s
```

Commit and push the changes.

```console
javad@fedora:~$ git add .
javad@fedora:~$ git commit - "Fix hello function return value"
javad@fedora:~$ git push
```

The GitHub action should run again and now the test will pass.

![Github Action test successfully](https://raw.githubusercontent.com/Ja7ad/blog/master/images/golang-CICD/6.png)
_Github Action test successfully_

![Github Action status_](https://raw.githubusercontent.com/Ja7ad/blog/master/images/golang-CICD/7.png)
_Github Action status_

# 9. Push Tag

Now that we know the test passes, let’s push a release tag. We will tag this version as **v1.0.0**

```console
javad@fedora:~$ git tag v1.0.0
javad@fedora:~$ git push --tags
```

After pushing the tags, the GitHub action will run again and this time it will build the Docker image and push it to your Docker Hub repository.

