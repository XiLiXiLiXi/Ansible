#!/bin/sh

message=
email=
subject=

# list of message status regex that should be ignored
ignore_msgs=(
)

until [ -z "$1" ]; do
	case "$1" in
		-m)
			shift
			message="$1"
			;;
		-s)
			shift
			subject="$1"
			;;
		-e)
			shift
			email="$1"
			;;
	esac
	shift
done

if [ -z "$message" -o -z "$email" -o -z "$subject" ]; then
        echo "Usage: $0 -m <email_message> -s <email_subject> -e <email>"
        exit 1
fi

# filter out erroneous messages from being sent
ignore_idx=0
ignore_count=${#ignore_msgs[*]}
while [ $ignore_idx -lt $ignore_count ]; do
        if [ -n "$(echo "$message" | grep -e "${ignore_msgs[$ignore_idx]}")" ]; then
                # going in here means the message should be ignored
                exit
        fi
        ignore_idx=$(( $ignore_idx + 1 ))
done

/usr/bin/printf "%b" "$message" | /bin/mail -s "$subject" $email
