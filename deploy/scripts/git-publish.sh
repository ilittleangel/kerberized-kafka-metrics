#!/usr/bin/env bash

repo=${1}

pushd "/tmp/${repo}"

UNTRACKED_FILES=`git ls-files . --exclude-standard --others | wc -l`
MODIFIED_FILES=`git diff | wc -l`
NUM_FILES=`expr ${MODIFIED_FILES} + ${UNTRACKED_FILES}`
COMMIT_MSG=$2
BRANCH=$3
TAG=$4

git status

if [[ ${NUM_FILES} -gt 0 ]] ; then

    # status
    echo "Files to synchronize:"
    git ls-files -m | sed -e 's/^/- /'
    git ls-files . --exclude-standard --others | sed -e 's/^/- /'

    # push commit
    git add --all
    git commit -m "${COMMIT_MSG}"
    git push origin ${BRANCH}

    # push tag
    if [[ "${BRANCH}" == "pro" ]] ; then
        echo "Tagging ..."
        git tag -a "${TAG}" -m "Tag ${TAG} release"
        git push origin ${TAG}
    fi

else

    echo "No files to synchronize"

fi

popd