FROM ubuntu:latest

# Install OS prerequisites
RUN apt-get update -qq
RUN apt-get install -y openjdk-8-jdk \
  wget \
  expect \
  zip \
  unzip
RUN rm -rf /var/lib/apt/lists/*

# Create android-sdk directory
RUN mkdir /opt/android-sdk
RUN cd /opt/android-sdk

# Download the SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN unzip sdk-tools-linux-4333796.zip -d /opt/android-sdk
RUN rm -rf sdk-tools-linux-4333796.zip

# Set  paths and environment variables
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install platform tools
RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'

# Install SDKs - Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter android-25 | grep 'package installed'

# Install build tools - Please keep these in descending order!
RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.2 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.1 | grep 'package installed'
RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.0 | grep 'package installed'

# ALTERNATIVELY you can install everything like this
# RUN echo y | android update sdk --no-ui | grep 'package installed'

# List everything installed
RUN android list sdk --all

# Accept license - check this out http://d.android.com/r/studio-ui/export-licenses.html
RUN mkdir "$ANDROID_HOME/licenses" || true
RUN echo "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_HOME/licenses/android-sdk-license"
RUN echo "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_HOME/licenses/android-sdk-preview-license"

# Clean up
RUN apt-get clean

# Give jenkins access on android home
RUN chown -R 1000:1000 $ANDROID_HOME

# Share the android SDK using a volume
VOLUME ["/opt/android-sdk"]

# Set current working directory
RUN mkdir -p /app
WORKDIR /app
