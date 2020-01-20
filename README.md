# Yume-Console
Convenient CLI solution for manga downloads.

[![Known Vulnerabilities](https://snyk.io/test/github/Jinzulen/Yume-Console/badge.svg?targetFile=package.json)](https://snyk.io/test/github/Jinzulen/Yume-Console?targetFile=package.json) [![CodeFactor](https://www.codefactor.io/repository/github/jinzulen/yume-console/badge/master)](https://www.codefactor.io/repository/github/jinzulen/yume-console/overview/development) ![NPM Weekly Downloads](https://img.shields.io/npm/dw/yumec.svg)

[![https://nodei.co/npm/tenorjs.png](https://nodei.co/npm/yumec.png)](https://www.npmjs.com/package/yumec)

**Please read:** Don't be a douche. Use this tool with care.

**HOW TO INSTALL:** `npm i yumec -g`

### 1. Available Commands
| # | Name | Argument | Description | Optional | Parent Command
--- | --- | --- | --- | --- | ---
1 | manga | manga_id | Lists all chapters available for a selected manga. | No | *
2 | chapter |  chapter_id | Downloads a chapter. | No | *
3 | zip | * | Compresses the download into a ZIP archive. | Yes | chapter
4 | group | group_name | Displays chapters by a specific scanlation team. | Yes | manga
5 | language | lang_code | Displays chapters in a specific language. | Yes | manga
6 | order | desc | Chapter display by default is in ascending order, this makes it descending. | Yes | manga
7 | show | * | Shows image links in the "Finished downloading" notice. | Yes | chapter
8 | about | * | Shows about dialog. | * | *
9 | help | * | Shows help dialog. | * | *

### 2. How to use
##### 1. List manga chapters:
- Command: `yume -m <manga_id>`
![Search result.](https://i.imgur.com/OI4PenC.png)

##### 2. List manga chapters matching a specific language:
- Command: `yume -m <manga_id> -l <lang_code>`
![Much more specific search result.](https://i.imgur.com/4hPmiQh.png)

###### 2. A List manga chapters in descending order:
- Command: `yume -m <manga_id> -o desc`
![Descending order display.](https://i.imgur.com/jNJ6Obf.png)

###### 2. B List manga chapters by a specific scanlation team:
- Command: `yume -m <manga_id> -g "group_name"`
![Scanlation team search.](https://i.imgur.com/jtQwqo2.png)

##### 3. Download a chapter:
- Command: `yume -c <chapter_id>`
- **FYI:** Downloaded chapters are placed automatically into your system's default downloads directory, might tweak it in the future to consider a user's custom destination but for now, that's where you'll find your downloads.

![Download chapter](https://i.imgur.com/dcf7j4B.png)

###### 3. A Show image links while downloading a chapter:
- Command: `yume -c <chapter_id> -s`
![Show image links.](https://i.imgur.com/8sfn3pz.png)

##### 4. Download compressed chapter:
- Command: `yume -c <chapter_id> -z`
![Download ZIP](https://i.imgur.com/pqTL224.png)

# 3. Contributors
* Jinzulen (Find me on Discord @ Jin#8303)
* Modder4869 - Ideas, testing and helping me out with a few puzzling things every now and then.

# 4. License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FJinzulen%2FYume-Console.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FJinzulen%2FYume-Console?ref=badge_large)