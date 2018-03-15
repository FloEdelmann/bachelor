#!/bin/sh

### BEGIN INIT INFO
# Provides:          olad
# Required-Start:    $remote_fs $syslog $network
# Required-Stop:     $remote_fs $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: OLA daemon
# Description:       Open Lighting Architecture daemon
### END INIT INFO

PATH=/usr/local/bin:/bin:/usr/bin
NAME=olad
DAEMON=/usr/local/bin/$NAME
PIDFILE=/var/run/$NAME.pid
DESC="OLA daemon"
USER=pi
LOG_LEVEL=3

DAEMON_ARGS="--syslog --log-level $LOG_LEVEL"

[ -x "$DAEMON" ] || exit 0

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Starting $DESC" "$NAME"

    /sbin/start-stop-daemon --start --background --make-pidfile --pidfile $PIDFILE --umask 0002 --chuid $USER --exec $DAEMON -- $DAEMON_ARGS

    # set GPIO24 high (drive enable of IC1) and GPIO16 low (drive enable of IC2)
    echo "24" > /sys/class/gpio/export
    echo "16" > /sys/class/gpio/export
    sleep 1
    echo "out" > /sys/class/gpio/gpio24/direction
    echo "out" > /sys/class/gpio/gpio16/direction
    sleep 1
    echo "1" > /sys/class/gpio/gpio24/value
    echo "0" > /sys/class/gpio/gpio16/value

    log_end_msg $?
    ;;
  stop)
    log_daemon_msg "Stopping $DESC" "$NAME"

    /sbin/start-stop-daemon --stop --remove-pidfile --pidfile $PIDFILE --chuid $USER --exec $DAEMON --retry 10

    # reset GPIO24 and GPIO16
    echo "24" > /sys/class/gpio/unexport
    echo "16" > /sys/class/gpio/unexport

    log_end_msg $?
    ;;
  reload|force-reload|restart)
    $0 stop && $0 start
    ;;
  status)
    status_of_proc -p $PIDFILE $DAEMON $NAME && exit 0 || exit $?
    ;;
  *)
    echo "Usage: /etc/init.d/$NAME {start|stop|reload|restart|force-reload|status}" >&2
    exit 1
    ;;
esac

exit 0
