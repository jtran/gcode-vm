# G-code VM

A G-code virtual machine and post-processing DSL.

## Requirements

- Ruby v2.5 to v3.0

## Installation

To use this gem, include it in your Gemfile.

```ruby
gem 'gcode-vm', git: 'git@github.com:jtran/gcode-vm.git'
```

Then install it.

```shell
bundle install
```

## Usage

First, make a transform file, `my_transform.yml`, that specifies how to
transform a toolpath.

```yaml
version: '1'

transform:
  # Strip line-ending characters.
  - chomp

  # Change all B axis movements to D axis movements.
  - name: rename_axis
    from: B
    to: D
```

See `examples/demo.yml` for more transforms.

Then transform your G-code toolpath using your specification.

```shell
transform -t my_transform.yml thing.gcode > thing_transformed.gcode
```

## Testing

```shell
rake test
```
