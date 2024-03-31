#!/bin/bash

# check if user is root or sudo
if ! [ $( id -u ) = 0 ]; then
    echo "Please run this script as sudo or root" 1>&2
    exit 1
fi

# download the nodejs source config script
curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
bash nodesource_setup.sh

# config the source of yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update

# install nodejs
apt install -y nodejs yarn

# get env variables
read -p "Enter OPENAI_API_KEY: " OPENAI_API_KEY
read -p "Enter CODE: " CODE
read -p "Enter PORT: " PORT

rm -rf .env.local
touch .env.local
echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> .env.local
echo "CODE=$CODE" >> .env.local

# install packages
yarn install
yarn build

# making chat-next-web service
rm -rf /etc/systemd/system/chat-next-web.service
echo "[Unit]
Description=ChatGPT Next Web

[Service]
Environment=PORT=$PORT
ExecStart=/usr/bin/yarn start
WorkingDirectory=/home/Panda/ChatGPT-Next-Web/
Restart=on-abnormal

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/chat-next-web.service

systemctl daemon-reload
