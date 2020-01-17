# Yume-Console
Convenient CLI solution for manga downloads.
**Please read:** Don't be a douche. Use this tool with care.

### 1. Available Commands
| # | Name | Argument | Description | Optional | Parent Command
--- | --- | --- | --- | --- | ---
1 | manga | manga_id | Lists all chapters available for a selected manga. | No | *
2 | chapter |  chapter_id | Downloads a chapter. | No | No | *
3 | zip | * | Compresses the download into a ZIP archive. | Yes | chapter
4 | language | lang_code | manga | Yes | manga
5 | about | * | Shows about dialog. | * | *
6 | help | * | Shows help dialog. | * | *

### 2. How to use
##### 1. List manga chapters:
- Command: `yume -m <manga_id>`
![Search result.](https://i.imgur.com/OI4PenC.png)

##### 2. List manga chapters matching a specific language:
- Command: `yume -m <manga_id> -l <lang_code>`
![Much more specific search result.](https://i.imgur.com/4hPmiQh.png)

##### 3. Download a chapter:
- Command: `yume -c <chapter_id>`
![Download chapter](https://i.imgur.com/SGBe5jv.png)

##### 4. Download compressed chapter:
- Command: `yume -c <chapter_id> -z`
![Download ZIP](https://i.imgur.com/sI1bICS.png)

### 3. To-do
1. Clean up a bug or two here and there but since they're nothing major and don't impact usability in any way, they're not a priority on my list right now.

# 4. Contributors
* Jinzulen (Find me on Discord @ Jin#8303)
* Modder4869 - Ideas and helping me out with a few puzzling things every now and then.