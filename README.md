[![Build Status](https://travis-ci.org/ehainer/voltron-upload.svg?branch=master)](https://travis-ci.org/ehainer/voltron-upload)

# Voltron::Upload

Voltron upload brings [Dropzone JS](http://www.dropzonejs.com/) and logical file upload & committing to rails resources. It is an attempt to solve the issue of dropzone js uploading files immediately, often times before the resource itself has been saved (i.e. - User registration, where one might be able to upload an avatar)

The nice feature of Voltron Upload is that it requires very little additional code outside of what would be required by [carrierwave](https://github.com/carrierwaveuploader/carrierwave) and gracefully can fall back to default file field inputs in the event that Dropzone is not supported.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'voltron-upload'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install voltron-upload

Then run the following to create the voltron.rb initializer (if not exists already) and add the upload config:

    $ rails g voltron:upload:install

Also, include the necessary js and css by adding the following to your application.js and application.css

```javascript
//= require voltron-upload
```

```css
/*
 *= require dropzone
 */
```

If you want to customize the out-of-the-box functionality or styles, you can copy the assets to your app assets directory by running:

    $ rails g voltron:upload:install:assets

## Usage

Voltron upload is designed to work as seamlessly as possible with how native carrierwave functionality does. Given a model `User`, you could have something like the following:

```ruby
class User < ActiveRecord::Base

  mount_uploader :avatar, AvatarUploader

  mount_uploaders :images, ImageUploader # For multiple uploads

end
```

Your controller only needs a call to `uploadable` to include the necessary route actions:

```ruby
class UsersController < ApplicationController

  uploadable :user

end
```

The only argument to `uploadable` is the name of the model you'll be associating the uploads with, and is also optional. If omitted, Voltron Upload will try to determine it by the controller name. A controller named `UsersController` will look for a model named `User`, `PeopleController` will look for a model named `Person`, etc... If you have any doubts in it's ability to determine the model, just define it like shown above.

Lastly, you need to include the routes in your routes.rb config file:

```ruby
Rails.application.routes.draw do

  upload_for :users

  # Or, specify multiple controllers at once:

  upload_for :users, :people, :companies

end
```

As for your markup, Voltron Upload overrides the `file_field` helper method, but the options remain the same so nothing out of the ordinary needs to change. However, two additonal arguments are possible:

* :default_input -> If voltron upload is enabled, setting this to `true` bypasses the default upload markup output and uses the rails default `file_field` method
* :preserve -> By default, voltron upload will display already uploaded files in the dropzone container when shown. Set to `false` to not do that

There are also several data attributes you can provide to customize a bit further:

* :data
  * :preview -> Either a CSS selector to an element or the raw HTML markup to use as the dropzone preview. See: http://www.dropzonejs.com/#config-previewTemplate
  * :upload -> Should not ever need to be altered as it is determined automatically, but this contains the URL of your upload controller action. Overriding this assumes you are going to handle file uploads on your own.

## Cleaning Up

Due to the way Voltron Upload allows for instant upload, and later "committing" said uploads once a form is submitted, there are times where a user might upload a file and then abandon the form, leaving the uploaded file in a state of limbo, using space on your server. To remedy this, it's encouraged that you setup some sort of scheduled task to periodically run:

```ruby
Voltron::Upload::Tasks.cleanup
```

The cleanup process will take into account the value of `Voltron.config.upload.keep_for`, deleting only records/files that are older than what is defined. How you choose to run the above command is up to you. I personally would recommend the [whenever](https://github.com/javan/whenever) gem, but there are any number of ways to skin a cat so ultimately you decide. Or don't, and buy large hard drives.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ehainer/voltron-notify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

