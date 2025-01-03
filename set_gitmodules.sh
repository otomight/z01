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

get() {
	local	arg

	arg="$1"
	if [ "$arg" = "$ARG_GITEA" ]; then
		cat $GITEA_GITMODULES_FILE > $GITMODULES_FILE
	elif [ "$arg" = "$ARG_GITHUB" ]; then
		cat $GITHUB_GITMODULES_FILE > $GITMODULES_FILE
	else
		send_arg_help
	fi
}

argsHandler "$@"
