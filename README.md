# OhaExtensions

Gem adds convenience methods listed below to Object, Hash and Array classes.

## Installation

Add this line to your application's Gemfile:

    gem 'oha_extensions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oha_extensions

## Usage

***
### Object extension methods:

* - has_additional_functionality_in(*files)
* - send_if_respond_to(method, *args)

***
### Hash extension methods:

* - sum(&block)
* - increment(key, amount=1, &block)
* - percent(key, &block)
* - assert_required_keys(*required_keys)
* - select_pairs(&block)
* - Hash.from_xml_string(s, options = {})

***
### Array extension methods:

* - stats
* - average
* - process_in_batches(batch_size)
* - to_hash_with_keys(options={}, &block)
* - to_lookup_hash()
* - to_identity_hash(id_proc = nil)
* - rand
* - next
* - shuffle
* - delete(first_element)

***
# Credits

[Oha_extensions](https://github.com/bkr/oha_extensions) is maintained by [Bookrenter/Rafter](http://github.com/bkr) and is funded by [BookRenter.com](http://www.bookrenter.com "BookRenter.com").

![BookRenter.com Logo](http://assets0.bookrenter.com/images/header/bookrenter_logo.gif "BookRenter.com")

# Copyright

Copyright (c) 2012 Bookrenter.com. See LICENSE.txt for further details.