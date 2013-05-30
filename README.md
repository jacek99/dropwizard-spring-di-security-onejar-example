Dropwizard Spring DI/Security & OneJar Example
==============================================

Example showing how to integrate Dropwizard, Spring DI, Spring Security and OneJar together.

It also shows how to perform integration testing of a REST application
using the famous BDD tool Cucumber:

http://cukes.info

This application was prepared for a Houston JUG presentation:

https://github.com/jacek99/dropwizard-spring-di-security-onejar-example/raw/master/Dropwizard_Spring.pdf

**Note**

This application uses Lombok:
http://projectlombok.org/

Please make sure you have the appropriate Lombok plugin installed in your IDE.


Gradle tasks
============

gradle idea
-----------

Regenerate IDEA IntelliJ bindings

gradle eclipse
--------------

Regenerate Eclipse bindings

gradle run
----------

Runs the app *main()* method

gradle oneJar
-------------

Compiles the entire app together with its dependencies into one single super-JAR, using the Gradle OneJar plugin

gradle runOneJar
----------------

Compiles and runs the OneJar version of the app

gradle bdd
----------

Runs the OneJar on a separate thread and executes the entire BDD test suite against the running application.


Integration testing with BDDs
=============================

Mock frameworks are the false prophets of Java application testing.

Your only surefire way to test your logic is to fire requests at your fully running app and verify its behaviour and responses.
Cucumber-style BDDs are the best and most productive way to accomplish this task IMHO:

http://cukes.info/

To get it fully running and installed do the following:

**Ubuntu / Debian**

    sudo apt-get install ruby
    sudo gem install bundler
    bundle install

**Fedora / CentOS**

    sudo yum install ruby
    gem install bundler
    bundle install

**Windows**

Install Ruby for Windows:

    http://rubyinstaller.org/

The rest is similar afterwards:

    gem install bundler
    bundle install

Running BDDs manually
=====================

Run the app from your IDE.
Go to a terminal and do

	cd src/test/resources/bdd
	cucumber

and you should see a human-readable BDD execute:

https://github.com/jacek99/dropwizard-spring-di-security-onejar-example/blob/master/src/test/resources/bdd/features/country_rest.feature
