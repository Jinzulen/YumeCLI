#!/usr/bin/env node

###
# @author Jinzulen
# @license Apache-2.0 License
# @copyright Copyright (C) 2020 Jinzulen
###

# Core dependencies.
OS           = require "os"
FS           = require "fs"
Path         = require "path"
JSZip        = require "jszip"
Moment       = require "moment"
Request      = require "request"
Commander    = require "commander"
Underscore   = require "underscore"
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
        .option "-a, --about", "About dialog."
        .option "-m, --manga <id>", "Show the chapter list for a given manga."
        .option "-z, --zip", "(Optional) Zips the downloaded chapter in an archive."
        .option "-c, --chapter <id>", "The ID for the chapter you wish to download."
        .option "-l, --language <code>", "(Optional) Limit chapter display to ones of a specific language."
        .parse process.argv

        # Check for a new version of the app.
        this.isUpdateAvailable()

        # About dialog.
        if App.about
            console.log "# Yume - Convenient CLI solution for manga downloads."
            console.log "# Published under the <Apache 2.0> license by Jinzulen (https://github.com/Jinzulen).\n"
            console.log "# Bug reports/feature requests: https://github.com/Jinzulen/Yume-Console/issues"
            console.log "# P.S: Don't be a douche, use this tool with care and don't abuse the kindness of Mangadex."

        # Handle manga/listing requests.
        if App.manga then this.handleManga App

        # If the user has selected a chapter for download, we want a different process to handle it.
        if App.chapter then this.handleChapter App

    handleManga: (App) ->
        try
            this.contactAPI "manga", App.manga, (Error, Data) ->
                if Error
                    throw Error

                # Store data.
                Manga = Data.manga
                Chapters = Data.chapter
                
                # Get language specific chapter amounts.
                cAmount = if App.language then Underscore.where(Chapters, {lang_code: App.language}).length else Object.keys(Chapters).length

                # Print data.
                console.log "### " + Manga.title
                console.log "# Artist: " + Manga.artist
                console.log "# Author: " + Manga.author
                console.log "# Status: " + Mangadex.Status[Manga.status] + "\n"

                console.log "# Chapters (" + cAmount + "):"

                # List chapters.
                chapterList = []

                for i in Object.keys Chapters
                    Chapter = []
                    Chapter.push [i, Chapters[i]]

                    i = 0
                    while i < Chapter.length
                        i++

                        if App.language
                            Chapter[0].some (Value) ->
                                if Value.lang_code == App.language
                                    chapterList.push [
                                        Chapter[0][0],
                                        Chapter[0][i].chapter,
                                        Chapter[0][i].volume,
                                        Chapter[0][i].title,
                                        Chapter[0][i].group_id,
                                        Chapter[0][i].group_name,
                                        Moment.unix(Chapter[0][i].timestamp).format("DD/MM/YYYY")
                                    ]

                        else
                            chapterList.push [
                                Chapter[0][0],
                                Chapter[0][i].chapter,
                                Chapter[0][i].volume,
                                Chapter[0][i].title,
                                Chapter[0][i].group_id,
                                Chapter[0][i].group_name,
                                Moment.unix(Chapter[0][i].timestamp).format("DD/MM/YYYY")
                            ]

                console.table ["ID", "Ch.", "Vol.", "Title", "Group ID", "Group Name", "Date"], chapterList
        catch E
            throw E

    handleChapter: (App) ->
        try
            this.contactAPI "chapter", App.chapter, (Error, Data) ->
                if Error
                    throw Error

                Title = (Data.title).replace(/[/:*?"<>|.]/g, "")

                # Define our directories.
                YumeFolder = OS.homedir() + "/Downloads/Yume/"
                chapterFolder = "Ch " + Data.chapter + " - " + Title

                # Check for the existence of necessary directories and create them if they don't exist.
                if not FS.existsSync YumeFolder then FS.mkdirSync YumeFolder
                if not App.zip and not FS.existsSync YumeFolder + chapterFolder then FS.mkdirSync YumeFolder + chapterFolder

                Download = (URI, Page, Callback) ->
                    Request.head URI, (Error, Response, Body) ->
                        if Error
                            throw Error

                        if App.zip
                            Request {
                                uri: URI,
                                encoding: null
                            }, (Error, Response, DataP) ->
                                Buff = new Buffer.from DataP, "binary"
                                Image = Buff.toString "base64"
                                
                                ZIP.file Page, Image, { base64: true }

                                ZIP
                                .generateNodeStream { type: "nodebuffer", streamFiles: true }
                                .pipe FS.createWriteStream YumeFolder + chapterFolder + ".zip"
                                .on "finish", () ->
                                    console.log "# Finished downloading: " + Page

                            .on "close", Callback
                            .on "error", console.error
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

                            if Data.body.status != "OK"
                                if subjectType == "manga" then return Callback "# [Error] " + Data.body.status
                                if subjectType == "chapter" then return Callback "# [Error] " + Data.body.message
                            else
                                Callback null, Data.body
        catch E
            throw E

    isUpdateAvailable: () ->
        try
            Package = [
                "https://raw.githubusercontent.com/Jinzulen/Yume-Console/master/package.json",
                require(Path.join(__dirname, "../package.json"))["version"]
            ]

            return Request Package[0], (Error, Data) ->
                Version = JSON.parse(Data.body).version

                if Package[1] < Version
                    console.log "# You are running an oudated version of Yume-Console (v" + Package[1] + "), please update to v" + Version + " as soon as possible."
                    process.exit 1
        catch E
            throw E