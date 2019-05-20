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

# Clean up
RUN apt-get clean

# Give jenkins access on android home
RUN chown -R 1000:1000 $ANDROID_HOME

# Share the android SDK using a volume
VOLUME ["/opt/android-sdk", "/root/.gradle"]

# Set current working directory
RUN mkdir -p /app
WORKDIR /app
