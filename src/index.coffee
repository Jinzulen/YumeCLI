#!/usr/bin/env node

###
# @author Jinzulen
# @license MIT License
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
YumeVersion = require(Path.join(__dirname, "../package.json"))["version"]

module.exports = new class Yume
    constructor: () ->
        App = new Commander.Command

        ## --version
        App.version YumeVersion

        App
        .option "-a, --about", "About dialog."
        .option "-g, --group <name>", "Sort out chapter display by group."
        .option "-m, --manga <id>", "Show the chapter list for a given manga."
        .option "-z, --zip", "(Optional) Zips the downloaded chapter in an archive."
        .option "-c, --chapter <id>", "The ID for the chapter you wish to download."
        .option "-o, --order <type>", "Sort out chapter display either in ascending or descending."
        .option "-l, --language <code>", "(Optional) Limit chapter display to ones of a specific language."
        .option "-s, --show", "(Optional) Will show the image link in the 'Finished downloading' notice."
        .parse process.argv

        # Check for a new version of the app.
        this.isUpdateAvailable()

        # About dialog.
        if App.about
            console.log "# Yume - Convenient CLI solution for manga downloads."
            console.log "# Published under the <MIT> license by Jinzulen (https://github.com/Jinzulen).\n"
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
                
                # Get language and group specific chapter amounts.
                cAmount = Object.keys(Chapters).length
                if App.language and not App.group then cAmount = Underscore.where(Chapters, {lang_code: App.language}).length
                if App.group and not App.language then cAmount = Underscore.where(Chapters, {group_name: (App.group).toLowerCase().split(" ").map((S) -> S.charAt(0).toUpperCase() + S.substring(1)).join(" ")}).length

                # Print data.
                console.log "### " + Manga.title
                console.log "# Artist: " + Manga.artist
                console.log "# Author: " + Manga.author
                console.log "# Status: " + Mangadex.Status[Manga.status] + "\n"

                console.log "# Chapters (" + cAmount + "):"

                # List chapters.
                chapterList = []
                Chaps = Object.keys Chapters

                # Why not just include this in the data object to begin with? istg...
                for i in Chaps then Chapters[i]["chapter_id"] = i
                    
                # If a group is specified then search the data for matches.
                if App.order == "desc" then Chapters = (Underscore.sortBy Chapters, Chapters.chapter).reverse() else Chapters = Underscore.sortBy Chapters, Chapters.chapter

                # If a group is specified then search the data for matches.
                if App.language then Chapters = Underscore.where(Chapters, {
                    lang_code: App.language
                })

                # If a group is specified then search the data for matches.
                if App.group then Chapters = Underscore.where(Chapters, {
                    group_name: (App.group).toLowerCase().split(" ").map((S) -> S.charAt(0).toUpperCase() + S.substring(1)).join(" ")
                })

                i = 0
                while i < Object.keys(Chapters).length
                    # Fill-up the table.
                    chapterList.push [
                        Chapters[i].chapter_id,
                        Mangadex.Language[Chapters[i].lang_code],
                        Chapters[i].chapter,
                        Chapters[i].volume,
                        Chapters[i].title,
                        Chapters[i].group_name,
                        Moment.unix(Chapters[i].timestamp).format("DD/MM/YYYY")
                    ]

                    i++
                    
                console.table ["ID", "Lang", "Ch.", "Vol.", "Title", "Group Name", "Date"], chapterList
        catch E
            throw E

    handleChapter: (App) ->
        try
            this.contactAPI "chapter", App.chapter, (Error, Data) ->
                if Error
                    throw Error

                # Get around Windows' folder naming issues.
                Title = (Data.title).replace(/[/:*?"<>|.]/g, "")

                # Define our directories.
                YumeFolder = OS.homedir() + "/Downloads/Yume/"

                # Chapter naming conditionals.
                if Data.chapter and Data.title then Stat = "Ch " + Data.chapter + " - " + Title
                if Data.chapter and not Data.title then Stat = "Ch " + Data.chapter
                if Data.title and not Data.chapter then Stat = Data.title
                if not Data.title and not Data.chapter then Stat = Data.id

                chapterFolder = Stat

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
                                    if App.show
                                        console.log "# [" + Data.id + "] Finished downloading: " + Page + " @ " + URI
                                    else
                                        console.log "# [" + Data.id + "] Finished downloading: " + Page

                            .on "close", Callback
                            .on "error", console.error
                        else
                            Stream = Request URI
                            .pipe FS.createWriteStream YumeFolder + chapterFolder + "/" + Page
                            .on "close", Callback
                            .on "error", console.error

                            Stream.on "finish", () ->
                                if App.show
                                    console.log "# [" + Data.id + "] Finished downloading: " + Page + " @ " + URI
                                else
                                    console.log "# [" + Data.id + "] Finished downloading: " + Page

                # Initiate download.
                chapterPages = Data.page_array;

                i = 0
                while i < chapterPages.length

                    Download Data.server + Data.hash + "/" + chapterPages[i], chapterPages[i], () ->
                        # Nothing.

                    i++
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
                                if subjectType == "manga" then return console.log "# [Error] " + Data.body.status
                                if subjectType == "chapter" then return console.log "# [Error] " + Data.body.message
                            else
                                Callback null, Data.body
        catch E
            throw E

    isUpdateAvailable: () ->
        try
            Package = ["https://raw.githubusercontent.com/Jinzulen/Yume-Console/master/package.json", YumeVersion]

            return Request Package[0], (Error, Data) ->
                Version = JSON.parse(Data.body).version

                if Package[1] < Version
                    console.log "# You are running an oudated version of Yume-Console (v" + Package[1] + "), please update to v" + Version + " as soon as possible."
                    console.log "# You can update Yume-Console by using its install command: npm i yumec -g"
                    process.exit 1
        catch E
            throw E