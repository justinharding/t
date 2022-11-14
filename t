#!/bin/sh

# Show current timelog
_t_timelog() {
  echo "$timelog"
}

# Run a ledger command on the timelog
_t_ledger() {
  ledger -f "$timelog" "$@"
}

# do something in unix with the timelog
_t_do() {
    action=$1; shift
    ${action} "$@" "${timelog}"
}

# Clock in to the given project
# Clock in to the last project if no project is given
_t_in() {
  tail -1 $timelog | grep '^i' && echo "already checked in" && exit 1
  [ ! "$1" ] && set -- "$@" "$(_t_last)"
  echo i `date '+%Y-%m-%d %H:%M:%S'` "$*" >> "$timelog"
}

# Clock out
_t_out() {
  tail -1 $timelog | grep '^o' && echo "already checked out" && exit 1
  echo o `date '+%Y-%m-%d %H:%M:%S'` "$*" >> "$timelog"
}

# switch projects
_t_sw() {
  tail -1 $timelog | grep '^o' && echo "not checked in" && exit 1
  tail -1 $timelog | grep "$*" && echo "already checked in to this project" && exit 1
  echo o `date '+%Y-%m-%d %H:%M:%S'` >> "$timelog"
  echo i `date '+%Y-%m-%d %H:%M:%S'` "$*" >> "$timelog"
}

# Show the currently clocked-in project
_t_cur() {
  sed -e '/^i/!d;$!d' "${timelog}" | __t_extract_project
}

# Show the last checked out project
_t_last() {
  sed -ne '/^o/{g;p;};h;' "${timelog}" | tail -n $1 | head -n 1 | __t_extract_project
}

_t_lwd() {
    echo "7 days ago"
    _t_ledger bal -p "7 days ago" "$@"
    echo "6 days ago"
    _t_ledger bal -p "6 days ago" "$@"
    echo "5 days ago"
    _t_ledger bal -p "5 days ago" "$@"
    echo "4 days ago"
    _t_ledger bal -p "4 days ago" "$@"
    echo "3 days ago"
    _t_ledger bal -p "3 days ago" "$@"
    echo "2 days ago"
    _t_ledger bal -p "2 days ago" "$@"
    echo "yesterday"
    _t_ledger bal -p "1 days ago" "$@"
}

# Show usage
_t_usage() {
  # TODO
  cat << EOF
Usage: t action
actions:
     in - clock into project or last project
     out - clock out of project
     sw,switch - switch projects
     bal - show balance
     hours,td - show balance for today
     yd,yesterday - show balance for yesterday
     yd2 to yd9 - show balance for n days ago
     tw,thisweek - show balance for this week
     lw,lastweek - show balance for last week
     lwd - show daily balance for last week
     edit - edit timelog file
     cur - show currently open project
     last - show last closed project
     last2 to last9 - show nth last closed project
     grep - grep timelog for argument
     cat - show timelog
     head - show start of timelog
     tail - show end of timelog
     less - show timelog in pager
     timelog - show timelog file
EOF
}

#
# INTERNAL FUNCTIONS
#

__t_extract_project() {
  sed -e 's/\([^ \t]* \)\{3\}//'
}

if [ -z "$TIMELOG_STARTOFWEEK" ]; then
  _args="bal -p"
else
  _args="bal --start-of-week $TIMELOG_STARTOFWEEK -p"
fi

action=$1; shift
[ "$TIMELOG" ] && timelog="$TIMELOG" || timelog="${HOME}/.timelog.ldg"

case "${action}" in
  in)   _t_in "$@";;
  out)  _t_out "$@";;
  sw)   _t_sw "$@";;
  swl)  _t_sw "`_t_last 1`";;
  swl2)  _t_sw "`_t_last 2`";;
  swl3)  _t_sw "`_t_last 3`";;
  swl4)  _t_sw "`_t_last 4`";;
  swl5)  _t_sw "`_t_last 5`";;
  swl6)  _t_sw "`_t_last 6`";;
  swl7)  _t_sw "`_t_last 7`";;
  swl8)  _t_sw "`_t_last 8`";;
  swl9)  _t_sw "`_t_last 9`";;
  bal) _t_ledger bal "$@";;
  hours) _t_ledger bal -p "since today" "$@";;
  td) _t_ledger bal -p "since today" "$@";;
  yesterday) _t_ledger bal -p "yesterday" "$@";;
  yd) _t_ledger bal -p "yesterday" "$@";;
  yd2) _t_ledger bal -p "2 days ago" "$@";;
  yd3) _t_ledger bal -p "3 days ago" "$@";;
  yd4) _t_ledger bal -p "4 days ago" "$@";;
  yd5) _t_ledger bal -p "5 days ago" "$@";;
  yd6) _t_ledger bal -p "6 days ago" "$@";;
  yd7) _t_ledger bal -p "7 days ago" "$@";;
  yd8) _t_ledger bal -p "8 days ago" "$@";;
  yd9) _t_ledger bal -p "9 days ago" "$@";;
  thisweek) _t_ledger $_args "this week" "$@";;
  tw) _t_ledger $_args "this week" "$@";;
  lastweek) _t_ledger $_args "last week" "$@";;
  lw) _t_ledger $_args "last week" "$@";;
  lwd) _t_lwd;;
  switch)   _t_sw "$@";;
  edit) _t_do $EDITOR "$@";;
  cur)  _t_cur "$@";;
  last9) _t_last 9 "$@";;
  last8) _t_last 8 "$@";;
  last7) _t_last 7 "$@";;
  last6) _t_last 6 "$@";;
  last5) _t_last 5 "$@";;
  last4) _t_last 4 "$@";;
  last3) _t_last 3 "$@";;
  last2) _t_last 2 "$@";;
  last) _t_last 1 "$@";;
  grep) _t_do grep "$@";;
  cat)  _t_do cat "$@";;
  head)  _t_do head "$@";;
  tail)  _t_do tail "$@" | grep "^i";;
  less)  _t_do less;;
  timelog) _t_timelog "$@";;

  h)    _t_usage;;
  *)    _t_usage;;
esac

exit 0
