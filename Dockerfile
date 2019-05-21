FROM ubuntu:latest

# Install OS prerequisites
RUN apt-get update -qq
RUN apt-get install -y openjdk-8-jdk \
  wget \
  expect \
  zip \
  unzip

# Create android-sdk directory
RUN mkdir /opt/android-sdk
RUN cd /opt/android-sdk

# Download the SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools-linux-4333796.zip -d /opt/android-sdk
RUN rm -rf sdk-tools-linux-4333796.zip

# Set  paths and environment variables
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Accept license
RUN yes | sdkmanager --licenses

# platform tools
RUN sdkmanager emulator tools platform-tools

# Install SDKs - Please keep these in descending order!
RUN yes | sdkmanager "platforms;android-28"
RUN yes | sdkmanager "build-tools;28.0.3"
RUN yes | sdkmanager "build-tools;28.0.2"
RUN yes | sdkmanager "build-tools;28.0.1"
RUN yes | sdkmanager "build-tools;28.0.0"
RUN yes | sdkmanager "system-images;android-28;google_apis;x86"

# Install Google Cloud
RUN apt-get install curl \
  gcc \
  python-dev \
  python-setuptools \
  apt-transport-https \
  lsb-release \
  openssh-client \
  git \
  gnupg
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
RUN echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update -qq
RUN apt-get install -y google-cloud-sdk

# Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get clean

# Give jenkins access on android home
RUN chown -R 1000:1000 $ANDROID_HOME

# Set current working directory
RUN mkdir -p /app
WORKDIR /app
