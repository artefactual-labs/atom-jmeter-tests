#!/bin/bash

usage() {
  echo "Run JMeter AtoM browsing tests."
  echo ""
  echo "$0 <AtoM host>"
  echo "    -h --help"
  echo "    [--protocol=<AtoM host protocol ('http' or 'https')>]"
  echo "    [--users=<number of users to simulate>]"
  echo "    [--rampup=<number of seconds to ramp up a thread>]"
  echo "    [--loops=<number of times to run test>]"
}

# Show usage if no host argument has been provided
if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

# Show usage is first arg is -h or --help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  exit
fi

ATOM_HOST=$1

# Parse options

shift # Start option parsing at arg 3

while [ "$1" != "" ]; do
  # Attempt to parse out value
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`

  # Handle when equal sign wasn't used to set option value
  if [ -n "$CURRENT_OPTION" ]; then
    VALUE=$PARAM
    PARAM=$CURRENT_OPTION
    unset CURRENT_OPTION
  fi

  # Process option
  case $PARAM in
    -h | --help)
      usage
      exit
      ;;
    --protocol)
      ATOM_PROTOCOL=$VALUE
      ;;
    --users)
      JMETER_USERS=$VALUE
      ;;
    --rampup)
      JMETER_RAMPUP=$VALUE
      ;;
    --loops)
      JMETER_LOOPS=$VALUE
      ;;

    *)
      echo "ERROR: unknown parameter \"$PARAM\""
      usage
      exit 1
      ;;

  esac

  # Handle null values
  if [ -z "$VALUE" ]; then
    CURRENT_OPTION=$PARAM
  fi

  shift
done

# Set whether HTTP or HTTPS will be used to access AtoM server
if [ -z $ATOM_PROTOCOL ]; then
  ATOM_PROTOCOL="https"
  echo "Using *default* protocol: $ATOM_PROTOCOL"
else
  echo "Using protocol: $ATOM_PROTOCOL"
fi

# Set number of users to simulate
if [ -z $JMETER_USERS ]; then
  JMETER_USERS="10"
  echo "Using *default* number of users: $JMETER_USERS"
else
  echo "Using number of users: $JMETER_USERS"
fi

# Set rampup time
if [ -z $JMETER_RAMPUP ]; then
  JMETER_RAMPUP="100"
  echo "Using *default* rampup time: $JMETER_RAMPUP"
else
  echo "Using rampup time: $JMETER_RAMPUP"
fi

# Set loops
if [ -z $JMETER_LOOPS ]; then
  JMETER_LOOPS="10"
  echo "Using *default* number of loops: $JMETER_LOOPS"
else
  echo "Using number of loops: $JMETER_LOOPS"
fi

# Create output directory
if [ ! -d "output" ]; then
  mkdir output
fi

# Delete existing JTL file (otherwise it'll get appended to)
if [ -f output/results.csv ]; then
  rm output/results.csv
fi

# Run test, generating JTL file
echo
echo "Testing AtoM host: $ATOM_HOST..."

export HEAP="-Xms1g -Xmx1g -XX:MaxMetaspaceSize=256m"
jmeter -n -t browsing.jmx \
  -Jserver="$1" \
  -Jprotocol="$ATOM_PROTOCOL" \
  -Jusers="$JMETER_USERS" \
  -Jrampup="$JMETER_RAMPUP" \
  -Jloops="$JMETER_LOOPS" \
  -l output/results.csv

# Summarize JTL, creating synthesis_report.csv
if command -v JMeterPluginsCMD.sh &> /dev/null; then
    JMeterPluginsCMD.sh --generate-csv output/synthesis_report.csv --input-jtl output/results.csv --plugin-type AggregateReport
fi
