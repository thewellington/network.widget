# This is a simple example Widget, written in CoffeeScript, to get you started
# with Übersicht. For the full documentation please visit:
#
# https://github.com/felixhageloh/uebersicht
#
# You can modify this widget as you see fit, or simply delete this file to
# remove it.

# this is the shell command that gets executed every time this widget refreshes
command: "network.widget/network.sh"

# the refresh frequency in milliseconds
refreshFrequency: 1000000

# render gets called after the shell command has executed. The command's output
# is passed in as a string. Whatever it returns will get rendered as HTML.
render: (output) -> """
  #{output}

"""

# the CSS style for this widget, written using Stylus
# (http://learnboost.github.io/stylus/)
style: """
  color: #fff
  font-family: Helvetica Neue
  font-weight: 300
  font-size: 14px
  line-height: 1.5
  margin-left: 0px
  padding: 20px 20px 20px
  bottom: 0%
  left: 0%
  width: 340px
  text-align: justify

  h1
    font-size: 18px
    font-weight: 300
    margin: 16px 0 8px

  strong
    background: #ad7a7c
    color: #fff
    display: block
    font-size: 16px
    font-style: italic
    font-weight: 200
    margin: 12px -20px
    padding: 8px 20px

  em
    font-weight: 400
    font-style: normal

  td
    padding-right: 10px

  .green
    color: #16fb13

  .red
    color: #fc0000

"""
