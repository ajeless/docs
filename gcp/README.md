# Google Cloud Platform: Remote Development Server Setup

Setup a remote development environment with linux, chrome remote desktop, and access to your private github repositories.
This guide uses Debian as a linux instance and XFCE desktop.  
To see other virtual worksation options see [Creating a virtual workstation](https://cloud.google.com/solutions/creating-a-virtual-workstation)

## Requirements
* [Google Cloud](https://cloud.google.com) account
* [Project in which to work](https://console.cloud.google.com/projectcreate)

## Step 1: Create Source Instance on Google Compute Engine (GCE)
See [Setting up Chrome Remote Desktop for Linux on Compute Engine]() for a complete explanation.

1. Go to https://console.cloud.google.com/compute/instancesAdd
1. Fill in the instance name
1. Optionally select a region
1. Optionally select 'Allow full access to all Cloud APIs', 'Allow HTTP traffic', and 'Allow HTTPS traffic'
1. Optionally choose 'e2-standard-2 (2 vCPU, 8 GB memory)' for machine type
1. Expand the link/dropdown 'Management, security, disks, networking, sole tenancy'
1. Paste the following startup script in the 'Automation' section
    ```bash
    #!/bin/bash -x

    # Bootstrap installation for XFCE, Chrome Remote Desktop, and Chrome
    # See environmental variables at then end of the script for configuration

    # Any additional packages that should be installed on startup can be added here
    EXTRA_PACKAGES="wget software-properties-common build-essential git less bzip2 zip unzip manpages-dev authbind"

    apt update -y
    apt upgrade -y
    apt dist-upgrade -y
    apt full-upgrade -y
    apt autoremove -y
    apt autoclean -y

    function install_desktop_env {
    PACKAGES="desktop-base xscreensaver"

    if [[ "$INSTALL_XFCE" != "yes" && "$INSTALL_CINNAMON" != "yes" ]] ; then
        # neither XFCE nor cinnamon specified; install both
        INSTALL_XFCE=yes
        INSTALL_CINNAMON=yes
    fi

    if [[ "$INSTALL_XFCE" = "yes" ]] ; then
        PACKAGES="$PACKAGES xfce4"
        echo "exec xfce4-session" > /etc/chrome-remote-desktop-session
        [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
        PACKAGES="$PACKAGES task-xfce-desktop"
    fi

    if [[ "$INSTALL_CINNAMON" = "yes" ]] ; then
        PACKAGES="$PACKAGES cinnamon-core"
        echo "exec cinnamon-session-cinnamon2d" > /etc/chrome-remote-desktop-session
        [[ "$INSTALL_FULL_DESKTOP" = "yes" ]] && \
        PACKAGES="$PACKAGES task-cinnamon-desktop"
    fi

    DEBIAN_FRONTEND=noninteractive \
        apt install -y $PACKAGES $EXTRA_PACKAGES

    systemctl disable lightdm.service
    }

    function download_and_install { # args URL FILENAME
    curl -L -o "$2" "$1"
    dpkg --install "$2"
    apt install -y -f
    }

    function is_installed {  # args PACKAGE_NAME
    dpkg-query --list "$1" | grep -q "^ii" 2>/dev/null
    return $?
    }

    # Configure the following environmental variables as required:
    INSTALL_XFCE=yes
    INSTALL_CHROME=yes
    INSTALL_FULL_DESKTOP=yes

    ! is_installed chrome-remote-desktop && \
    download_and_install \
        https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb \
        /tmp/chrome-remote-desktop_current_amd64.deb

    install_desktop_env

    [[ "$INSTALL_CHROME" = "yes" ]] && \
    ! is_installed google-chrome-stable && \
    download_and_install \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
        /tmp/google-chrome-stable_current_amd64.deb

    echo "Chrome remote desktop installation completed"
    ```
1. Click 'create' at the bottom of the page to create the instance

## Step 2: Setup Chrome Remote Desktop Service
See [Configuring and starting the chrome remote desktop service](https://cloud.google.com/solutions/chrome-desktop-remote-on-compute-engine#configuring_and_starting_the_chrome_remote_desktop_service)

## Step 3: Improve the Desktop Experience
See [Improving the remote desktop experience](https://cloud.google.com/solutions/chrome-desktop-remote-on-compute-engine#improving_the_remote_desktop_experience)

## Step 4: Setup Git ssh
In the running machine instance setup Git ssh. See [Connecting to GitHub with SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh)

## Step 5: Create a Machine Image
Avoid repeating steps 1-4 the next time a development workstation needs to be set up by [Creating a machine image](https://cloud.google.com/compute/docs/machine-images/create-machine-images). Use the machine image as a base and create **actual/working** development instances/VMs from that.