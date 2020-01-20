# Yume-Console
Convenient CLI solution for manga downloads.

**Please read:** Don't be a douche. Use this tool with care.

**HOW TO INSTALL:** `npm i yumec -g`

### 1. Available Commands
| # | Name | Argument | Description | Optional | Parent Command
--- | --- | --- | --- | --- | ---
1 | manga | manga_id | Lists all chapters available for a selected manga. | No | *
2 | chapter |  chapter_id | Downloads a chapter. | No | *
3 | zip | * | Compresses the download into a ZIP archive. | Yes | chapter
4 | language | lang_code | Displays chapters in a specific language. | Yes | manga
5 | order | desc | Chapter display by default is in ascending order, this makes it descending. | Yes | manga
6 | about | * | Shows about dialog. | * | *
7 | help | * | Shows help dialog. | * | *

### 2. How to use
##### 1. List manga chapters:
- Command: `yume -m <manga_id>`
![Search result.](https://i.imgur.com/OI4PenC.png)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FJinzulen%2FYume-Console.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FJinzulen%2FYume-Console?ref=badge_shield)

##### 2. List manga chapters matching a specific language:
- Command: `yume -m <manga_id> -l <lang_code>`
![Much more specific search result.](https://i.imgur.com/4hPmiQh.png)

###### 2. A List manga chapters in descending order:
- Command: `yume -m <manga_id> -o desc`
![Descending order display.](https://i.imgur.com/LguvH80.png)

##### 3. Download a chapter:
- Command: `yume -c <chapter_id>`
- **FYI:** Downloaded chapters are placed automatically into your system's default downloads directory, might tweak it in the future to consider a user's custom destination but for now, that's where you'll find your downloads.

![Download chapter](https://i.imgur.com/SGBe5jv.png)

##### 4. Download compressed chapter:
- Command: `yume -c <chapter_id> -z`
![Download ZIP](https://i.imgur.com/sI1bICS.png)

### 3. To-do
1. Clean up a bug or two here and there but since they're nothing major and don't impact usability in any way, they're not a priority on my list right now.

# 4. Contributors
* Jinzulen (Find me on Discord @ Jin#8303)
* Modder4869 - Ideas and helping me out with a few puzzling things every now and then.

## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FJinzulen%2FYume-Console.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2FJinzulen%2FYume-Console?ref=badge_large)