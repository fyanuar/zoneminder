#### Set Timezone ####

    TZ="Asia/Jakarta"       # Timezone

#### Database ####

    INSTALL_DB="true"       # 0/false/no if you are using remote database, default is "true" or not set and DB_HOST will be localhost.
    DB_HOST="192.168.2.254" # This env will be skip if INSTALL_DB=true
    DB_USER="zmuser"
    DB_PASS="zmpass"
    DB_NAME="zm"

#### Multi-Server Zoneminder. Do NOT set ZM_SERVER_HOST if you are not using Multi-Server ####

    ZM_SERVER_HOST="cctv1"  # The name specified here must have a corresponding entry in the Servers tab under Options

#### zmeventnotification ###

    INSTALL_ZMES="true"     # Whether to install Event Server or not.
    INSTALL_HOOK="yes"      # Install hooks if "true".
    INSTALL_MODEL=1         # Download models if "true".
