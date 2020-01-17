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

        if App.manga then this.handleManga App.manga
        if App.chapter then this.handleChapter App.chapter

    handleManga: (mangaId) ->
        this.contactAPI "manga", mangaId, (Error, Data) ->
            if Error
                throw Error

            console.log Data

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