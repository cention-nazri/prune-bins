#!/bin/sh
me=$(basename $0)

usage() {
    echo "Usage: $me <origin> <dir>

Clones git repository in <origin> to <dir>, and prunes
all tarballs in <dir>, and add reference to old commit"
}

while getopts h opt
do
  case "$opt" in
    h) usage ; exit;;
    \?) echo Unknown option ; exit;;
  esac
done
shift $(($OPTIND -1))

url=$1
dir=$2

if [ -z "$url" ]; then usage; exit 1; fi
if [ -z "$dir" ]; then usage; exit 1; fi

test -d "$dir" && { echo "Directory '$dir' already exist"; exit 1; }

git clone "$url" "$dir" &&
cd "$dir" &&
git filter-branch \
 --msg-filter '
	msg=`cat`
	echo "$msg"
	echo
	echo "cention/packages.git: $GIT_COMMIT"
	tarballs=$(git show --stat $GIT_COMMIT | sed -ne "/ | /p" | grep -E "tar.(gz|bz2)")
	test -n "$tarballs" && echo "Tarballs:"
	echo "$tarballs"
	exit 0
' --tree-filter 'rm *.gz *.bz2' master

echo "Now to slim down the new repo, do

git clone file:///path/to/pruned-repo pruned-repo-slim"
