#!/usr/bin/env node

###
# @author Jinzulen
# @license MIT License
# @copyright Copyright (C) 2020 Jinzulen
###

# Core dependencies.
OS           = require "os"
FS           = require "fs"
JSZip        = require "jszip"
Moment       = require "moment"
Request      = require "request"
Commander    = require "commander"
consoleTable = require "console.table"

# Initialize JSZip.
ZIP = new JSZip

# Mangadex.
Gateway = "https://mangadex.org/api"
Mangadex = require "../mangadex.json"

module.exports = new class Yume
    constructor: () ->
        App = new Commander.Command

        App
        .option "-m, --manga <id>", "Show the chapter list for a given manga."
        .option "-z, --zip", "(Optional) Zips the downloaded chapter in an archive."
        .option "-c, --chapter <id>", "The ID for the chapter you wish to download."
        .option "-l, --language <code>", "(Optional) Limit chapter display to ones of a specific language."
        .parse process.argv

        # If the user has selected a chapter for download, we want a different process to handle it.
        if App.chapter then this.handleChapter App

    handleChapter: (App) ->
        try
            this.contactAPI "chapter", App.chapter, (Error, Data) ->
                if Error
                    throw Error

                # Define our directories.
                YumeFolder = OS.homedir() + "/Downloads/Yume/"
                chapterFolder = "Ch. " + Data.chapter + " - " + Data.title

                # Check for the existence of necessary directories and create them if they don't exist.
                if not FS.existsSync YumeFolder then FS.mkdirSync YumeFolder
                if not App.zip and not FS.existsSync YumeFolder + chapterFolder then FS.mkdirSync YumeFolder + chapterFolder

                Download = (URI, Page, Callback) ->
                    Request.head URI, (Error, Response, Body) ->
                        if Error
                            throw Error

                        if App.zip

                        else
                            Stream = Request URI
                            .pipe FS.createWriteStream YumeFolder + chapterFolder + "/" + Page
                            .on "close", Callback
                            .on "error", console.error

                            Stream.on "finish", () ->
                                console.log "# Finished downloading: " + Page

                                # Delete "undefined" file.
                                # TO-DO: Look more into this bug.
                                if FS.existsSync YumeFolder + chapterFolder + "/undefined" then FS.unlinkSync YumeFolder + chapterFolder + "/undefined"

                # Initiate download.
                chapterPages = Data.page_array;

                i = -1
                while i < chapterPages.length
                    i++

                    Download Data.server + Data.hash + "/" + chapterPages[i], chapterPages[i], () ->
                        # Nothing.
        catch E
            throw E

    contactAPI: (subjectType, subjectId, Callback) ->
        try
            return new Promise (Resolve, Reject) ->
                if typeof Callback == "function"
                    return new Promise (Resolve, Reject) ->
                        Request {
                            json: true,
                            uri: Gateway + "/" + subjectType + "/" + subjectId
                        }, (Error, Data) ->
                            if Error
                                throw Error

                            Callback null, Data.body
        catch E
            throw E