#!/bin/sh

clr() { printf '\000message\037\n \000nonselectable\037true\037urgent\037true\n'; }
err_msg() {
    printf '\000message\037error: %s\n \000nonselectable\037true\037urgent\037true\n' "$1"
    exit 1
}

C_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_wiki"
if [ ! -d "$C_DIR" ]; then
    mkdir -p "$C_DIR" || err_msg "can't mkdir -p $C_DIR"
fi

printf '\000use-hot-keys\037true\n'
printf '\000markup-rows\037true\n'
printf '\000keep-selection\037true\n'
if [ "$ROFI_DATA" = _history ] && [ $ROFI_RETV -ne 14 ]; then
    printf '\000new-selection\0370\n'
fi

banner() {
    printf '\000message\037\n
search\000icon\037en_wiki\037info\037https://en.wikipedia.org/wiki/Special:Search\n
ua search\000icon\037uk_wiki\037info\037https://uk.wikipedia.org/wiki/Special:Search\n'
    exit 0
}

print_from_cache() {
    [ -f "$1" ] || err_msg 'no recent results found in cache'
    printf '\000message\037[Cache]\n'
    printf '\000data\037%s\n' "$1"
    awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); print}' "$1"
}

handle_query() {
    [ -n "$1" ] || exit 1
    results_cache="${C_DIR}/$(echo "$1" | base64)"
    if [ -f "$results_cache" ] && [ "$(wc -c <"$results_cache")" != 0 ]; then
        print_from_cache "$results_cache"
    else
        printf '\000data\037%s\n' "$results_cache"
        "$GO_HELPER" -q="$1" | tee -a "$results_cache"
    fi
}

print_history() {
    case $(find "$C_DIR" -maxdepth 1 -type f | wc -l) in
    0) printf '\000message\037history is empty\n\000urgent\0370\n \000nonselectable\037true\n' ;;
    *)
        [ -z "$1" ] && printf '\000new-selection\0370\n'
        printf '\000message\037history\n\000data\037_history\n'
        find "$C_DIR" -type f -printf '%T@ %p\n' |
            sort -k 1nr | cut -d' ' -f2- |
            while read -r file; do
                query="$(basename "$file" | base64 -d |
                    sed 's/[&]/\&amp;/g; s/[<]/\&lt;/g; s/[>]/\&gt;/g; s/["]/\&quot;/g; s/['"'"']/\&\#39;/g')"
                printf '%s\000info\037%s\n' "$query" "$file"
            done
        ;;
    esac
}

case $ROFI_RETV in
# print banner on start and kb-custom-2 (ctrl-s)
0 | 11) banner ;;
# select line
1)
    if [ "$ROFI_DATA" = _history ]; then
        print_from_cache "$ROFI_INFO"
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
# handle custom input
2) handle_query "$@" ;;
# kb-custom-1 (ctrl-c) - clear list rows
10) clr ;;
# kb-custom-3 (ctrl-r) - refresh cached result
12)
    if [ "$ROFI_DATA" = _history ]; then
        print_history
        exit 0
    fi
    if [ -z "$ROFI_DATA" ] || [ ! -f "$ROFI_DATA" ]; then
        banner
    fi
    subj="$(basename "$ROFI_DATA" | base64 -d)"
    [ -n "$subj" ] || banner
    if ! rm -f "$ROFI_DATA"; then
        err_msg "Error while deleting $ROFI_DATA"
    fi
    handle_query "$subj"
    ;;
# kb-custom-4 (ctrl-h) - history
13) print_history ;;
# kb-custom-5 (ctrl-x,Delete) - delete history element
14)
    [ "$ROFI_DATA" = _history ] || banner

    results_cache="${C_DIR}/$(echo "$1" | base64)"
    if [ -f "$results_cache" ]; then
        rm -f "$results_cache"
    else
        printf '\000message\037file %s not found\n' "$results_cache"
    fi
    print_history keep-selection

    ;;
esac
