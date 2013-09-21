# Dropwizard Spring DI/Security Example #

Example showing how to integrate Dropwizard, Spring DI, Spring Security together.
They are compiled into a single uber-jar using the Gradle Shadow plugin: <https://github.com/johnrengelman/shadow>.

*We used the OneJar plugin before (hence it is in the title of this example), but it caused issues with Dropwizard's  HTML asset loading mechanism, so we replaced it with the Gradle Shadow plugin.*

It also shows how to perform integration testing of a REST application
using the famous BDD tool Cucumber:

http://cukes.info

This application was prepared for a Houston JUG presentation:

https://github.com/jacek99/dropwizard-spring-di-security-onejar-example/raw/master/Dropwizard_Spring.pdf

**Note**

This application uses Lombok:
http://projectlombok.org/

Please make sure you have the appropriate Lombok plugin installed in your IDE.


## Core Gradle tasks ##

### gradle idea ###

Regenerate IDEA IntelliJ bindings

### gradle eclipse ###

Regenerate Eclipse bindings

### gradle run ###

Runs the app *main()* method

### gradle shadow ###

Compiles the entire app together with its dependencies into one single uber-JAR, using the Gradle Shadow plugin

### gradle runShadow ###

Compiles and runs the Gradle Shadow uber-JAR version of the app

### gradle bdd ###

Runs the uber-JAR on a separate thread and executes the entire BDD test suite against the running application.


## Integration testing with BDDs ##

Mock frameworks are the false prophets of Java application testing.

Your only surefire way to test your logic is to fire requests at your fully running app and verify its behaviour and responses.
Cucumber-style BDDs are the best and most productive way to accomplish this task IMHO:

http://cukes.info/

To get it fully running and installed do the following:

**Ubuntu / Debian**

    sudo apt-get install ruby ruby-dev libyaml-dev
    sudo gem install bundler
    bundle install

**Fedora / CentOS**

    sudo yum install ruby ruby-devel libyaml-devel
    gem install bundler
    bundle install

**Windows**

Install Ruby 1.9 (NOT 2.0) for Windows: 
http://rubyinstaller.org/

and the Ruby 1.9 DevKit as well:
http://rubyinstaller.org/add-ons/devkit/

Install the dev kit (from the folder where you placed it):

    ruby dk.rb init
    ruby dk.rb install

The rest is similar afterwards:

    gem install bundler
    bundle install

### Running BDDs manually ###

Run the app from your IDE.

You will need to create a launcher that passes in the **server myapp.yml** program arguments to the main class
MyAppService, as seen in the image below:

https://raw.github.com/jacek99/dropwizard-spring-di-security-onejar-example/master/launcher.png

Go to a terminal and do

	cd src/test/resources/bdd
	cucumber

and you should see a human-readable BDD execute:

https://github.com/jacek99/dropwizard-spring-di-security-onejar-example/blob/master/src/test/resources/bdd/features/country_rest.feature


# Native Linux Packaging (DEB and RPM) #

One of the greatest aspects of Dropwizard and Gradle Shadow is that it is very easy to wrap your application
in a native Linux package such as a **.deb** or a **.rpm** file.

This allows to set up as a Linux daemon, use respawn capabilities (lets the OS restart your app automatically in case of a crash),
and natively install/uninstall using the OS's built-in packaging capabilities.

If you are using tools such as Puppet or Chef for DevOps, having your app delivered in a native Linux package makes it trivial
for them to roll it out across a large number of servers in a datacenter.

## Gradle tasks ##

### gradle deb ###

Create a native **.deb** file (in *build/distributions*)

You can then install the **.deb**:

    sudo dpkg -i build/distributions/myapp-1.1.deb

    Selecting previously unselected package myapp.
    (Reading database ... 370503 files and directories currently installed.)
    Unpacking myapp (from .../distributions/myapp-1.1.deb) ...
    Setting up myapp (1.1) ...
    Installing new version of config file /etc/myapp.yml ...
    Processing triggers for ureadahead ...

Run it as a service:

    sudo service myapp start

    myapp start/running, process 20141

    ps -ef | grep myapp
    root     20141     1 46 12:57 ?        00:00:04 /usr/lib/jvm/java-1.7.0-openjdk-amd64/bin/java -Xms512m -Xmx512m -jar -server myapp-shadow.jar server /etc/myapp.yml

Kill it and verify Linux restarted it automatically:

    sudo kill -9 20141

    ps -ef | grep myapp
    root     20184     1 99 12:57 ?        00:00:02 /usr/lib/jvm/java-1.7.0-openjdk-amd64/bin/java -Xms512m -Xmx512m -jar -server myapp-shadow.jar server /etc/myapp.yml

Uninstall it and verify the service got stopped automatically (look for the *"Stopping MyApp..."* message):

    sudo apt-get remove myapp

    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    The following packages will be REMOVED:
      myapp
    0 upgraded, 0 newly installed, 1 to remove and 2 not upgraded.
    After this operation, 0 B of additional disk space will be used.
    Do you want to continue [Y/n]? y
    (Reading database ... 370503 files and directories currently installed.)
    Removing myapp ...
    Stopping MyApp...
    myapp stop/waiting
    Processing triggers for ureadahead ...

In the sample above, we are running the service as **root**, which is not recommended.
You can change the default user by modifying the contents of the **/etc/init/myapp.conf** file:

    # change this user if required
    # setuid root

**Note**:  You can create .deb files on CentOS / Fedora as well. You just need to have the **dpkg** package installed:

    sudo yum install dpkg

and the *gradle deb* task will execute successfully on those flavors of Linux as well.
You can obviously install the actual **.deb** on Debian systems only though.




