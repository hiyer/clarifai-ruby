# clarifai-ruby

[![Build Status](https://travis-ci.org/hiyer/clarifai-ruby.png?branch=master)](https://travis-ci.org/hiyer/clarifai-ruby)

clarifai-ruby is an *unofficial* gem to work with the [Clarifai](http://www.clarifai.com/) visual recognition service. It provides simple functions to get classify an image (or video) and also provide feedback for the same. All the intelligence is in Clarifai, and this is just a dumb interface to the same.

## Installation

Add this line to your application's Gemfile:

    gem 'clarifai', :github => 'hiyer/clarifai-ruby'

And then execute

    $ bundle

Or install it yourself from source using:

    $ gem build clarifai.gemspec
    $ gem install ./clarifai-<version>.gem


### Configuration

To use Clarifai, you need to sign up and create an application on [their website](http://www.clarifai.com/). Once done, you can configure this gem using the client id and secret as follows:

    Clarifai.configure do |c|
      c.client_id = 'abc'
      c.client_secret = 'xyz'
    end

Or you may also use the following environment variables:

    $ export CLARIFAI_APP_ID='<client-id>'
    $ export CLARIFAI_APP_SECRET='<client-secret>'

## Usage

This gem provides the following interfaces:

### Get usage limits
    Clarifai.info

Gets the usage limits for the user, as described [here](https://developer.clarifai.com/docs/info).

### Classify image or video
    Clarifai.tags(<array-of-urls>)

Classifies the images (or videos) as described [here](https://developer.clarifai.com/docs/tag). Returns an array of `Clarifai::Result` objects which exposes the following information:
* url - the url for the image/video
* docid - the docid string for the image (or video) which can be used for providing feedback to the Clarifai service
* status_code - status of the classification. This will be "OK" for the image/video if the classification succeeded
* status_msg - error message from classification, if any
* as_json - the complete JSON string returned by the Clarifai service for the image/video

### Provide feedback on classification

#### Add or remove tags
    Clarifai.add_tags(<array-of-docids>, <array-of-tags-to-add>)
    Clarifai.remove_tags(<array-of-docids>, <array-of-tags-to-remove>)

Add or remove tags or from a list of images or videos. Note that these methods require `docids` and not URLs for the inputs. The docids may be obtained using the `tags` API above. These APIs do not return anything.

#### Add similar or dissimilar images
    Clarifai.add_similar_images(<array-of-docids>, <array-of-docids-of-similar-images>)
    Clarifai.add_dissimilar_images(<array-of-docids>, <array-of-docids-of-dissimilar-images>)

These methods are similar to the ones for tags above.

## TODO

* Add support for local files

## Contributing

Fork and raise a PR. Unit tests using rspec are available, so add tests for your changes if possible.

# Legal

Released under the MIT License: http://www.opensource.org/licenses/mit-license.php

Clarifai is a registered trademark of Clarifai, Inc.