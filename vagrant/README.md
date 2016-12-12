To set up and run a [Vagrant](https://www.vagrantup.com/) 
box running a local copy of crime-data-api, `cd` into this 
directory, then 

    vagrant up
    vagrant ssh
    ./run.sh  

Your server will be available at port 5001 on your host machine.

To run the test suite:

    vagrant ssh
    cd crime-data-api
    flask test
    # or
    py.test

You can store a snapshot of the box as a 
[package](https://www.dev-metal.com/copy-duplicate-vagrant-box/)
as a shortcut to building a new copy.




