nightwatchrun
=============

A small shell script that helps run nightwatch tests using Selenium running in a docker container.

Usage
-----

- Create a copy of this repo (don't fork it)
- Add your Nightwatch_ tests in the ``e2e/tests`` folder, removing the existing ``crunchDemo.js``
- Configure your environments in ``env/``. Start by updating ``env/stable`` and setting it to your valid URL
- Update ``nightwatch.conf.js`` as needed
- Run ``nightwatchrun.sh``

  .. code::

      ./nightwatchrun.sh -c nightwatch.conf.js

  You should see output that looks like this:

   .. code::

      Starting selenium testing against environment: stable with version latest
      Using config file: nightwatch.conf.js
      505dfa97156f1be91f881f23b1cdcf8acd5db80b2e349a5f4d952ab5545daba6
      Today's test are run against:
      Google Chrome 60.0.3112.113 unknown
      Selenium is running at 0.0.0.0 port 32783
      Selenium is not yet alive. Sleeping 1 second.
      yarn run v1.1.0
      warning From Yarn 1.0 onwards, scripts don't require "--" for options to be forwarded. In a future version, any explicit "--" will be forwarded as-is to the scripts.
      $ "/Users/xistence/Projects/Crunch/nightwatchrun/node_modules/.bin/nightwatch" "-c" "nightwatch.conf.js"
      Running in parallel with auto workers.
      Started child process for: crunchDemo
       crunchDemo   Running in parallel with auto workers.
       crunchDemo   \n
       crunchDemo   [Crunch Demo] Test Suite
      ============================
       crunchDemo
       crunchDemo   Results for:  Demo test Google
       crunchDemo   ✔ Element <body> was visible after 71 milliseconds.
       crunchDemo   ✔ Testing if the page title equals "Crunch".
       crunchDemo   ✔ Testing if element <div.intro-message h3> contains text: "A modern platform".
       crunchDemo   ✔ Testing if element <div.intro-message h3 + h3> contains text: "for analytics".
       crunchDemo   OK. 4 assertions passed. (4.065s)

        >> crunchDemo finished.


      ✨  Done in 4.58s.
      Executed tests 1 times successfully
      Removing the docker container: nightwatchrun.nightwatch.conf.js

Flags
-----

nightwatchrun supports a variety of flags that alter its operation:

- ``-c`` [REQUIRED] -- The nightwatch configuration file to use, this is
  required.
- ``-e`` [DEFAULT: stable] -- The environment file to load, has to be available
  in ``env/``
- ``-w`` [DEFAULT: auto] -- The amount of workers that Nightwatch is allowed to
  start at once. The default sets it automatically based upon the amount of
  available cores on the host system. Lowering this may be necessary if tests
  seem to be failing randomly.
- ``-v`` [DEFAULT: latest] -- The Selenium container version tag to use,
  defaults to ``latests``.
- ``-i`` [DEFAULT: None] -- This is the local public IP of the host Docker is
  running on, this is used with the ``local`` environment, see `Local
  Environment`_ for more information.
- ``-d`` [DEFALT: False] -- This will start the debug version of the Selenium
  container, which starts a VNC server so that you may watch progress of
  nightwatch testing in real time. Will ask user to press enter before
  continuing a test run to give the user time to VNC to the newly running
  instance.
- ``-x`` [DEFAULT: 1] -- The amount of times to run the tests, this can be
  handy when dealing with a flaky test that may or may not fail. The entire
  test suite (unless alternate flags are passed to nightwatch) will be retried
  the selected number of times.

Passing flags to the underlying ``nightwatch`` is possible by ending flag input
to ``nightwatchrun.sh`` with a ``--``, anything after the ``--`` will be passed
through to ``nightwatch``. This can be used for instance to only run a singular
test:

.. code::

    ./nightwatchrun.sh -c nightwatch.conf.js -e stable -- -t e2e/tests/crunchDemo.js

Which will run that single test, instead of all tests.

Local Environment
-----------------

Due to the Docker container not having access to ``localhost`` on the host that
it runs on, you will need to use a FQDN when testing against a locally running
server. This server should also be listening on a non-localhost IP (anything
but 127.0.0.1).

In the example provided we use ``local.crunch.io``, when the Docker container
starts we add a ``/etc/hosts`` entry for ``local.crunch.io`` that points to one
of the hosts public IP addresses. If you are using something like
grunt-contrib-connect_ to host a local server, you need to set the ``hostname``
parameter to ``*`` or ``0.0.0.0``.

A ``prehook`` will attempt to determine the public IP address of the host
machine when starting with a ``local`` environment, however if it is wrong you
may override the IP address with the ``-i`` flag to ``nightwatchrun.sh``.

This way the Docker container will connect to the host's public IP address and
will be able to reach the locally running instance.

.. code::

    ./nightwatchrun.sh -e local -c nightwatch.conf.js

Will run against the local environment.

.. _Nightwatch: http://nightwatchjs.org/
.. _grunt-contrib-connect: https://github.com/gruntjs/grunt-contrib-connect#hostname
