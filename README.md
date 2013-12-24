# MuhrTable

Easily create tables from any data source with filtering and sorting.             
Currentl supported data-sources are ActiveRecord and Array-backed.  Plugging in new            
backends is easy.  The goal is to get you up and running as fast as possible while 
being completely customizable.  The code is clean and modular so that
new features and back-ends can be quickly implemented.

Supports bootstrap but doesn't depend on it
Easy to replace back-end
No dependencies
Pagination built-in
Easy to control format of parameters and generated URLs
easy to add support for other generators (html, CSV)

## Installation

Add this line to your application's Gemfile:

    gem 'muhr_table'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install muhr_table

## Usage

Init using muhr_init(datasource)

Then in your view use muhr_grid()

## Contributing

I'm very happy to receive code contributions!  To contribute, simply do a pull-request on GitHub.  

