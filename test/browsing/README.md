# AtoM Browsing JMeter tests

Tests an AtoM site populated with demo data and using the default Dominion
theme.

`test.sh` runs JMeter in CLI mode so JMeter's GUI doesn't skew test results.

Results are written into an `output` directory (as `results.csv`). A log of
JMeter messages (debugging info, etc.) is written as `jmeter.log`.

Example (testing https://demo.accesstomemory.org):

    $ ./test.sh demo.accesstomemory.org


Command options
---------------

The protocol to test with can optionally be specified using the `--protocol`
command-line option. Example:

    $ ./test.sh demo.accesstomemory.org http --protocol="http"

The number of users to simulate can optionally be specified using the `--users`
command-line option. Example:

    $ ./test.sh demo.accesstomemory.org http --users="200"

The ramp up time can optionally be specified using the `--rampup` command-line
option. Example:

`--rampup` command-line options. Example:

    $ ./test.sh demo.accesstomemory.org http --rampup="150"

The number of loops can optionally be specified using the `--loops`
command-line option. Example:

    $ ./test.sh demo.accesstomemory.org http --loops="5"

The server,  protocol, number of users being simulated, ramp up time, and
number of loops will be displayed in JMeter's INFO-level logging.


Synthesis reports
-----------------

If the jpgc-cmd JMeter plugin is installed then, after JMeter tests are run, a
command will be run to generate a synthesis report (a mix between a Summary
Report and Aggregate Report) in the output directory (as
`synthesis_report.csv`).

The following JMeter plugins need to be installed for this to work:

* jpgc-cmd: https://jmeter-plugins.org/wiki/JMeterPluginsCMD/
* jpgc-synthesis: https://jmeter-plugins.org/wiki/SynthesisReport/
* jpgc-filterresults: https://jmeter-plugins.org/wiki/FilterResultsTool/


Loading in demo data
--------------------

To load demo data into an AtoM instance enter the following commands from
AtoM's root directory:

    $ wget https://wiki.accesstomemory.org/demfils/atom-demo-v240-data.sql.gz
    $ gunzip atom-demo-v240-data.sql.gz
    $ mysql -u <MySQL user> -p<MySQL password> -D <database name> -e "DROP DATABASE <database name>"
    $ mysql -u <MySQL user> -p<MySQL password> -e "CREATE DATABASE <database name>"
    $ mysql -u <MySQL user> -p<MySQL password> -D <database name> < atom-demo-v240-data.sql
    $ php symfony tools:upgrade-sql -B
    $ php symfony search:populate

This data will reference digital objects, etc., who file assets won't exist in
the AtoM instance but that shouldn't affect these tests.


Running tests via the GUI
-------------------------

If developing/expanding these tests you may want to run them using the GUI.

To do so without having to change the user defined variables in the test plan
you can specify the server you'd like to test,the protocol to test with (`http`
or `https`), using CLI options.

Example:

    $ ./jmeter -Jserver="192.168.168.199" \
      -Jprotocol="http" \
      -Jusers="200' \
      -rampup= "150" \
      -loops="5"

Adding a "View Results Tree" listener will allow you to see the results of
individual HTTP requests during/after test runs but should only be used for
debugging as it can use a lot of memory.
