# syntax=docker/dockerfile:1

# https://create.arduino.cc/projecthub/B45i/getting-started-with-arduino-cli-7652a5
# https://learn.adafruit.com/adafruit-metro-esp32-s2/arduino-ide-setup-2

FROM debian:buster AS arduino-installer
RUN apt-get update && apt-get install -y \
    wget \
    xz-utils \
    python3 python3-pip \
    unzip #TODO: remove when Nugget_Screen is ready
RUN pip3 install pyserial

WORKDIR /app
ARG ARDUINO_CLI_VERSION=0.22.0
RUN wget https://github.com/arduino/arduino-cli/releases/download/${ARDUINO_CLI_VERSION}/arduino-cli_${ARDUINO_CLI_VERSION}_Linux_64bit.tar.gz
RUN tar -xf arduino-cli_${ARDUINO_CLI_VERSION}_Linux_64bit.tar.gz

RUN mkdir RubberNugget
COPY RubberNugget ./RubberNugget
COPY arduino-cli.yaml .
#TODO: remove lines below
COPY Nugget_Interface.zip ./RubberNugget
RUN cd RubberNugget && ls && unzip Nugget_Interface.zip

RUN ./arduino-cli core update-index --config-file arduino-cli.yaml
RUN ./arduino-cli core install esp32:esp32

RUN ./arduino-cli lib install \
    "ESP8266 and ESP32 OLED driver for SSD1306 displays" \
    "Adafruit NeoPixel"
# TODO: figure out how to version control packages from git
RUN ./arduino-cli lib install --git-url \
    "https://github.com/dojyorin/arduino_base64" \
    "https://github.com/chegewara/EspTinyUSB"
    # https://github.com/HakCat-Tech/Nugget_Screen

RUN ./arduino-cli compile -b esp32:esp32:esp32s2 RubberNugget/
