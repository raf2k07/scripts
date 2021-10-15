#!/bin/sh
PROJECT_NAME=$1
PROJECT_BACKEND=$2

# TODO add firebase analytics
# TODO add dockerfile

#Create next app and cd into it
npx create-next-app --ts $PROJECT_NAME
cd $PROJECT_NAME

# Checking if firebase cli is installed
if [ "$PROJECT_BACKEND" = "firebase" ] || [ "$PROJECT_BACKEND" = "auth" ]; then
    FIRECLI=$(npm list -g | grep firebase-tools)
    if [ "$FIRECLI" = "" ]; then
        echo "Firebase CLI not installed. Install now? (y/n)"
        read choice
        if [ $choice = "y" ]; then
            npm i -g firebase-tools
        elif [ $choice = "n" ]; then
            echo "You need to have firebase tools installed. Install manually and then rerun this script. "
            exit
        fi
    fi
fi

#Installing dependencies
if [ "$PROJECT_BACKEND" = "auth" ]; then
    echo "Initializing project with firebase auth..."
    yarn add @mui/material @emotion/react @emotion/styled @emotion/server firebase next-firebase-auth formik yup date-fns
    # Initialize a project to use Firebase Analytics
    firebase init functions

elif ["$PROJECT_BACKEND" = "firebase"]; then
    echo "Initializing project with Firebase..."
    yarn add @mui/material @emotion/react @emotion/styled @emotion/server firebase firebase-admin next-firebase-auth formik yup date-fns
    firebase init
else
    echo "Initializing project without backend..."
    yarn add @mui/material @emotion/react @emotion/styled @emotion/server

fi

#Fetching firebase project config
if [ "$PROJECT_BACKEND" = "firebase" ] || [ "$PROJECT_BACKEND" = "auth" ]; then
    script -c "firebase apps:sdkconfig" config.txt
    # TODO put CONFIG somewhere
    # Trim the script output to get only the config JSON
    CONFIG=$(tail -13 config.txt | head -9)
    rm config.txt
    echo "$CONFIG"
fi

#Directory structure
echo "Creating directories and files..."
mkdir components components/common/ components/hoc/ assets constants lib
touch .env.development .env.production

#Configuration files
echo "Downloading config files..."
# SYNTAX FOR WRITING FROM CURL TO A FILE
# curl <github-raw-url> >> <filename>

# Prettier Config Files
curl https://gist.githubusercontent.com/raf2k07/41590e9085219c491af749303814ed4b/raw/4af1babab13fda145f83ae6d0eb4dabe4adf5356/.prettierignore >>.prettierignore
curl https://gist.githubusercontent.com/raf2k07/41590e9085219c491af749303814ed4b/raw/4af1babab13fda145f83ae6d0eb4dabe4adf5356/.prettierrc >>.prettierrc

# MUI Configuration for Next
curl https://gist.githubusercontent.com/raf2k07/41590e9085219c491af749303814ed4b/raw/59de14fc293da81290f6ac3ae3424a68388f628a/_app.tsx >./pages/_app.tsx
curl https://gist.githubusercontent.com/raf2k07/41590e9085219c491af749303814ed4b/raw/59de14fc293da81290f6ac3ae3424a68388f628a/_document.tsx >./pages/_document.tsx

# Placeholder theme file for MUI
curl https://gist.githubusercontent.com/raf2k07/41590e9085219c491af749303814ed4b/raw/59de14fc293da81290f6ac3ae3424a68388f628a/theme.ts >./lib/theme.ts
# SSR requirement for MUI v5
curl https://gist.githubusercontent.com/raf2k07/41590e9085219c491af749303814ed4b/raw/59de14fc293da81290f6ac3ae3424a68388f628a/createEmotionCache.ts >./lib/createEmotionCache.ts

# next-firebase-auth setup
if [ "$PROJECT_BACKEND" = "firebase" ] || [ "$PROJECT_BACKEND" = "auth" ]; then
    echo "Adding firebase auth config..."
    curl https://gist.githubusercontent.com/raf2k07/41590e9085219c491af749303814ed4b/raw/91eab00b45fb2a1571a447ea8d3353371a1674a1/initAuth.ts >./lib/initAuth.ts
fi

echo "Successfully created $PROJECT_NAME"
