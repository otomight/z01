#!/bin/bash

WRITE_CMD="write"
GET_CMD="get"

ARG_GITEA="gitea"
ARG_GITHUB="github"

CUSTOM_MODULES_DIR=".custom.gitmodules"

GITMODULES_FILE=".gitmodules"
GITEA_GITMODULES_FILE="$CUSTOM_MODULES_DIR/gitea.gitmodules"
GITHUB_GITMODULES_FILE="$CUSTOM_MODULES_DIR/github.gitmodules"

send_arg_help() {
	echo "Wrong argument, please use $ARG_GITEA or $ARG_GITHUB with your command."
}

argsHandler() {
	local	command
	local	file

	command="$1"
	file="$2"
	case "$command" in
	"$WRITE_CMD")
		write "$file"
		return 1
		;;
	"$GET_CMD")
		get "$file"
		return 1
		;;
	*)
		echo "Command not found, please user $WRITE_CMD or $GET_CMD with the right arg."
		return 1
		;;
	esac
	return 0
}

write() {
	local	arg

	arg="$1"
	if [ "$arg" = "$ARG_GITEA" ]; then
		cat $GITMODULES_FILE > $GITEA_GITMODULES_FILE
	elif [ "$arg" = "$ARG_GITHUB" ]; then
		cat $GITMODULES_FILE > $GITHUB_GITMODULES_FILE
	else
		send_arg_help
	fi
}

add_submodules() {
	local	submodule_path
	local	submodule_url

	if [ ! -f "$GITMODULES_FILE" ]; then
		echo "Error : $GITMODULES_FILE not found."
		exit 1
	fi
	while IFS= read -r line; do
		submodule_path=$(echo $line | awk '{print $3}')
		submodule_url=$(git config --file "$GITMODULES_FILE" submodule."$submodule_path".url)
		echo "add submodule $submodule_path with url $submodule_url"
		git submodule add "$submodule_url" "$submodule_path"
	done < <(grep 'path =' "$GITMODULES_FILE")
	git submodule sync --recursive
	git submodule update --init --recursive
}

get() {
	local	arg
	local	module_path

	# remove all index of the cache
	for module_path in $(git config --file .gitmodules --get-regexp path | awk '{print $2}'); do
		git rm --cached "$module_path"
	done
	arg="$1"
	if [ "$arg" = "$ARG_GITEA" ]; then
		cat $GITEA_GITMODULES_FILE > $GITMODULES_FILE
	elif [ "$arg" = "$ARG_GITHUB" ]; then
		cat $GITHUB_GITMODULES_FILE > $GITMODULES_FILE
	else
		send_arg_help
	fi
	rm -rf .git/modules/*
	add_submodules
}

argsHandler "$@"
