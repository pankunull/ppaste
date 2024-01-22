#!/bin/sh

# Written by: panku
#  Thanks to: o1, deesix, genunix

# Source code is hosted on : "https://www.genunix.com"
# Pastebin is hosted on    : "https://www.oetec.com/pastebin"


# -----------------------------------------------------------------------------


# global variables

_version=0.4.42
#_source='https://www.genunix.com/panku/pankupaste/ppaste.sh'
#_sha256='https://www.genunix.com/panku/pankupaste/sha256sum.txt'
_source='https://raw.githubusercontent.com/pankunull/ppaste/main/ppaste.sh'
_sha256='https://raw.githubusercontent.com/pankunull/ppaste/main/sha256sum.txt'
_width=120
_columns="$(stty size | cut -d ' ' -f2)"
_expiretime=0
_verbose=0
_links=""
_history=1
_name="$(basename "$0")"
_dir="$(dirname "$0")"
_historyfile=~/."$_name"/history
_downloaddir=~/."$_name"/download
_textflag=1
_maxsize=300000000
_pwcmd='curl --silent --connect-timeout 3 --max-time 10 --location'
_localhash="$(openssl sha256 -r "$_dir/$_name" | cut -d' ' -f1)"




# -----------------------------------------------------------------------------

# banner

if [ ! -e "$_historyfile" ]; then
    _history_print="No history file"
else
    _history_print="$_historyfile"
fi

if [ ! -e "$_downloaddir" ]; then
    _download_print="No download dir"
else
    _download_print="$_downloaddir"
fi



# horizontal split
split()
{
    printf -- ":%.0s" $(seq 1 $_columns)
    printf "\n\n"
}



# banner
printf """
          /-  $_name - $_version
PPASTE -- |-  $_history_print
          \-  $_download_print

$(split)

"""



# -----------------------------------------------------------------------------




# show_usage
#     Display usage information for this utility.
show_usage() 
{
    printf "Usage: %s [OUTPUT] [HISTORY] <file1> <file...> or [TEXT] <text> \n\n" "$_name"

    printf "OUTPUT                                                               \n"
    printf "  -f                  :Full mode (show html and plain links)         \n"
    printf "  -p                  :Plain mode (show plain links)                 \n"
    printf "  -d                  :Lined mode (show lined links)                 \n"
    printf "  -m                  :HTML mode (show html links)                 \n\n"

    printf "  -e  <1-7>           :Expiration date in days                       \n"
    printf "                          If this options is omitted the default     \n"
    printf "                          parameter is 4 hours.                    \n\n"

    printf "HISTORY                                                              \n"
    printf "  -s                  :Save session in history                     \n\n"

    printf "TEXT                                                                 \n"
    printf "  -t  \"text\"          :Paste text (in double quotes)               \n"
    printf "                          This function doesn't work with files or   \n"
    printf "                          multiple entries                           \n"

    printf "UTILITIES                                                            \n" 
    printf "  -l <format>         :Show links saved in history                   \n"
    printf "                          Formats: alive, dead, all                  \n"
    printf "  -L <format>         :Show table history with dates                 \n"
    printf "                          Formats: alive, dead, all                \n\n"

    printf "  -c  <url>           :Check expiration date                         \n"

    printf "  -D                  :Download alive links                        \n\n"

    printf "UPGRADE                                                              \n"
    printf "  -u                  :Upgrade                                       \n"
    printf "  -U                  :Force upgrade                               \n\n"

    printf "HELP                                                                 \n"
    printf "  -h                  :Show this help                              \n\n"

    printf "VERSION                                                              \n"
    printf "  -v                  :Show version                                \n\n"
   
    printf "EXAMPLES                                                             \n"
    printf " %s <file1> <file2>\n" "$_name"
    printf " %s -p -s -e 3 <file1> <file2>\n" "$_name"
    printf " %s -d -e 7 -t \"text\"\n" "$_name"
    printf " %s -l alive\n\n" "$_name"

    exit 0
}




# version
#     Display current version of the script
version()
{
    printf "Version: %s\n" "$_version"
    printf "%s\n\n" "$_localhash"
    exit 0
}




# upgrade
#     Check for newer version and upgrade
upgrade()
{
    # Check if source is reachable
    if ! _sourceversion="$($_pwcmd --url "$_source")"; then
        printf "ERROR: curl failed.\n"
        exit 1
    fi

    # Grab version
    _sourceversion="$(echo "$_sourceversion" |\
                      grep -m 1 "_version" |\
                      cut -d '=' -f2 )"

    # Check if the new version has been grabbed
    if [ -z "$_sourceversion" ]; then
        printf "ERROR: can't fetch version.\n"
        exit 1
    fi

    _sourcehash="$($_pwcmd --url $_sha256)"

    printf "Local version  : %s\n" "$_version"
    printf "%s\n\n" "$_localhash"
    printf "Latest version : %s\n" "$_sourceversion"
    printf "%s\n\n" "$_sourcehash"


    # if [ "$(echo "$VERSION_GRABBER > $PASTEBIN_VERSION" | bc -l)" -eq 1 ]; then
    #       ^ this is the old method using bc

    #if [ "$(echo "$_sourceversion" | tr -d '.')" -le \
    #     "$(echo "$_version" | tr -d '.')" ]; then
    #
    #    printf "Up-to-date\n"
    #    exit 0
    #fi

    # new method using grep + regex
    if printf '%s\n' $_version $_sourceversion | \
                     sort --version-sort --check &>/dev/null; then
        
        printf "Up-to-date\n\n"
        
        if [ "$_sourcehash" != "$_localhash" ]; then
            printf "WARNING: version is up-to-date but the hash doesn't match.\n"
            printf "\t You are using a modified version of the script.\n\n"
        fi
        
        exit 0
    fi
    

    printf "Do you want to upgrade? [y/N]: "
    read -r _choice

    case "$_choice" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            printf "Aborting.\n"
            exit 0;;
    esac

    # Upgrade 
    if ! $_pwcmd --url "$_source" \
                 --output /tmp/"$_name".new; then
        printf "ERROR: curl failed.\n"
        exit 1
    fi
    
    printf "\nFile downloaded to: %s\n" "$(ls /tmp/"$_name".new)"

    printf "Do you want to overwrite the current script? [y/N]: "
    
    read -r _choice

    case "$_choice" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            printf "Aborting.\n"
            exit 0;;
    esac
    
    mv -v "$0" "$0".old
    mv -v /tmp/"$_name".new "$_dir/$_name"
    chmod -v +x "$_dir/$_name"
    rm -v "$0".old

    printf "\nDone!\n\n"

    exit 0
}




# force upgrade
#     straight upgrade without checking
force_upgrade()
{
    # Check if source is reachable
    if ! _sourceversion="$($_pwcmd --url "$_source")"; then
        printf "ERROR: curl failed.\n"
        exit 1
    fi

    printf "Do you want to upgrade? [y/N]: "
    read -r _choice

    case "$_choice" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            printf "Aborting.\n"
            exit 0;;
    esac


    # Upgrade 
    if ! $_pwcmd --url "$_source" \
                 --output /tmp/"$_name".new; then
        printf "ERROR: curl failed.\n"
        exit 1
    fi


    printf "\nFile downloaded to: %s\n" "$(ls /tmp/"$_name".new)"
    

    printf "Do you want to overwrite the current script? [y/N]: "
    read -r _choice


    case "$_choice" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            printf "Aborting.\n"
            exit 0;;
    esac


    mv -v "$0" "$0".old
    mv -v /tmp/"$_name".new "$_dir/$_name"
    chmod -v +x "$_dir/$_name"
    rm -v "$0".old

    printf "\nDone!\n\n"

    exit 0
}




# show_history
#     Display history of all pastebin saved
show_history()
{
    if [ ! -f "$_historyfile" ]; then
        printf "ERROR: history file doesn't exist.\n"
        exit 1
    fi

    printf "Grabbing history from '%s'\n\n" "$_historyfile"

    case "$OPTARG" in
        alive)
            _historylinks="$(awk -F\, '$2 > '"$(date +%s)"'' "$_historyfile")"
            ;;
        dead)  
            _historylinks="$(awk -F\, '$2 < '"$(date +%s)"'' "$_historyfile")"
            ;;
        all)
            _historylinks="$(cat "$_historyfile")"
            ;;
        *)
            printf "ERROR: bad argument.\n"
            exit 1
        ;;
    esac

    if [ -z "$_historylinks" ]; then
        printf "No history found.\n\n"
    else
        split
        printf "%s\n\n" "$(echo "$_historylinks" | cut -d ',' -f1)"
    fi

    exit 0
}




# show_history_full
#     Display history of all pastebin saved
show_history_full()
{
    if [ ! -f "$_historyfile" ]; then
        printf "ERROR: history file doesn't exist.\n"
        exit 1
    fi

    printf "Grabbing history from '%s'\n\n" "$_historyfile"

    case "$OPTARG" in
        alive)
            _historylinks="$(awk -F\, '$2 > '"$(date +%s)"'' "$_historyfile")"
            ;;
        dead)  
            _historylinks="$(awk -F\, '$2 < '"$(date +%s)"'' "$_historyfile")"
            ;;
        all)
            _historylinks="$(cat "$_historyfile")"
            ;;
        *)
            printf "ERROR: bad argument.\n"
            exit 1
        ;;
    esac

    if [ -z "$_historylinks" ]; then
        printf "No history found.\n\n"
    else
        split

        printf -- "-%.0s" $(seq 1 107) ; printf "\n"
        
        printf "%25s %21s %18s %11s %18s\n" "Link" "|" "Created on" "|" "Expires on"

        printf -- "-%.0s" $(seq 1 107) ; printf "\n"
        
        while read _LINE; do
            _LLINK="$(printf "$_LINE" | cut -d ',' -f1)"
            _LEXPIRE="$(date -d @$(printf "$_LINE" | cut -d ',' -f2))"
            _LCREATED="$(date -d @$(printf "$_LINE" | cut -d ',' -f3))"
            
            printf "%s | %s | %s\n" "$_LLINK" "$_LCREATED" "$_LEXPIRE"
        done < "$_historyfile"
    fi
    
    printf "\n"

    exit 0
}




# check_lifetime
#     Display expiration time
check_lifetime()
{
    # Grab headers from the link
    if ! _headers="$($_pwcmd -s -I "$OPTARG")"; then
        printf "ERROR: Curl failed.\n"
        exit 1
    fi

    # Check if the link is valid 
    # and the headers contain the expiration time
    if ! echo "$_headers" | grep "Expires: " 1>/dev/null; then
        printf "ERROR: not a valid link.\n"
        exit 1
    fi

    # Parse all information
    _headers="$(echo "$_headers" | tr -d '\r')"

    _borndate="$(echo "$_headers" | grep "Date: " | cut -d ' ' -f3-6 | tr -d ',')" 
    _expiredate="$(echo "$_headers" | grep "Expires: " | cut -d ' ' -f3-6 | tr -d ',')"

    _bornsec="$(date -d "$_borndate" +%s 2>/dev/null || \
                date -j -f %d%b%Y%H%M%S "$(echo "$_borndate" | tr -d ' :')" +%s)"

    _expiresec="$(date -d "$_expiredate" +%s 2>/dev/null || \
                  date -j -f %d%b%Y%H%M%S  "$(echo "$_expiredate" | tr -d ' :')" +%s)"

    _difference=$(( _expiresec - _bornsec ))

    printf "Created: %s\n" "$_borndate"
    printf "Expires: %s\n" "$_expiredate"

    printf "Timer  : %sd %sh %sm %ss\n\n" \
        "$((  _difference / 86400))" \
        "$(( (_difference % 86400) / 3600))" \
        "$(( (_difference % 3600) / 60))" \
        "$((  _difference % 60))"

    exit 0
}



# download
#    Download alive history
download()
{
    
    if [ ! -f "$_historyfile" ]; then
        printf "ERROR: history file doesn't exist.\n"
        exit 1
    fi

    printf "Grabbing history from '%s'\n" "$_historyfile"

    _historylinks="$(awk -F\, '$2 < '"$(date +%s)"'' "$_historyfile")"

    if [ -z "$_historylinks" ]; then
        printf "No history found.\n\n"
        exit 0
    fi
    
    _historylinks="$(echo "$_historylinks" | cut -d ',' -f1)"

    
    if [ ! -d "$_downloaddir" ]; then
        printf "Creating download folder in $_downloaddir\n"

        if mkdir -v -p "$_downloaddir" 2>/dev/null; then
            printf "ERROR: can't create the download folder.\n"
            exit 1
        fi
    fi

    printf "Downloading files in: '%s'\n\n" "$_downloaddir"

    split

    for _link in $_historylinks; do
        printf "Downloading -> %s\n" "$_link"

        curl --progress-bar -4 --max-time 60 --connect-timeout 5 -L --url "$_link" -O --output-dir $_downloaddir

        printf "\n" ; split
    done

    exit 0
}




# lifetime
#     Expiration time for the pastebin
lifetime()
{
    # Check if expiration time:
    # - exist
    # - is a positive integer number
    # - is between 1 and 7

    if [ "$OPTARG" -ge 0 ] 2>/dev/null || [ "$OPTARG" -lt 0 ] 2>/dev/null; then
        if [ "$OPTARG" -gt 0 ] && [ "$OPTARG" -lt 8 ]; then
            _expiretime="$OPTARG"
        else
            printf "ERROR: hours must be between 1 and 7.\n"
            exit 1
        fi
    else
        printf "ERROR: hours must be a positive integer.\n"
        exit 1
    fi
}




# save_pastebin
#     Save pastebin link to file
save_pastebin()
{
    _history=0

    if [ ! -f "$_historyfile" ]; then
        if mkdir -p ~/."$_name"; then
            if touch "$_historyfile"; then
                printf "History file '%s' created.\n" "$_historyfile"
            else
                printf "ERROR: failed to create history file.\n"
                exit 1
            fi
        else
            printf "ERROR: failed to create folder.\n"
            exit 1

        fi
    fi
    
    printf "Session saved in: %s\n\n" "$_historyfile"
    split
}





# -----------------------------------------------------------------------------




# Process arguments
#
while getopts 'hvut:l:L:c:o:Dfpdme:s' _option; do
    case "$_option" in
        h) 
            show_usage
            ;;

        v)
            version
            ;;

        u)
            upgrade
            ;;

        t)
            _textpaste="$OPTARG"
            _textflag=0
            ;;

        l)
            show_history
            ;;
        L)
            show_history_full
            ;;

        c)
            check_lifetime
            ;;
        D)
            download
            ;;

        f) 
            _verbose=1 
            ;;

        p) 
            _verbose=2
            ;;

        m)
            _verbose=3 
            ;;

        d) 
            _verbose=4
            ;;

        e)
            lifetime
            ;;

        s)
            save_pastebin
            ;;

        *)
            printf "%s: try '-h' for more information.\n\n" "$(basename "$0")"
            exit 1
            ;;
    esac
done




# -----------------------------------------------------------------------------



# Shift arguments when getopt is done
shift $((OPTIND-1))


# Check if there are no OPTIONS or ARGUMENTS
if [ $OPTIND -eq 1 ] && [ $# -eq 0 ]; then 
    printf "%s: try '-h' option for more information.\n\n" "$(basename "$0")"
    exit 1
fi


# Check if no ARGUMENTS are passed when OPTIONS are given
if [ "$_textflag" -eq 1 ]; then
    if [ $OPTIND -gt 1 ] && [ $# -eq 0 ]; then
        printf "ERROR: no file given.\n"
        exit 1
    else
        _args="$*"
    fi
else
    _args="$_textpaste"
fi



# -----------------------------------------------------------------------------


# Looping through files
for _file in $_args; do
    # Check if:
    # - file exist
    # - is not empty
    # - is not larger than 3000000000 (300MB)

    # File checking
    if [ -n "$_textpaste" ]; then
        _content="paste=$_textpaste"
    else
        if [ -f "$_file" ]; then
            if [ -s "$_file" ]; then
                if [ "$(wc -c < "$_file")" -gt "$_maxsize" ]; then
                    printf  "ERROR: %s is exceeding 300MB.\n\n" "$(basename "$_file")"
                    split
                else
                    _content="pastefile=@$_file"
                fi
            else
                printf "ERROR: %s is empty.\n\n" "$_file"
                split
            fi    
        else
            printf "ERROR: '%s' is not a valid file.\n\n" "$_file"
            split
        fi
    fi

            

    # Content parsing
    if [ -n "$_content" ]; then
        # Sending output
        printf "Sending -> " 

        if [ "$_textflag" -eq 0 ]; then
            printf "%s\n" "$_textpaste"    
        else
            printf "%s\n" "$(basename "$_file")"
        fi


        # Expiration time output
        if [ "$_expiretime" -eq 0 ]; then
            printf "Paste expires in 4h"
            printf " (%s)\n\n" "$(date -u -d "+4 hours" +'%H:%M:%S - %d/%B/%Y' 2>/dev/null || \
                                  date -u -v "+4H"      +'%H:%M:%S - %d/%B/%Y')" 
        else
            printf "Paste expires in %sd" "$_expiretime"
            printf " (%s)\n\n" "$(date -u -d "+${_expiretime} days" +'%H:%M:%S - %d/%B/%Y' 2>/dev/null || \
                                  date -u -v "+${_expiretime}d"     +'%H:%M:%S - %d/%B/%Y')"
        fi


        # Curl the file
        if _data="$(curl                                           \
                   --progress-bar                                  \
                   --output - -#                                   \
                   --max-time 10                                   \
                   --connect-timeout 5                             \
                   --form                     post=pastebin        \
                   --form                     plain=true           \
                   --form                     "days=$_expiretime"  \
                   --form                     "$_content"          \
                   https://www.oetec.com/post                      \
                   )"; then

            # Check 404 from website
            if echo "$_data" | grep "404" 1>/dev/null; then
                printf "ERROR: 404 - page not found.\n\n"
                exit 1
            fi
     
            # Check if server return POST variables error
            if echo "$_data" | grep -i "fail" 1>/dev/null; then
                printf "ERROR: POST failed, check variables.\n\n"
                exit 1
            fi

            printf "\nHash: %s\n\n" "$(echo "$_data" | \
                                       sed '1p;d' | \
                                       rev | \
                                       cut -d '/' -f1 | \
                                       rev)"

            # Verbose output
            # 0 - default output
            # 1 - full
            # 2 - plain
            # 3 - html
            # 4 - lined
            case $_verbose in
                0)
                    printf "%s\n" "$(echo "$_data" | sed '1p;d')"
                    printf "%s\n" "$(echo "$_data" | sed '2p;d')"
                    printf "%s\n\n" "$(echo "$_data" | sed '3p;d')" ;;
                1)
                    _links="$_links $(echo "$_data" | sed '1p;d')"
                    _links="$_links $(echo "$_data" | sed '2p;d')";
                    _links="$_links $(echo "$_data" | sed '3p;d')" ;;
                2)
                    _links="$_links $(echo "$_data" | sed '2p;d')" ;;
                3)
                    _links="$_links $(echo "$_data" | sed '1p;d')" ;;
                4)
                    _links="$_links $(echo "$_data" | sed '3p;d')" ;;
            esac
            
            # History save
            if [ "$_history" -eq 0 ]; then
                if [ "$_expiretime" -eq 0 ]; then
                    _expireflag=4
                fi

                {
                    printf "%s," "$(echo "$_data" | sed '2p;d')"
                    printf "%s," "$(date -u -d "+${_expireflag} hours" +'%s' 2>/dev/null || \
                                    date -u -v "+${_expireflag}H"      +'%s')"
                    printf "%s\n" "$(date "+%s" 2>/dev/null || \
                                     date "+%s")"
                } >> "$_historyfile" 
            fi
     
        else
            printf "ERROR: curl failed.\n\n"
        fi

        split

    fi  


    _content=''
        

    if [ -n "$_textpaste" ]; then
        break
    fi
done



# When all files are uploaded print links
if [ -n "$_links" ]; then
    printf "Links: \n\n"

    for _line in $_links; do
        printf "%s\n" "$_line"
    done
    echo
fi

