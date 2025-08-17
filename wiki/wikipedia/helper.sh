#!/bin/sh

clr() { printf '\000message\037\n \000nonselectable\037true\037urgent\037true\n'; }
err_msg() {
    printf '\000message\037error: %s\n' "$1"
    clr
    exit 1
}

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"
[ -f "$SCRIPTPATH/helper" ] || err_msg "go helper not found"

C_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_wiki"
[ -d "$C_DIR" ] || {
    mkdir -p "$C_DIR" || err_msg "can't mkdir -p $C_DIR"
}

printf '\000use-hot-keys\037true\n'
printf '\000markup-rows\037true\n'
printf '\000keep-selection\037true\n'
if [ "$ROFI_DATA" = _history ] && [ $ROFI_RETV -ne 14 ]; then
    printf '\000new-selection\0370\n'
fi

banner() {
    printf 'search\000icon\037en_wiki\037info\037https://en.wikipedia.org/wiki/Special:Search\nua search\000icon\037uk_wiki\037info\037https://uk.wikipedia.org/wiki/Special:Search\n'
    exit 0
}

print_from_cache() {
    [ -f "$1" ] || err_msg 'no recent results found in cache'
    printf '\000message\037[Cache]\n'
    printf '\000data\037%s\n' "$1"
    printf '\000keep-filter\037true\n'
    awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); print}' "$1"
}

handle_query() {
    [ -n "$1" ] || exit 1
    query="$(printf '%s' "$1" | sed 's/\s/+/g')"
    results_cache="${C_DIR}/$(echo "$query" | base64)"
    [ -f "$results_cache" ] && {
        print_from_cache "$results_cache"
        return
    }
    printf '\000data\037%s\n' "$results_cache"
    "$SCRIPTPATH/helper" -q="$1" | tee -a "$results_cache"
}

print_history() {
    case $(find "$C_DIR" -maxdepth 1 -type f | wc -l) in
    0) printf '\000message\037history is empty\n\000urgent\0370\n \000nonselectable\037true\n' ;;
    *)
        [ -z "$1" ] && printf '\000new-selection\0370\n'
        printf '\000message\037history\n\000data\037_history\n'
        find "$C_DIR" -type f -printf '%T@ %f\n' | sort -k 1nr | sed 's/^[^ ]* //' | base64 -d | xargs -I {} printf '%s\n' "{}"
        ;;
    esac
}

case $ROFI_RETV in
# print banner on start and kb-custom-1
0 | 10) banner ;;
# select line
1)
    if [ "$ROFI_DATA" = _history ]; then
        handle_query "$@"
        exit 0
    fi
    case $ROFI_INFO in
    https://*.wikipedia.org/*) setsid -f "$BROWSER" "$ROFI_INFO" >/dev/null 2>&1 ;;
    *)
        printf "\000message\037invalid url '%s'\n" "$ROFI_INFO"
        banner
        ;;
    esac
    if [ -f "$ROFI_DATA" ]; then
        print_from_cache "$ROFI_DATA"
    fi
    ;;
# execute custom input
2) handle_query "$@" ;;
# kb-custom-2 - clear list rows
11)
    printf '\000message\037\n'
    clr
    ;;
# kb-custom-3 - remove cached result
12)
    [ -n "$ROFI_DATA" ] || banner
    [ -f "$ROFI_DATA" ] || banner
    subj="$(basename "$ROFI_DATA" | base64 -d)"
    [ -n "$subj" ] || banner
    rm -f "$ROFI_DATA" || banner
    handle_query "$subj"
    ;;
# kb-custom-4 - history
13)
    print_history
    ;;
# kb-custom-5 - delete history element
14)
    [ "$ROFI_DATA" = _history ] || banner

    query="$(printf '%s' "$1" | sed 's/\s/+/g')"
    results_cache="${C_DIR}/$(echo "$query" | base64)"
    if [ -f "$results_cache" ]; then
        rm -f "$results_cache"
    else
        printf '\000message\037file %s not found\n' "$results_cache"
    fi
    print_history keep-selection

    ;;
esac
