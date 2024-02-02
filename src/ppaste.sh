#!/bin/sh

# Written by: panku
# Thanks to: o1, deesix, genunix

# Source code is hosted on : "https://www.github.com/pankunull/ppaste"
# Pastebin is hosted on    : "https://www.oetec.com/pastebin"

# POSIX


# -----------------------------------------------------------------------------

# global variables

_version=0.4.53
_source='https://raw.githubusercontent.com/pankunull/ppaste/main/src/ppaste.sh'
_sha256='https://raw.githubusercontent.com/pankunull/ppaste/main/sign/sha256sum.txt'
_pastebin="https://www.oetec.com/pastebin"

_width=120
_columns="$(stty size | cut -d ' ' -f2)"
_alignwidth=-15

_maxsize=300000000
_pwcmd='curl --silent --connect-timeout 5  --location'

_expiretime=0
_verbose=0
_verbosemode='None'
_links=""
_history=1

_name="$(basename "$0")"
_dir="$(dirname "$0")"

_historyfile=~/"$_name"/history
_historyfile_table=~/"$_name"/history_table
_downloaddir=~/"$_name"/download

_localhash="$(sha256sum "$_dir"/"$_name" | cut -d ' ' -f1)"





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
    printf -- "-%.0s" $(seq 1 "$_columns")
    printf "\n\n"
}


printf "\n           /-  %s - %s" "$_name" "$_version"
printf "\nPPASTE -- |-   %s" 	  "$_history_print"
printf "\n           \-  %s\n\n"  "$_download_print"
printf "%s\n\n" "$(split)"




# -----------------------------------------------------------------------------

# show_usage
#     Display usage information for this utility.
show_usage() 
{
    printf "Usage: %s [OUTPUT] [HISTORY] [LIFETIME] <file1> <file...>\n\n" "$_name"

    printf "Output:                                                               \n"
    printf "  -f                  : All (normal, lined, plain)                    \n"
    printf "  -p                  : Plain                                         \n"
    printf "  -d                  : Lined                                         \n"
    printf "  -m                  : Normal                                      \n\n"

    printf "History:                                                              \n"
    printf "  -s                  : Save session in history                       \n"
    printf "  -r                  : Delete history                                \n"   
    printf "  -R                  : Delete download                             \n\n"   
    
    printf "Lifetime:                                                             \n"
    printf "  -e  <1-7>           : Expiration date in days                       \n"
    printf "                        If this options is omitted the default        \n"
    printf "                        parameter is 4 hours.                       \n\n"

    printf "Utilities:                                                            \n" 
    printf "  -l <format>         : Show history (alive, dead, full)              \n"
    printf "  -L <format>         : Show formatted history (alive ,dead, full)    \n"

    printf "  -c <url>            : Check expiration date                         \n"

    printf "  -D                  : Download alive links                        \n\n"

    printf "Miscellaneous:                                                        \n"
    printf "  -u                  : Upgrade                                       \n"
    printf "  -U                  : Force upgrade                                 \n"
    printf "  -h                  : Show this help                                \n"
    printf "  -v                  : Show version                                \n\n"
   
    printf "Examples:                                                             \n"
    printf " %s <file1> <file2>\n" "$_name"
    printf " %s -p -e 3 -s <file1> <file2>\n" "$_name"
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

    _sourcehash="$($_pwcmd --url $_sha256 | cut -d ' ' -f1)"

    printf "Local version  : %s\n" "$_version"
    printf "%s\n\n" "$_localhash"
    printf "Latest version : %s\n" "$_sourceversion"
    printf "%s\n\n" "$_sourcehash"


    # Check version 
    if [ "$(echo "$_version" | tr -d '.')" -eq \
         "$(echo "$_sourceversion" | tr -d '.')" ]; then
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
        printf "%s\n\n" "$(echo "$_historylinks" | cut -d '|' -f1)"
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
            _historylinks="$(awk -F\, '$3 < '"$(date +%s)"'' "$_historyfile")"
            ;;
        dead)  
            _historylinks="$(awk -F\, '$3 > '"$(date +%s)"'' "$_historyfile")"
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

        _minus=104
        _minus="$_columns"

        # Table's header
        {
            printf -- "-%.0s" $(seq 1 "$_minus")
            printf "\n"
            printf "%22s %17s %18s %9s %18s %9s %s %s %s\n" \
                "Link" "|" "Created on" "|" "Expires on" "|" "Lifetime" "|" "Filename"
            printf -- "-%.0s" $(seq 1 "$_minus") 
            printf "\n" 
        } > "$_historyfile_table"
        
        #awk -F , '{$2=""; print $0}' OFS=',' "$_historyfile" | \
        awk 'BEGIN {FS=OFS="|";}
                   {$2 = strftime("%c %Z", $2); $3 = strftime("%c %Z", $3); } 
                   {print}' "$_historyfile" | \
        awk -F '|' '{ if ($4 == "1")    $4="1 day     "  }1' OFS='|' | \
        awk -F '|' '{ if (int($4) > 1 ) $4=$4" days    " }1' OFS='|' | \
        awk -F '|' '{ if ($4 == "0")    $4="4 hours   "  }1' OFS='|' >> "$_historyfile_table"
        #awk -F,  'BEGIN {FS=",";OFS=","} 
        #                {print $1,substr($2,1,15),$3,$4,$5}' >> "$_historyfile_table"  
       
        sed -i -e 's/|/ | /g' "$_historyfile_table"
        
        printf -- "-%.0s" $(seq 1 "$_minus") >> "$_historyfile_table"

        printf "\n" >> "$_historyfile_table"

        cat "$_historyfile_table"
        
    fi
    
    printf "\n"

    exit 0
}




# delete_history
#     Delete history
delete_history()
{
    if [ ! -f "$_historyfile" ]; then
        printf "No history file found.\n\n"
        exit 0
    fi

    printf "Are you sure you want to delete the history? [y/N]: "
    
    read -r _choice

    case "$_choice" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            printf "Aborting.\n"
            exit 0;;
    esac

    rm -v "$_historyfile"
    #rm -v "$_historyfile_table"
    
    exit 0
}




# delete_history
#     Delete history
delete_download()
{
    if [ ! -d "$_downloaddir" ]; then
        printf "No download folder found.\n\n"
        exit 0
    fi

    printf "Are you sure you want to delete the download folder? [y/N]: "
    
    read -r _choice

    case "$_choice" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            printf "Aborting.\n"
            exit 0;;
    esac

    rm -v -r "$_downloaddir"
    
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
    _hash="$(echo "$OPTARG" | rev | cut -d '/' -f1 | rev)"

    _type="$(echo "$_headers" | grep "Type: " | cut -d ' ' -f2-)" 

    _headers="$(echo "$_headers" | tr -d '\r')"

    _borndate="$(echo "$_headers" | grep "Date: " | cut -d ' ' -f2-)" 
    _expiredate="$(echo "$_headers" | grep "Expires: " | cut -d ' ' -f2-)"

    _bornsec="$(date -d "$_borndate" +%s 2>/dev/null || \
                date -j -f %d%b%Y%H%M%S "$(echo "$_borndate" | tr -d ' :')" +%s)"

    _expiresec="$(date -d "$_expiredate" +%s 2>/dev/null || \
                  date -j -f %d%b%Y%H%M%S  "$(echo "$_expiredate" | tr -d ' :')" +%s)"

    _difference=$(( _expiresec - _bornsec ))

    printf "%${_alignwidth}s : %s\n" "Hash" "$_hash"
    printf "%${_alignwidth}s : %s\n" "Type" "$_type"
    printf "%${_alignwidth}s : %s\n" "Created" "$_borndate"
    printf "%${_alignwidth}s : %s\n" "Epires" "$_expiredate"

    printf "%${_alignwidth}s : %sd %sh %sm %ss\n\n" \
        "Timer" \
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

    printf "Grabbing history from '%s'\n\n" "$_historyfile"

    _historydownload="$(awk -F\, '$2 < '"$(date +%s)"'' "$_historyfile")"

    if [ -z "$_historydownload" ]; then
        printf "No history found.\n\n"
        exit 0
    fi
   
    if [ ! -d "$_downloaddir" ]; then
        printf "Creating download folder in %s\n\n" "$_downloaddir"

        if ! mkdir -v -p "$_downloaddir" 2>&1; then
            printf "ERROR: can't create the download folder.\n"
            exit 1
        fi

    fi

    printf "If the file is already in the folder it won't be downloaded.\n\n"
    printf "There are %s entries in the history, continue? [y/N]: " "$(wc -l "$_historyfile" | cut -d ' ' -f1)"
    
    read -r _choice

    case "$_choice" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            printf "Aborting.\n"
            exit 0;;
    esac

    printf "\n" ; split

    for _link in $_historydownload; do
        _downloadhash="$(echo "$_link" | cut -d '|' -f1 | rev | cut -d '/' -f1 | rev)"
        _downloadname="$(echo "$_link" | rev | cut -d '|' -f1 | rev)"
        _link="$_pastebin/plain/$_downloadhash"

        if [ ! -f "$_downloaddir"/"$_downloadhash.$_downloadname" ]; then
            printf "%${_alignwidth}s : %s\n" "Downloading" "$_downloadhash.$_downloadname"
            
            COLUMNS=63 curl --progress-bar -# -L --url "$_link" -o "$_downloadhash.$_downloadname" --output-dir "$_downloaddir"

            printf "\n" ; split
        fi
    done

    printf "Finished! -> %s\n\n" "$_downloaddir"

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
        if mkdir -p ~/"$_name"; then
            if touch "$_historyfile"; then
                printf "History file '%s' created.\n\n" "$_historyfile"
                split
            else
                printf "ERROR: failed to create history file.\n"
                exit 1
            fi
        else
            printf "ERROR: failed to create folder.\n"
            exit 1

        fi
    fi
    
    printf "Saving session in: %s\n\n" "$_historyfile"
    split
}





# -----------------------------------------------------------------------------




# Process arguments
#
while getopts 'hvrRuU:l:L:c:o:Dfpdme:s' _option; do
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
        U)
            force_upgrade
            ;;

        l)
            show_history
            ;;
        L)
            show_history_full
            ;;
        r)
            delete_history
            ;;
        R)
            delete_download
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
if [ $OPTIND -gt 1 ] && [ $# -eq 0 ]; then
    printf "ERROR: no file given.\n"
    exit 1
fi



# -----------------------------------------------------------------------------



# Looping through files
for _file in "$@"; do
    # Check if:
    # - file exist
    # - is not empty
    # - is not larger than 3000000000 (300MB)

    # File checking
    if [ -f "$_file" ]; then
        if [ -s "$_file" ]; then
            if [ "$(wc -c < "$_file")" -gt "$_maxsize" ]; then
                printf  "ERROR: %s is exceeding 300MB.\n\n" "$(basename "$_file")"
                split
            else
                _content=pastefile=@"$_file"
            fi
        else
            printf "ERROR: %s is empty.\n\n" "$_file"
            split
        fi    
    else
        printf "ERROR: '%s' is not a valid file.\n\n" "$_file"
        split
    fi

            

    # Content parsing
    if [ -n "$_content" ]; then
        
        # Filename
        printf "%${_alignwidth}s : %s\n" "Sending" "$(basename "$_file")"
        
        # Curl the file
        if _data="$(COLUMNS=63 curl                                \
                   --progress-bar                                  \
                   --output - -#                                   \
                   --connect-timeout 5                             \
                   --form                     post=pastebin        \
                   --form                     plain=true           \
                   --form                     "days=$_expiretime"  \
                   --form                     "$_content"          \
                   https://www.oetec.com/post                      \
                   )"; then


        # Curl the file
        #if _data="$(curl                                           \
        #           --connect-timeout 5                             \
        #           --form                     post=pastebin        \
        #           --form                     plain=true           \
        #           --form                     "days=$_expiretime"  \
        #           --form                     "$_content"          \
        #           https://www.oetec.com/post                      \
        #           )"; then


            # Check if server is returning 404
            if echo "$_data" | grep "404" 1>/dev/null; then
                printf "ERROR: 404 - page not found.\n\n"
                exit 1
            fi
     
            # POST check
            if echo "$_data" | grep -i "fail" 1>/dev/null; then
                printf "ERROR: POST failed, check variables.\n\n"
                exit 1
            fi


            # Created on
            printf "%${_alignwidth}s : %s\n" "Created on" "$(date)"


            # Expires on
            if [ "$_expiretime" -eq 0 ]; then
                printf "%${_alignwidth}s : %s\n" "Expires on" "$(date -d "+4 hours" 2>/dev/null || \
                                                                 date -v "+4H")" 
                printf "%${_alignwidth}s : %s\n" "Lifetime" "4 hours"
            else
                printf "%${_alignwidth}s : %s\n" "Expires on" "$(date -d "+${_expiretime} days" 2>/dev/null || \
                                                                 date -v "+${_expiretime}d")"
                if [ "$_expiretime" -eq 1 ]; then
                    printf "%${_alignwidth}s : %s\n" "Lifetime" "$_expiretime day"
                else
                    printf "%${_alignwidth}s : %s\n" "Lifetime" "$_expiretime days"
                fi
            fi
            

            # Hash print
            printf "%${_alignwidth}s : %s\n" "Hash" "$(echo "$_data" | \
                                                        sed '1p;d' | \
                                                        rev | \
                                                        cut -d '/' -f1 | \
                                                        rev)"
    
            # Links print
	        printf "%${_alignwidth}s : %s\n" "Normal" "$(echo "$_data" | sed '1p;d')"
	        printf "%${_alignwidth}s : %s\n" "Lined" "$(echo "$_data" | sed '2p;d')"
            printf "%${_alignwidth}s : %s\n\n" "Plain" "$(echo "$_data" | sed '3p;d')"


            # Verbose output
            # 1 - full
            # 2 - plain
            # 3 - html
            # 4 - lined
            case $_verbose in
                1)
                    _verbosemode='Html, Lined, Plain';
                    _links="$_links $(echo "$_data" | sed '1p;d')";
                    _links="$_links $(echo "$_data" | sed '2p;d')";
                    _links="$_links $(echo "$_data" | sed '3p;d')" ;;
                2)
                    _verbosemode='Plain';
                    _links="$_links $(echo "$_data" | sed '3p;d')" ;;
                3)
                    _verbosemode='HTML';
                    _links="$_links $(echo "$_data" | sed '1p;d')" ;;
                4)
                    _verbosemode='Lined';
                    _links="$_links $(echo "$_data" | sed '2p;d')" ;;
            esac


            # History save
            if [ "$_history" -eq 0 ]; then

                {
                    # Link
                    printf "%s|" "$(echo "$_data" | sed '1p;d')"


                    # Create time in epoch
                    printf "%s|" "$(date --utc '+%s' 2>/dev/null || \
                                    date --utc '+%s')"

                    if [ "$_expiretime" -eq 0 ]; then
                        printf "%s|" "$(date --utc '+%s' -d "+4 hours" 2>/dev/null || \
                                        date --utc '+%s' -v "+4H")"
                    else
                        printf "%s|" "$(date --utc '+%s' -d "+${_expiretime} days" 2>/dev/null || \
                                        date --utc '+%s' -v "+${_expiretime}d")"
                    fi
                    
                    # Time flag
                    printf "%s|" "$_expiretime"

                    # Filename
                    printf "%s\n" "$(basename "$_file")"

                } >> "$_historyfile" 
            fi
     
        else
            printf "ERROR: curl failed.\n\n"
        fi

        split

    fi  


    _content=''

done



# When all files are uploaded print links
if [ "$_verbose" -gt 0 ] && [ -n "$_links" ]; then
    printf "Links: %s\n\n" "$_verbosemode"

    for _line in $_links; do
        printf "%s\n" "$_line"
    done
    echo
fi

