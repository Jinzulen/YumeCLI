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
                cAmount = Object.keys(Chapters).some (Key) ->
                    if App.language then Key.includes (App.language) else Chapters.length

                # Print data.
                console.log "### " + Manga.title
                console.log "# Artist: " + Manga.artist
                console.log "# Author: " + Manga.author
                console.log "# Status: " + Mangadex.Status[Manga.status] + "\n"

                console.log "# Chapters:"

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

                            Callback null, Data.body
        catch E
            throw E