# Undercity eink lanyard

## How to flash it

__Note : only works on macos :/__

1. Clone the repo
    ```bash
    git clone
    ```
2. You need anaconda, imagemagick installed & arduino-cli. Install anaconda using this [link](https://www.anaconda.com/docs/getting-started/anaconda/install#macos-linux-installation)
    ```bash
    # arduino cli
    brew install arduino-cli

    # imagemagick
    brew install imagemagick

    arduino-cli config add board_manager.additional_urls https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json

    arduino-cli lib install "Adafruit NeoPixel"
    ```
3. Just run the script
    ```bash
    chmod +x upload.sh
    ./upload.sh
    ```
4. Follow the instructions and yay!

## Wooo

<img width="547" height="720" alt="image" src="https://github.com/user-attachments/assets/4808eedb-61ba-4868-983b-0e15dcd37818" />
