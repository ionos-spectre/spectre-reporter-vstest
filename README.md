# Spectre::Reporter::VSTest

This module generates a VSTest report for [spectre](https://github.com/ionos-spectre/spectre-core) test runs, which can be used for Azure DevOps integration.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add spectre-reporter-vstest

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install spectre-reporter-vstest

## Usage

Include the `spectre/reporter/vstest` module in your `spectre.yml` file, so it is automatically loaded.

```yaml
[...]
include:
 - spectre/reporter/vstest
```

Run `spectre` with the `-r` (reporters) parameter to generate a VSTest report file.

```bash
spectre -r Spectre::Reporter::VSTest
```

You can also include the module with the run parameter `-p`

```
spectre -p include=spectre/reporter/vstest -r Spectre::Reporter::VSTest
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ionos-spectre/spectre-reporter-vstest.

## License

The gem is available as open source under the terms of the [GNU General Public License 3](https://www.gnu.org/licenses/gpl-3.0.de.html).
