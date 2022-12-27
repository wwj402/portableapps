NTLinksMaker tool for Total Commander
-------------------------------------
(information in English is below)

Утилита для создания NTFS-ссылок всех типов:
+ создание точек соединения, жестких ссылок, а также символических ссылок
+ возможность дублирования нескольких уровней каталогов обычными каталогами
+ возможность сохранения иерархии каталогов (для объектов из разных каталогов)
+ запрос повышения для операций, требующих прав администратора
+ возможность работы без отображения диалоговых окон
+ поддержка Юникода и длинных путей


1. Общие возможности

NTLinksMaker - утилита для создания ссылок уровня файловой системы для отдельного файла/каталога или списка объектов. Поддерживаются все доступные в Windows типы ссылок, при необходимости запрашиваются права администратора.

Точки соединения каталогов - это псевдокаталоги, внутри которых операционная система отображает содержимое целевых каталогов, позволяя также изменять его. Идентичны точкам монтирования, которые представляют собой ссылки на тома. Старые программы (включая Проводник в Windows XP) не отличали их от обычных каталогов и при удалении ссылки удаляли все файлы внутри целевого каталога, поэтому лучше удалять их из ТК. Поддерживаются с Windows 2000.

Жесткие ссылки файлов - это равноправные записи, ссылающиеся на общее содержимое файла. Могут иметь различные имена и находиться в разных каталогах в пределах одного тома. Изменение атрибутов, прав доступа или содержимого через любую из них изменяет сам файл. При изменении файла через одну ссылку остальные могут продолжать отображать устаревшую информацию, пока файл не будет открыт через них. Содержимое файла хранится на диске, пока есть хотя бы одна жесткая ссылка на него. Поддерживаются с Windows 2000.

Символические ссылки каталогов - ссылки, похожие на точки соединения, но допускающие относительные и сетевые пути. Как и в случае точек соединения, старые программы могут при удалении ссылки очищать содержимое целевого каталога. Поддерживаются с Windows Vista, для создания нужны права администратора.

Символические ссылки файлов - псевдофайлы, позволяющие обращаться к содержимому целевых файлов и изменять его. Они не отображают размера (он всегда нулевой) и атрибутов целевого файла (дата модификации всегда равна дате создания ссылки). Поддерживаются с Windows Vista, для создания нужны права администратора.


2. Диалоговое окно

В окне можно изменить путь к папке, в которой будут созданы ссылки, и имя создаваемой ссылки. Если объектов больше одного, необходимо в качестве имени указывать *.* или более сложную маску (например, *_z.* добавляет к именам окончание "_z", а одиночная * отбрасывает расширения).

Для сохранения взаимного расположения объектов относительно некоторого каталога (см. опцию /r), маска имени ссылки должна начинаться со *, а также должна быть включена соответствующая опция.

Также можно выбрать количество уровней каталогов для дублирования в виде каталогов (см. опцию /l) и типы создаваемых ссылок для файлов и каталогов.

В зависимости от того, какие объекты содержатся в списке, ненужные элементы управления блокируются, в частности, выбор типов ссылок на папки, когда в списке нет папок.


2.1. Режимы создания ссылок

Для файлов:
	1. Жёсткие ссылки - создавать только жёсткие ссылки
	2. Символические ссылки (при необходимости) - создавать символические ссылки, только если нельзя создать жёсткие (между разными дисками)
	3. Только символические ссылки - создавать только абсолютные символические ссылки
	4. Относительные символические ссылки - создавать только относительные символические ссылки
	5. Относительные символические ссылки (по возможности) - создавать относительные символические ссылки, если возможно, иначе - абсолютные

Для папок:
	1. Точки соединения - создавать только точки соединения
	(остальные пункты - как для файлов)


3. Обработка ошибок

Программа сообщает о возникающих ошибках и предлагает несколько действий. Вы можете прервать создание ссылок и завершить программу, пропустить текущий объект или все последующие объекты с ошибками. Также Вы можете устранить проблему и попробовать повторно создать ссылку для текущего объекта.

При нажатии кнопки повтора операции все последующие действия выполняются от имени администратора.

При запуске в тихом режиме все ошибки молча пропускаются, права администратора не запрашиваются.


4. Командная строка

В командной строке задаются исходные объекты, для которых необходимо создать ссылки, каталог назначения, а также некоторые параметры создания ссылок и поведения программы. Синтаксис:

NTLinksMaker[.exe] [<parameters>] {<src_file>|@<src_list_utf16>} <dst_path>

Параметры:
	/l=0
		Количество уровней, на которых каталоги будут продублированы как обычные каталоги, внутри которых будут размещены файловые ссылки. На следующем уровне будут созданы каталоги-ссылки.
	/s[f|d][?|r|r?], /s[f|d]<num>
		Буквы f (файлы) и d (каталоги) уточняют тип объектов, для которых создавать тип ссылок, указанный далее. Тип можно задавать строкой или числом: "-" - без символических, пустой - только символические, "?" - символические при необходимости, "r" - относительные символические, "r?" - относительные символические по возможности, число - соответствует номеру варианта в диалоге (подробнее см. в п.п. 2.1). Если ключ /s не указан, для каталогов создаются точки соединения, а для файлов - жесткие ссылки.
	/r=<path>
		Данная опция позволяет создавать ссылки для объектов с сохранением их взаимного расположения. Для каждого объекта определяется и воссоздается частичная структура каталогов относительно указанного базового каталога.
	/b
		Блокировать окно ТК при отображении диалога утилиты (как и при обычных диалогах ТК).
	/n
		Ключ необходимо указывать, если целевой путь включает имя ссылки (а не только путь к папке, где её нужно создать).
	/q
		Включить тихий режим, в котором во время работы утилиты не будет показано никаких диалоговых окон и запросов. Будут сделаны действия, которые возможно сделать, и возвращён код результата (ненулевой, если были ошибки).

После списка параметров указывается путь к исходному файлу или каталогу (или же путь к файлу-списку в кодировке UTF-16 с префиксом @) и путь к каталогу назначения.


Примеры запуска:

Создать ссылку на D:\TEMP в папке C:\TEST (с отображением диалогового окна):
NTLinksMaker.exe "D:\TEMP" "C:\TEST\"

Создать ссылку на D:\TEMP в папке C:\TEST с именем TEMPORARY (в тихом режиме):
NTLinksMaker.exe /q /n "D:\TEMP" "C:\TEST\TEMPORARY"

Создать символические ссылки для объектов из файла-списка D:\list.txt в папке C:\TEST (в тихом режиме, нужны права администратора):
NTLinksMaker.exe /q /s "@D:\list.txt" "C:\TEST\"

Создать жёсткие ссылки для файлов и по возможности относительные символические ссылки для каталогов из файла-списка D:\list.txt в папке C:\TEST:
NTLinksMaker.exe /sf1 /sd5 "@D:\list.txt" "C:\TEST\"
NTLinksMaker.exe /sf- /sdr? "@D:\list.txt" "C:\TEST\"


5. Файл конфигурации

Конфигурационный файл должен находиться в папке утилиты и иметь такое же имя файла, но расширение INI.

Параметры секции [NTLinks Maker]:

	FontName
		Название шрифта диалогового окна;
	FontSize
		Размер шрифта диалогового окна. Влияет также на размер элементов окна. Может использоваться без указания FontName;
	Language
		Имя выбранного файла языка сообщений (без пути и расширения);
	ConfirmSymlinkElevation=1
		Показывать подтверждение запроса прав администратора для создания символических ссылок;
	CopyAttributesToLinks=0
		Устанавливать символическим ссылкам атрибуты целевых объектов (только чтение, скрытый, системный);
	FollowLinkDirLevels=0
		Заходить в ссылки на каталоги при дублировании уровней (по умолчанию ссылки дублируются как ссылки).

6. Интеграция с ТК

Чтобы из ТК можно было создавать ссылки для одного или выделенны объектов с помощью утилиты, нужно создать кнопку на панели инструментов или пользовательскую команду (тогда можно будет добавить утилиту в главное меню или настроить комбинацию клавиш). В поле параметров рекомендуется указывать следующее: /q- /b /r="%P" "@%WL" "%T". Кроме того, можно изменить начальные состояния опций диалога с помощью ключей /l и /s. Чтобы окно справки не появлялось при запуске утилиты, когда фокус установлен на элемент "..", можно добавить ключ /q в поле команды: "NTLinksMaker.exe" /q.


Обсуждение на официальном русскоязычном форуме: http://forum.wincmd.ru/viewtopic.php?t=13191



NTLinksMaker tool for Total Commander
-------------------------------------
(English section)

Tool for NTFS links creation:
+ supports junctions, hardlinks and symbolic links
+ allows duplicating first levels with regular folders
+ allows keeping directory structure (for objects from multiple dirs)
+ elevation request when admin rights needed
+ supports silent mode w/o any windows
+ Unicode and long paths support


1. General features

NTLinksMaker is a tool for creating file system links for single file/folder or a list of objects. All link types available in Windows are supported, the tool asks for elevation when administrator rights are required.

Junctions - pseudo-folders that show contents of some target folders and allow modifying it. They are similar to mount points that link to volumes. Old programs (including Explorer in Windows XP) treat them as regular folders and erase all target folder contents when you delete link, so it is better to delete them from TC. Supported since Windows 2000.

File hardlinks - equivalent links to the same file contents. Such links may have different names and located in different folders within same volume. You can change file attributes or contents via any of them, and other ones may show old attributes until you open file via them. File contents is kept on disk while at least one hardlink exists. Supported since Windows 2000.

Symbolic folder links - ones similar to junctions but support relative and UNC paths. Old programs may erase all target folder contents when you delete link. Supported since Windows Vista, administrator rights required for creation.

Symbilic file links - pseudo-files providing access to target file contents. Such links don't show file size (it is always zero) and attributes (modification date is always the same as link creation date). Supported since Windows Vista, administrator rights required for creation.


2. Dialog

You can change destination path and link name. In case of multiple objects link name must be *.* or a more complex mask (e.g. *_z.* adds "_z" to names while lonely * strips extensions).

If you want to keep partial paths of items relative to some folder, you should start file mask with * and enable corresponding option.

Also you can set number of levels to be duplicated as regular folders (/l option) and specify desired link types to be created for files and folders.

Some unneeded dialog controls may be disabled depending on list of targets, e.g. folder link type selector when no folders in list.


2.1. Link creation modes

For files:
	1. Hardlinks - only hardlinks
	2. Symbolic links (if necessary) - create symbolic links if hardlink creation fails (e.g. between volumes)
	3. Symbolic links only - only absolute symbolic links
	4. Relative symbolic links - only relative symbolic links
	5. Relative symbolic links (if possible) - relative symbolic links if possible, absoulte ones otherwise

For directories:
	1. Junctions - only junctions
	(other choices - as for files)


3. Error handling

The tool reports all errors and asks for an action. You can abort creation of links and exit, or you can skip current object or all further objects with errors. You also can fix problem and try to repeat link creation for current object.

If you ask to repeat, all further operations will be done with admin rights.

In silent mode no error messages or elevation requests will be shown.


4. Command line

Command line accepts source objects and destination path, and also optional parameters. Syntax:

NTLinksMaker[.exe] [<parameters>] {<src_file>|@<src_list_utf16>} <dst_path>

Parameters:
	/l=0
		Number of levels where folders will be duplicated as regular folders with file links inside them. Next level will be duplicated with folder links.
	/s[f|d][?|r|r?], /s[f|d]<num>
		Letters f (files) and d (directories) specify object types for creating links. Type may be specified with string or number: "-" - no symbolic, empty - symbolic only, "?" - symbolic if required, "r" - symbolic relative, "r?" - symbolic relative if possible, number - just like in dialog (refer to section 2.1 for details). If switch is not passed, junctions are created for folders and hardlinks for files.
	/r=<path>
		This option allows links creation with keeping directory structure. It sets base path which is used to detect and re-create partial paths for all objects.
	/b
		Block TC window when dialog is shown (as for regular copy/move TC dialogs).
	/n[-]
		This option must be set when destination path contains also link name.
	/q
		Enable silent mode which suppresses all questions and confirmations. Only possible actions will be performed and status code returned (nonzero in case of errors).

After parameters you should specify path to a source object (or path to a UTF-16 text file with list of objects prefixed with @) and a destination path.


Examples:

Create link for D:\TEMP in C:\TEST (dialog will be shown):
NTLinksMaker.exe "D:\TEMP" "C:\TEST\"

Create link for D:\TEMP in C:\TEST with name TEMPORARY (silent mode):
NTLinksMaker.exe /q /n "D:\TEMP" "C:\TEST\TEMPORARY"

Create symbolic links for objects from list D:\list.txt in C:\TEST (silent mode, admin rights required):
NTLinksMaker.exe /q /s "@D:\list.txt" "C:\TEST\"

Create symbolic links for files and possible relative links for folders from list D:\list.txt in C:\TEST:
NTLinksMaker.exe /sf1 /sd5 "@D:\list.txt" "C:\TEST\"
NTLinksMaker.exe /sf- /sdr? "@D:\list.txt" "C:\TEST\"


5. Configuration file

Configuration file must be placed near application and have same name and extension INI.

Parameters in [NTLinks Maker] section:

	FontName
		Dialog font face name;
	FontSize
		Dialog font size. Also affects size of controls. May be used without FontName;
	Language
		Current language file name (just name w/o path and extension);
	ConfirmSymlinkElevation=1
		Show elevation requirement confirmation for creating symbolic links;
	CopyAttributesToLinks=0
		Copy file/folder attributes to symbolic links (read only, hidden, system);
	FollowLinkDirLevels=0
		Enumerate folder contents behind folder links while duplicating levels (by default folder links are duplicated as links).


6. Integration with TC

If you want to create links for selected files/folders in TC, you should create a buttonbar button or user command (this one will allow adding tool to main menu or assigning a hotkey for it). Recommended parameter field string is: /q- /b /r="%P" "@%WL" "%T". Also you can alter initial dialog options using /l and /s keys. If you don't like to see help window when ".." item is focused, you can add /q key to command field: "NTLinksMaker.exe" /q.


Discussion page on official board: http://www.ghisler.ch/board/viewtopic.php?t=23681



History:

2019-03-12	1.4.1.416
	+ CopyAttributesToLinks, FollowLinkDirLevels options
	+ do not start child instance if already elevated

2018-11-14	1.4.0.408
	+ locking some controls when list contains no files or folders
	+ enabling relbase checkbox for single object if dst path has wild name and /n is passed
	* some dialog controls adjusted
	* fixed enabling relbase checkbox with input field (broken since 1.3.0.376)
	* fixed passing mask to child instance

2018-10-30	1.4.0.384
	+ added numbers for link type modes in dialog
	+ added mixed relative/absolute symlink creation mode
	+ unlocking TC window explicitly after closing dialog (workaround for Windows bug)

2018-08-30	1.3.0.372
	+ relative symlink creation
	+ ConfirmSymlinkElevation option
	* separate link type selection for files and folders
	* do not allow junctions for UNC paths

2018-01-26	1.2.0.352
	+ symlink creation is allowed under Windows XP with Masatoshi Kimura driver
	* fixed overwriting of empty files by symlinks

2017-01-10	1.2.0.340
	+ wildcard filename mask support (default mask is now *.* for consistency with TC)
	+ symlinks are now created manually in Explorer-compatible form

2016-11-07	1.1.1.322
	* source/target UNC path support (long path issue)

2016-01-17	1.1.0.306
	* /l=-1 worked as /l=0

2015-10-05	1.1.0.304
	+ paths with up to 1024 characters are supported now
	* a bit better error reporting
	* fixed junctions creation for long targets

2015-07-30	1.0.5.272
	+ FontName, FontSize options added
	- Windows font detection removed

2015-02-06	1.0.5.262
	+ creates intermediate folders
	+ /r parameter with base path to cut when determining destination name
	+ /s? parameter allows symlink creation when it is impossible to create old links
	+ detects Windows font to use in dialog
	* better error handling with hardlinks and new dir creation

2014-10-08	1.0.4.170
	+ retry/skip inner files/folders in case of nonzero level number

2014-08-14	1.0.3.154
	+ ignore all button added to error dialog
	+ left/right keys goes to selection start/end in input field
	* /l=-1 is now supported

2014-02-24	1.0.2.122
	+ supports junctions/hardlinks/symlinks and folder level to duplicate
	+ asks for elevation when required
	+ is able to block TC window
	+ F5/F6 switches selection in input field (like in TC)
	* do not enter reparse points
