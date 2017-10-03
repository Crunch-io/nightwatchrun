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

This way the Docker container will connect to the host's public IP address and
will be able to reach the locally running instance.

.. _Nightwatch: http://nightwatchjs.org/
.. _grunt-contrib-connect: https://github.com/gruntjs/grunt-contrib-connect#hostname
