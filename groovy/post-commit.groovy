#!/usr/bin/env groovy
 
// Arguments for git log command.
def logArgs = ['max-count': '1', 'pretty': 'format:%an commited %s {%h}']
 
// Invoke git log command.
def gitLog = logArgs.inject(['git', 'log']) { cmd, k, v ->
    cmd << "--$k=$v"
}.execute()
 
// Get git log message to be used as notification message.
def message = gitLog.text
 
// Set icon and title for message.
def iconPath = '/Users/mrhaki/Pictures/git-icon-black.png'
def title = 'Git commit'
 
// Notify user of commit with growlnotify.
def notifyArgs = [message: message, title: title, image: iconPath]
notifyArgs.inject(['growlnotify']) { cmd, k, v ->
    cmd << "--$k" << v
}.execute()